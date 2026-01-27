using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class RecommendationService : IRecommendationService
{
    private const int MaxLimit = 20;
    private readonly FitCityDbContext _dbContext;

    private static readonly Dictionary<TrainingGoal, TrainerSpecialty[]> GoalToSpecialties = new()
    {
        [TrainingGoal.WeightLoss] = new[] { TrainerSpecialty.WeightLoss, TrainerSpecialty.Cardio },
        [TrainingGoal.MuscleGain] = new[] { TrainerSpecialty.Hypertrophy, TrainerSpecialty.Strength },
        [TrainingGoal.Strength] = new[] { TrainerSpecialty.Strength },
        [TrainingGoal.Endurance] = new[] { TrainerSpecialty.Cardio, TrainerSpecialty.Functional },
        [TrainingGoal.Rehab] = new[] { TrainerSpecialty.Rehab, TrainerSpecialty.Mobility },
        [TrainingGoal.GeneralFitness] = new[] { TrainerSpecialty.Functional, TrainerSpecialty.Cardio }
    };

    private static readonly Dictionary<WorkoutType, TrainerSpecialty[]> WorkoutToSpecialties = new()
    {
        [WorkoutType.Gym] = new[] { TrainerSpecialty.Strength, TrainerSpecialty.Hypertrophy },
        [WorkoutType.Cardio] = new[] { TrainerSpecialty.Cardio, TrainerSpecialty.WeightLoss },
        [WorkoutType.Functional] = new[] { TrainerSpecialty.Functional },
        [WorkoutType.Boxing] = new[] { TrainerSpecialty.Boxing, TrainerSpecialty.Cardio },
        [WorkoutType.Crossfit] = new[] { TrainerSpecialty.Functional, TrainerSpecialty.Strength },
        [WorkoutType.Yoga] = new[] { TrainerSpecialty.Mobility, TrainerSpecialty.Rehab },
        [WorkoutType.Pilates] = new[] { TrainerSpecialty.Mobility, TrainerSpecialty.Rehab }
    };

    public RecommendationService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<RecommendedTrainerDto>> RecommendTrainersForUserAsync(
        Guid userId,
        int limit,
        CancellationToken cancellationToken)
    {
        var cappedLimit = NormalizeLimit(limit);
        var preferenceProfile = await GetPreferenceProfileAsync(userId, cancellationToken);

        var trainers = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .Where(t => t.IsActive)
            .ToListAsync(cancellationToken);

        if (trainers.Count == 0)
        {
            return Array.Empty<RecommendedTrainerDto>();
        }

        var trainerIds = trainers.Select(t => t.Id).ToList();
        var ratingLookup = await _dbContext.Reviews
            .AsNoTracking()
            .Where(r => trainerIds.Contains(r.TrainerId))
            .GroupBy(r => r.TrainerId)
            .Select(g => new { TrainerId = g.Key, Avg = g.Average(x => x.Rating), Count = g.Count() })
            .ToDictionaryAsync(x => x.TrainerId, x => new RatingStats(x.Avg, x.Count), cancellationToken);

        var recentBookingCounts = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => trainerIds.Contains(s.TrainerId)
                        && s.StartUtc >= DateTime.UtcNow.AddDays(-30)
                        && (s.Status == TrainingSessionStatus.Confirmed || s.Status == TrainingSessionStatus.Completed))
            .GroupBy(s => s.TrainerId)
            .Select(g => new { TrainerId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.TrainerId, x => x.Count, cancellationToken);

        var collaborativeScores = await BuildCollaborativeTrainerScoresAsync(userId, preferenceProfile, cancellationToken);

        var scored = new List<RecommendedTrainerDto>(trainers.Count);

        foreach (var trainer in trainers)
        {
            var contentScore = ComputeTrainerContentScore(preferenceProfile, trainer);
            var ratingStats = ratingLookup.TryGetValue(trainer.Id, out var stats)
                ? stats
                : new RatingStats(0, 0);
            var qualityScore = ComputeQualityScore(ratingStats);
            var collaborativeScore = collaborativeScores.TryGetValue(trainer.Id, out var collab) ? collab : 0d;
            var finalScore = (0.55 * contentScore) + (0.35 * collaborativeScore) + (0.10 * qualityScore);
            var reasons = BuildTrainerReasons(contentScore, collaborativeScore, qualityScore, ratingStats.Count);

            scored.Add(new RecommendedTrainerDto
            {
                TrainerId = trainer.Id,
                TrainerName = trainer.User.FullName,
                PhotoUrl = trainer.PhotoUrl,
                HourlyRate = trainer.HourlyRate,
                RatingAverage = ratingStats.Count > 0 ? Math.Round(ratingStats.Avg, 2) : null,
                RatingCount = ratingStats.Count,
                Score = Math.Round(finalScore, 4),
                ContentScore = Math.Round(contentScore, 4),
                CollaborativeScore = Math.Round(collaborativeScore, 4),
                QualityScore = Math.Round(qualityScore, 4),
                ExplorationBoosted = false,
                Reasons = reasons
            });
        }

        scored = scored
            .OrderByDescending(s => s.Score)
            .ThenBy(s => s.TrainerName)
            .ToList();

        ApplyExplorationBoost(scored, trainers, ratingLookup, recentBookingCounts, preferenceProfile, userId);

        return scored
            .OrderByDescending(s => s.Score)
            .ThenBy(s => s.TrainerName)
            .Take(cappedLimit)
            .ToList();
    }

    public async Task<IReadOnlyList<RecommendedGymDto>> RecommendGymsForUserAsync(
        Guid userId,
        int limit,
        CancellationToken cancellationToken)
    {
        var cappedLimit = NormalizeLimit(limit);
        var preferenceProfile = await GetPreferenceProfileAsync(userId, cancellationToken);

        var gyms = await _dbContext.Gyms
            .AsNoTracking()
            .Where(g => g.IsActive)
            .ToListAsync(cancellationToken);

        if (gyms.Count == 0)
        {
            return Array.Empty<RecommendedGymDto>();
        }

        var gymIds = gyms.Select(g => g.Id).ToList();
        var gymTrainers = await _dbContext.GymTrainers
            .AsNoTracking()
            .Include(gt => gt.Trainer)
            .Where(gt => gymIds.Contains(gt.GymId))
            .ToListAsync(cancellationToken);

        var trainerIds = gymTrainers
            .Select(gt => gt.TrainerId)
            .Distinct()
            .ToList();

        var gymRatingLookup = await _dbContext.Reviews
            .AsNoTracking()
            .Where(r => r.GymId != null && gymIds.Contains(r.GymId.Value))
            .GroupBy(r => r.GymId!.Value)
            .Select(g => new { GymId = g.Key, Avg = g.Average(x => x.Rating), Count = g.Count() })
            .ToDictionaryAsync(x => x.GymId, x => new RatingStats(x.Avg, x.Count), cancellationToken);

        var trainerRatingLookup = await _dbContext.Reviews
            .AsNoTracking()
            .Where(r => trainerIds.Contains(r.TrainerId))
            .GroupBy(r => r.TrainerId)
            .Select(g => new { TrainerId = g.Key, Avg = g.Average(x => x.Rating), Count = g.Count() })
            .ToDictionaryAsync(x => x.TrainerId, x => new RatingStats(x.Avg, x.Count), cancellationToken);

        var availabilityLookup = await _dbContext.TrainerSchedules
            .AsNoTracking()
            .Where(s => s.GymId != null
                        && gymIds.Contains(s.GymId.Value)
                        && s.StartUtc >= DateTime.UtcNow
                        && s.StartUtc <= DateTime.UtcNow.AddDays(7)
                        && s.IsAvailable)
            .GroupBy(s => s.GymId!.Value)
            .Select(g => new { GymId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.GymId, x => x.Count, cancellationToken);

        var maxAvailability = availabilityLookup.Count == 0 ? 0 : availabilityLookup.Values.Max();
        var collaborativeScores = await BuildCollaborativeGymScoresAsync(userId, preferenceProfile, cancellationToken);

        var scored = new List<RecommendedGymDto>(gyms.Count);

        foreach (var gym in gyms)
        {
            var specialtySet = gymTrainers
                .Where(gt => gt.GymId == gym.Id)
                .SelectMany(gt => gt.Trainer.Specialties)
                .ToHashSet();

            var gymTrainerIds = gymTrainers
                .Where(gt => gt.GymId == gym.Id)
                .Select(gt => gt.TrainerId)
                .Distinct()
                .ToList();

            var contentScore = ComputeGymContentScore(preferenceProfile, gym, specialtySet);
            var availabilityScore = ComputeAvailabilityScore(availabilityLookup, gym.Id, maxAvailability);
            var distanceScore = ComputeDistanceScore(preferenceProfile, gym);
            var qualityStats = gymRatingLookup.TryGetValue(gym.Id, out var gymStats)
                ? gymStats
                : ComputeFallbackGymRating(gymTrainerIds, trainerRatingLookup);
            var qualityScore = ComputeQualityScore(qualityStats);
            var collaborativeScore = collaborativeScores.TryGetValue(gym.Id, out var collab) ? collab : 0d;
            var hasDistance = distanceScore > 0;
            var weights = hasDistance
                ? new ScoreWeights(0.40, 0.20, 0.20, 0.15, 0.05)
                : new ScoreWeights(0.45, 0.25, 0.20, 0.0, 0.10);
            var finalScore = (weights.Content * contentScore)
                             + (weights.Availability * availabilityScore)
                             + (weights.Quality * qualityScore)
                             + (weights.Distance * distanceScore)
                             + (weights.Collaborative * collaborativeScore);

            var reasons = BuildGymReasons(contentScore, availabilityScore, qualityScore, distanceScore, collaborativeScore, qualityStats.Count);

            scored.Add(new RecommendedGymDto
            {
                GymId = gym.Id,
                GymName = gym.Name,
                City = gym.City,
                PhotoUrl = gym.PhotoUrl,
                WorkHours = gym.WorkHours,
                RatingAverage = qualityStats.Count > 0 ? Math.Round(qualityStats.Avg, 2) : null,
                RatingCount = qualityStats.Count,
                Score = Math.Round(finalScore, 4),
                ContentScore = Math.Round(contentScore, 4),
                CollaborativeScore = Math.Round(collaborativeScore, 4),
                QualityScore = Math.Round(qualityScore, 4),
                AvailabilityScore = Math.Round(availabilityScore, 4),
                DistanceScore = Math.Round(distanceScore, 4),
                Reasons = reasons
            });
        }

        return scored
            .OrderByDescending(s => s.Score)
            .ThenBy(s => s.GymName)
            .Take(cappedLimit)
            .ToList();
    }

    private async Task<PreferenceProfile> GetPreferenceProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        var preference = await _dbContext.Preferences
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

        return PreferenceProfile.From(preference);
    }

    private async Task<Dictionary<Guid, double>> BuildCollaborativeTrainerScoresAsync(
        Guid userId,
        PreferenceProfile profile,
        CancellationToken cancellationToken)
    {
        var similarUserIds = await FindSimilarUsersAsync(userId, profile, cancellationToken);
        if (similarUserIds.Count == 0)
        {
            return new Dictionary<Guid, double>();
        }

        var scores = new Dictionary<Guid, double>();

        var sessions = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => similarUserIds.Contains(s.UserId)
                        && s.Status != TrainingSessionStatus.Cancelled)
            .GroupBy(s => s.TrainerId)
            .Select(g => new { TrainerId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        foreach (var session in sessions)
        {
            AddScore(scores, session.TrainerId, session.Count * 3);
        }

        var reviews = await _dbContext.Reviews
            .AsNoTracking()
            .Where(r => similarUserIds.Contains(r.UserId))
            .GroupBy(r => r.TrainerId)
            .Select(g => new { TrainerId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        foreach (var review in reviews)
        {
            AddScore(scores, review.TrainerId, review.Count * 2);
        }

        var interactions = await _dbContext.UserTrainerInteractions
            .AsNoTracking()
            .Where(i => similarUserIds.Contains(i.UserId))
            .ToListAsync(cancellationToken);

        foreach (var interaction in interactions)
        {
            var weight = interaction.Weight > 0 ? interaction.Weight : DefaultWeight(interaction.Type);
            AddScore(scores, interaction.TrainerId, weight);
        }

        var trainerUserIds = await _dbContext.Trainers
            .AsNoTracking()
            .Select(t => new { t.Id, t.UserId })
            .ToListAsync(cancellationToken);

        var trainerUserMap = trainerUserIds.ToDictionary(x => x.UserId, x => x.Id);

        var conversations = await _dbContext.Conversations
            .AsNoTracking()
            .Where(c => similarUserIds.Contains(c.MemberId))
            .ToListAsync(cancellationToken);

        foreach (var conversation in conversations)
        {
            if (trainerUserMap.TryGetValue(conversation.TrainerId, out var trainerId))
            {
                AddScore(scores, trainerId, 2);
            }
        }

        return Normalize(scores);
    }

    private async Task<Dictionary<Guid, double>> BuildCollaborativeGymScoresAsync(
        Guid userId,
        PreferenceProfile profile,
        CancellationToken cancellationToken)
    {
        var similarUserIds = await FindSimilarUsersAsync(userId, profile, cancellationToken);
        if (similarUserIds.Count == 0)
        {
            return new Dictionary<Guid, double>();
        }

        var scores = new Dictionary<Guid, double>();

        var memberships = await _dbContext.Memberships
            .AsNoTracking()
            .Where(m => similarUserIds.Contains(m.UserId))
            .GroupBy(m => m.GymId)
            .Select(g => new { GymId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        foreach (var membership in memberships)
        {
            AddScore(scores, membership.GymId, membership.Count * 3);
        }

        var checkIns = await _dbContext.CheckInLogs
            .AsNoTracking()
            .Where(c => similarUserIds.Contains(c.UserId))
            .GroupBy(c => c.GymId)
            .Select(g => new { GymId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        foreach (var checkIn in checkIns)
        {
            AddScore(scores, checkIn.GymId, checkIn.Count * 2);
        }

        var sessions = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => s.GymId != null && similarUserIds.Contains(s.UserId))
            .GroupBy(s => s.GymId!.Value)
            .Select(g => new { GymId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        foreach (var session in sessions)
        {
            AddScore(scores, session.GymId, session.Count * 2);
        }

        var reviews = await _dbContext.Reviews
            .AsNoTracking()
            .Where(r => r.GymId != null && similarUserIds.Contains(r.UserId))
            .GroupBy(r => r.GymId!.Value)
            .Select(g => new { GymId = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);

        foreach (var review in reviews)
        {
            AddScore(scores, review.GymId, review.Count * 2);
        }

        return Normalize(scores);
    }

    private async Task<List<Guid>> FindSimilarUsersAsync(
        Guid userId,
        PreferenceProfile profile,
        CancellationToken cancellationToken)
    {
        if (profile.IsEmpty)
        {
            return new List<Guid>();
        }

        var otherPreferences = await _dbContext.Preferences
            .AsNoTracking()
            .Where(p => p.UserId != userId)
            .Select(p => new
            {
                p.UserId,
                p.TrainingGoals,
                p.WorkoutTypes
            })
            .ToListAsync(cancellationToken);

        var candidates = otherPreferences
            .Select(p => new
            {
                p.UserId,
                Score = OverlapScore(profile, PreferenceProfile.From(p.TrainingGoals, p.WorkoutTypes))
            })
            .Where(x => x.Score >= 0.25)
            .OrderByDescending(x => x.Score)
            .Take(20)
            .Select(x => x.UserId)
            .ToList();

        return candidates;
    }

    private static double ComputeTrainerContentScore(PreferenceProfile profile, Trainer trainer)
    {
        if (profile.IsEmpty)
        {
            return 0.3;
        }

        var trainerSpecialties = trainer.Specialties.ToHashSet();
        var goalSpecialties = MapSpecialties(profile.TrainingGoals, GoalToSpecialties);
        var typeSpecialties = MapSpecialties(profile.WorkoutTypes, WorkoutToSpecialties);

        var goalMatch = OverlapRatio(goalSpecialties, trainerSpecialties);
        var typeMatch = OverlapRatio(typeSpecialties, trainerSpecialties);
        var fitnessMatch = ComputeFitnessMatch(profile, trainer);

        return Clamp01((0.50 * goalMatch) + (0.30 * typeMatch) + (0.20 * fitnessMatch));
    }

    private static double ComputeGymContentScore(
        PreferenceProfile profile,
        Gym gym,
        HashSet<TrainerSpecialty> gymSpecialties)
    {
        if (profile.IsEmpty)
        {
            return 0.3;
        }

        var goalSpecialties = MapSpecialties(profile.TrainingGoals, GoalToSpecialties);
        var typeSpecialties = MapSpecialties(profile.WorkoutTypes, WorkoutToSpecialties);

        var specialtyMatch = Math.Max(OverlapRatio(goalSpecialties, gymSpecialties), OverlapRatio(typeSpecialties, gymSpecialties));
        var locationMatch = ComputeLocationMatch(profile, gym);

        return Clamp01((0.60 * specialtyMatch) + (0.40 * locationMatch));
    }

    private static double ComputeAvailabilityScore(
        IReadOnlyDictionary<Guid, int> availabilityLookup,
        Guid gymId,
        int maxAvailability)
    {
        if (maxAvailability <= 0)
        {
            return 0.0;
        }

        return availabilityLookup.TryGetValue(gymId, out var count)
            ? Clamp01(count / (double)maxAvailability)
            : 0.0;
    }

    private static double ComputeDistanceScore(PreferenceProfile profile, Gym gym)
    {
        if (!profile.PreferredLatitude.HasValue || !profile.PreferredLongitude.HasValue)
        {
            return 0.0;
        }

        if (!gym.Latitude.HasValue || !gym.Longitude.HasValue)
        {
            return 0.0;
        }

        var distanceKm = HaversineDistanceKm(
            profile.PreferredLatitude.Value,
            profile.PreferredLongitude.Value,
            gym.Latitude.Value,
            gym.Longitude.Value);

        if (distanceKm <= 1)
        {
            return 1.0;
        }
        if (distanceKm <= 2)
        {
            return 0.8;
        }
        if (distanceKm <= 5)
        {
            return 0.6;
        }
        if (distanceKm <= 10)
        {
            return 0.4;
        }
        if (distanceKm <= 20)
        {
            return 0.2;
        }

        return 0.0;
    }

    private static double ComputeFitnessMatch(PreferenceProfile profile, Trainer trainer)
    {
        if (!profile.FitnessLevel.HasValue)
        {
            return 0.5;
        }

        if (trainer.SupportedFitnessLevels.Count == 0)
        {
            return 0.6;
        }

        return trainer.SupportedFitnessLevels.Contains(profile.FitnessLevel.Value) ? 1.0 : 0.2;
    }

    private static double ComputeLocationMatch(PreferenceProfile profile, Gym gym)
    {
        if (profile.PreferredLocations.Count == 0)
        {
            return 0.4;
        }

        var target = $"{gym.Name} {gym.Address} {gym.City}".ToLowerInvariant();
        return profile.PreferredLocations.Any(loc => target.Contains(loc)) ? 1.0 : 0.0;
    }

    private static double ComputeQualityScore(
        IReadOnlyDictionary<Guid, RatingStats> lookup,
        Guid key)
    {
        if (!lookup.TryGetValue(key, out var entry))
        {
            return 0.0;
        }

        return ComputeQualityScore(entry);
    }

    private static double ComputeQualityScore(RatingStats entry)
    {
        if (entry.Count == 0)
        {
            return 0.0;
        }

        var avg = entry.Avg;
        var count = entry.Count;
        var ratingScore = avg / 5.0;
        var confidence = Math.Min(1.0, count / 5.0);
        return Clamp01(ratingScore * (0.60 + (0.40 * confidence)));
    }

    private static void ApplyExplorationBoost(
        List<RecommendedTrainerDto> scored,
        List<Trainer> trainers,
        IReadOnlyDictionary<Guid, RatingStats> ratingLookup,
        IReadOnlyDictionary<Guid, int> bookingCounts,
        PreferenceProfile profile,
        Guid userId)
    {
        var limit = scored.Count;
        if (limit == 0)
        {
            return;
        }

        var trainerMap = trainers.ToDictionary(t => t.Id);
        var explorationPool = scored
            .Select(item => new ExplorationCandidate
            {
                Item = item,
                QualityScore = ComputeQualityScore(ratingLookup, item.TrainerId),
                BookingCount = bookingCounts.TryGetValue(item.TrainerId, out var count) ? count : 0,
                ContentScore = ComputeTrainerContentScore(profile, trainerMap[item.TrainerId])
            })
            .Where(x => x.BookingCount <= 2 && (x.QualityScore >= 0.75 || x.ContentScore >= 0.65))
            .ToList();

        if (explorationPool.Count == 0)
        {
            return;
        }

        var slots = Math.Max(1, Math.Min(2, limit / 5));
        var random = new Random(HashCode.Combine(userId, DateTime.UtcNow.Date));

        var picks = new List<RecommendedTrainerDto>();
        var candidates = explorationPool
            .OrderByDescending(x => x.QualityScore)
            .ThenByDescending(x => x.ContentScore)
            .ToList();

        for (var i = 0; i < slots && candidates.Count > 0; i++)
        {
            var pick = WeightedPick(candidates, random);
            picks.Add(pick.Item);
            candidates.Remove(pick);
        }

        if (picks.Count == 0)
        {
            return;
        }

        var replaceIndex = Math.Max(0, scored.Count - picks.Count);
        for (var i = 0; i < picks.Count; i++)
        {
            var item = picks[i];
            item.ExplorationBoosted = true;
            if (!item.Reasons.Contains("discovery pick"))
            {
                item.Reasons.Add("discovery pick");
            }
            item.Score = Math.Max(item.Score, scored[replaceIndex + i].Score * 0.98);
            scored[replaceIndex + i] = item;
        }
    }

    private static ExplorationCandidate WeightedPick(IReadOnlyList<ExplorationCandidate> candidates, Random random)
    {
        var total = 0d;
        var weights = new double[candidates.Count];

        for (var i = 0; i < candidates.Count; i++)
        {
            var candidate = candidates[i];
            var quality = candidate.QualityScore;
            var content = candidate.ContentScore;
            var weight = Math.Max(0.1, (quality * 0.7) + (content * 0.3));
            weights[i] = weight;
            total += weight;
        }

        var roll = random.NextDouble() * total;
        for (var i = 0; i < candidates.Count; i++)
        {
            roll -= weights[i];
            if (roll <= 0)
            {
                return candidates[i];
            }
        }

        return candidates[0];
    }

    private static void AddScore(Dictionary<Guid, double> scores, Guid key, double value)
    {
        if (scores.TryGetValue(key, out var existing))
        {
            scores[key] = existing + value;
        }
        else
        {
            scores[key] = value;
        }
    }

    private static Dictionary<Guid, double> Normalize(Dictionary<Guid, double> scores)
    {
        if (scores.Count == 0)
        {
            return scores;
        }

        var max = scores.Values.Max();
        if (max <= 0)
        {
            return scores.ToDictionary(x => x.Key, _ => 0d);
        }

        return scores.ToDictionary(x => x.Key, x => x.Value / max);
    }

    private static HashSet<TrainerSpecialty> MapSpecialties<T>(
        IReadOnlyCollection<T> values,
        IReadOnlyDictionary<T, TrainerSpecialty[]> mapping)
        where T : struct
    {
        var set = new HashSet<TrainerSpecialty>();
        foreach (var value in values)
        {
            if (mapping.TryGetValue(value, out var specialties))
            {
                foreach (var specialty in specialties)
                {
                    set.Add(specialty);
                }
            }
        }
        return set;
    }

    private static double OverlapRatio(HashSet<TrainerSpecialty> left, HashSet<TrainerSpecialty> right)
    {
        if (left.Count == 0 || right.Count == 0)
        {
            return 0.0;
        }

        var overlap = left.Count(item => right.Contains(item));
        return overlap / (double)left.Count;
    }

    private static double OverlapScore(PreferenceProfile a, PreferenceProfile b)
    {
        var goalScore = OverlapRatio(MapSpecialties(a.TrainingGoals, GoalToSpecialties), MapSpecialties(b.TrainingGoals, GoalToSpecialties));
        var typeScore = OverlapRatio(MapSpecialties(a.WorkoutTypes, WorkoutToSpecialties), MapSpecialties(b.WorkoutTypes, WorkoutToSpecialties));
        return (goalScore + typeScore) / 2.0;
    }

    private static int DefaultWeight(UserTrainerInteractionType type) => type switch
    {
        UserTrainerInteractionType.Booking => 3,
        UserTrainerInteractionType.Message => 2,
        UserTrainerInteractionType.Favorite => 2,
        _ => 1
    };

    private static int NormalizeLimit(int limit)
    {
        if (limit <= 0)
        {
            return 10;
        }

        return Math.Min(limit, MaxLimit);
    }

    private static double Clamp01(double value) => Math.Max(0, Math.Min(1, value));

    private static RatingStats ComputeFallbackGymRating(
        IReadOnlyCollection<Guid> trainerIds,
        IReadOnlyDictionary<Guid, RatingStats> trainerRatings)
    {
        if (trainerIds.Count == 0)
        {
            return new RatingStats(0, 0);
        }

        var ratings = trainerIds
            .Where(trainerRatings.ContainsKey)
            .Select(id => trainerRatings[id])
            .ToList();

        if (ratings.Count == 0)
        {
            return new RatingStats(0, 0);
        }

        var totalCount = ratings.Sum(r => r.Count);
        var weightedSum = ratings.Sum(r => r.Avg * r.Count);
        var avg = totalCount > 0 ? weightedSum / totalCount : ratings.Average(r => r.Avg);
        return new RatingStats(avg, totalCount);
    }

    private static List<string> BuildGymReasons(
        double contentScore,
        double availabilityScore,
        double qualityScore,
        double distanceScore,
        double collaborativeScore,
        int ratingCount)
    {
        var reasons = new List<string>();
        if (contentScore >= 0.6)
        {
            reasons.Add("matches your goals");
        }
        if (availabilityScore >= 0.6)
        {
            reasons.Add("many free slots");
        }
        if (qualityScore >= 0.7 && ratingCount >= 2)
        {
            reasons.Add("high ratings");
        }
        if (distanceScore >= 0.6)
        {
            reasons.Add("close to you");
        }
        if (collaborativeScore >= 0.6)
        {
            reasons.Add("popular with similar members");
        }

        return reasons;
    }

    private static List<string> BuildTrainerReasons(
        double contentScore,
        double collaborativeScore,
        double qualityScore,
        int ratingCount)
    {
        var reasons = new List<string>();
        if (contentScore >= 0.6)
        {
            reasons.Add("matches your goals");
        }
        if (qualityScore >= 0.7 && ratingCount >= 2)
        {
            reasons.Add("high ratings");
        }
        if (collaborativeScore >= 0.6)
        {
            reasons.Add("popular with similar members");
        }

        return reasons;
    }

    private sealed record PreferenceProfile(
        List<TrainingGoal> TrainingGoals,
        List<WorkoutType> WorkoutTypes,
        FitnessLevel? FitnessLevel,
        List<string> PreferredLocations,
        double? PreferredLatitude,
        double? PreferredLongitude)
    {
        public bool IsEmpty => TrainingGoals.Count == 0 && WorkoutTypes.Count == 0 && !FitnessLevel.HasValue && PreferredLocations.Count == 0;

        public static PreferenceProfile From(Preference? preference)
        {
            if (preference == null)
            {
                return new PreferenceProfile(new List<TrainingGoal>(), new List<WorkoutType>(), null, new List<string>(), null, null);
            }

            var locations = SplitLocations(preference.PreferredGymLocations);
            return new PreferenceProfile(
                preference.TrainingGoals.ToList(),
                preference.WorkoutTypes.ToList(),
                preference.FitnessLevel,
                locations,
                preference.PreferredLatitude,
                preference.PreferredLongitude);
        }

        public static PreferenceProfile From(List<TrainingGoal> trainingGoals, List<WorkoutType> workoutTypes)
        {
            return new PreferenceProfile(trainingGoals, workoutTypes, null, new List<string>(), null, null);
        }

        private static List<string> SplitLocations(string? locations)
        {
            if (string.IsNullOrWhiteSpace(locations))
            {
                return new List<string>();
            }

            return locations
                .Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(item => item.Trim().ToLowerInvariant())
                .Where(item => item.Length > 0)
                .ToList();
        }
    }

    private sealed record RatingStats(double Avg, int Count);

    private sealed record ScoreWeights(
        double Content,
        double Availability,
        double Quality,
        double Distance,
        double Collaborative);

    private sealed class ExplorationCandidate
    {
        public RecommendedTrainerDto Item { get; init; } = null!;
        public double QualityScore { get; init; }
        public double ContentScore { get; init; }
        public int BookingCount { get; init; }
    }

    private static double HaversineDistanceKm(
        double lat1,
        double lon1,
        double lat2,
        double lon2)
    {
        const double radius = 6371;
        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);
        var a = Math.Pow(Math.Sin(dLat / 2), 2)
                + Math.Cos(DegreesToRadians(lat1))
                * Math.Cos(DegreesToRadians(lat2))
                * Math.Pow(Math.Sin(dLon / 2), 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return radius * c;
    }

    private static double DegreesToRadians(double degrees) => degrees * (Math.PI / 180.0);
}
