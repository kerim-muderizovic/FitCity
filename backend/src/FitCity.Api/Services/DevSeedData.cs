using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Api.Services;

public static class DevSeedData
{
    public static async Task SeedGymPhotosAsync(IServiceProvider services, ILogger logger, CancellationToken cancellationToken = default)
    {
        using var scope = services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<FitCityDbContext>();

        var gyms = await dbContext.Gyms.AsNoTracking().ToListAsync(cancellationToken);
        if (gyms.Count == 0)
        {
            return;
        }

        var existingPhotos = await dbContext.GymPhotos
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var photoPool = new List<string>
        {
            "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1571019613914-85f342c55f42?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1554344728-77cf90d9ed26?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80"
        };

        var added = 0;
        foreach (var gym in gyms)
        {
            var gymPhotos = existingPhotos.Where(p => p.GymId == gym.Id).Select(p => p.Url).ToList();
            var missing = Math.Max(0, 2 - gymPhotos.Count);
            if (missing == 0)
            {
                continue;
            }

            var random = new Random(gym.Id.GetHashCode());
            var candidates = photoPool.Where(url => !gymPhotos.Contains(url)).ToList();
            while (missing > 0 && candidates.Count > 0)
            {
                var index = random.Next(candidates.Count);
                var url = candidates[index];
                candidates.RemoveAt(index);
                dbContext.GymPhotos.Add(new GymPhoto
                {
                    Id = Guid.NewGuid(),
                    GymId = gym.Id,
                    Url = url,
                    SortOrder = gymPhotos.Count + 1
                });
                gymPhotos.Add(url);
                missing--;
                added++;
            }
        }

        if (added > 0)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Seeded {Count} gym photos for missing gyms.", added);
        }
    }
    public static async Task SeedTrainerAvailabilityAsync(IServiceProvider services, ILogger logger, CancellationToken cancellationToken = default)
    {
        using var scope = services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<FitCityDbContext>();

        var trainers = await dbContext.Trainers
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        if (trainers.Count == 0)
        {
            return;
        }

        var memberIds = await dbContext.Users
            .AsNoTracking()
            .Where(u => u.Role == UserRole.User)
            .Select(u => u.Id)
            .ToListAsync(cancellationToken);

        if (memberIds.Count == 0)
        {
            return;
        }

        var rangeStart = DateTime.UtcNow.Date;
        var rangeEnd = rangeStart.AddDays(14);

        var totalSchedules = 0;
        var totalSessions = 0;

        foreach (var trainer in trainers)
        {
            var existingStarts = await dbContext.TrainerSchedules
                .AsNoTracking()
                .Where(s => s.TrainerId == trainer.Id
                            && s.StartUtc >= rangeStart
                            && s.StartUtc < rangeEnd)
                .Select(s => s.StartUtc)
                .ToListAsync(cancellationToken);

            var existingStartSet = new HashSet<DateTime>(existingStarts);

            var gymId = await dbContext.GymTrainers
                .AsNoTracking()
                .Where(gt => gt.TrainerId == trainer.Id)
                .Select(gt => (Guid?)gt.GymId)
                .FirstOrDefaultAsync(cancellationToken);

            var random = new Random(trainer.Id.GetHashCode());
            var busyRate = 0.3 + (random.NextDouble() * 0.2);

            var schedules = new List<TrainerSchedule>();
            var sessions = new List<TrainingSession>();

            for (var day = rangeStart; day < rangeEnd; day = day.AddDays(1))
            {
                if (day.DayOfWeek == DayOfWeek.Saturday || day.DayOfWeek == DayOfWeek.Sunday)
                {
                    continue;
                }

                for (var hour = 10; hour < 18; hour++)
                {
                    var startUtc = day.AddHours(hour);
                    var endUtc = startUtc.AddHours(1);
                    if (existingStartSet.Contains(startUtc))
                    {
                        continue;
                    }
                    var schedule = new TrainerSchedule
                    {
                        Id = Guid.NewGuid(),
                        TrainerId = trainer.Id,
                        GymId = gymId,
                        StartUtc = startUtc,
                        EndUtc = endUtc,
                        IsAvailable = true
                    };

                    if (random.NextDouble() < busyRate)
                    {
                        schedule.IsAvailable = false;
                        var memberId = memberIds[random.Next(memberIds.Count)];
                        sessions.Add(new TrainingSession
                        {
                            Id = Guid.NewGuid(),
                            UserId = memberId,
                            TrainerId = trainer.Id,
                            GymId = gymId,
                            StartUtc = startUtc,
                            EndUtc = endUtc,
                            Status = TrainingSessionStatus.Confirmed
                        });
                    }

                    schedules.Add(schedule);
                }
            }

            if (schedules.Count > 0)
            {
                dbContext.TrainerSchedules.AddRange(schedules);
                totalSchedules += schedules.Count;
            }

            if (sessions.Count > 0)
            {
                dbContext.TrainingSessions.AddRange(sessions);
                totalSessions += sessions.Count;
            }
        }

        if (totalSchedules > 0 || totalSessions > 0)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Seeded {ScheduleCount} trainer schedules and {SessionCount} sessions.", totalSchedules, totalSessions);
        }
    }

    public static async Task SeedRecommendationDataAsync(IServiceProvider services, ILogger logger, CancellationToken cancellationToken = default)
    {
        using var scope = services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<FitCityDbContext>();
        var recommendationService = scope.ServiceProvider.GetRequiredService<IRecommendationService>();

        var alreadySeeded = await dbContext.Users.AnyAsync(u => u.Email.EndsWith("@seed.fitcity.local"), cancellationToken);
        if (alreadySeeded)
        {
            return;
        }

        var trainers = await dbContext.Trainers
            .Include(t => t.User)
            .OrderBy(t => t.User.FullName)
            .ToListAsync(cancellationToken);

        if (trainers.Count == 0)
        {
            return;
        }

        var gyms = await dbContext.Gyms
            .AsNoTracking()
            .Where(g => g.IsActive)
            .ToListAsync(cancellationToken);

        var gymTrainerPairs = await dbContext.GymTrainers
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var random = new Random(1337);
        var now = DateTime.UtcNow;

        var fitnessLevels = Enum.GetValues<FitnessLevel>();

        var popularTrainers = trainers.Take(2).ToList();
        var underEngaged = trainers.Skip(2).Take(2).ToList();
        var mediumTrainers = trainers.Skip(4).ToList();

        var members = new List<User>();
        var preferences = new List<Preference>();

        for (var i = 1; i <= 30; i++)
        {
            var member = new User
            {
                Id = Guid.NewGuid(),
                Email = $"member{i:00}@seed.fitcity.local",
                FullName = $"Seed Member {i:00}",
                PhoneNumber = $"060-55{i:00}",
                PasswordHash = "HASHED:seedpass",
                Role = UserRole.User,
                CreatedAtUtc = now.AddDays(-random.Next(1, 30))
            };
            members.Add(member);

            var groupIndex = (i - 1) / 10;
            var goal = groupIndex == 0 ? TrainingGoal.Strength
                : groupIndex == 1 ? TrainingGoal.WeightLoss
                : TrainingGoal.Rehab;
            var goal2 = groupIndex == 0 ? TrainingGoal.MuscleGain
                : groupIndex == 1 ? TrainingGoal.Endurance
                : TrainingGoal.GeneralFitness;
            var workout = groupIndex == 0 ? WorkoutType.Gym
                : groupIndex == 1 ? WorkoutType.Cardio
                : WorkoutType.Pilates;
            var workout2 = groupIndex == 0 ? WorkoutType.Functional
                : groupIndex == 1 ? WorkoutType.Boxing
                : WorkoutType.Yoga;
            var level = fitnessLevels[(i - 1) % fitnessLevels.Length];

            var locationBase = gyms[random.Next(gyms.Count)];
            var lat = (locationBase.Latitude ?? 43.8563) + (random.NextDouble() - 0.5) * 0.02;
            var lon = (locationBase.Longitude ?? 18.4131) + (random.NextDouble() - 0.5) * 0.02;

            preferences.Add(new Preference
            {
                Id = Guid.NewGuid(),
                UserId = member.Id,
                FitnessGoal = goal.ToString().ToLowerInvariant(),
                TrainingGoals = new List<TrainingGoal> { goal, goal2 },
                WorkoutTypes = new List<WorkoutType> { workout, workout2 },
                FitnessLevel = level,
                PreferredWorkoutTime = i % 3 == 0 ? "Evening" : i % 3 == 1 ? "Morning" : "Afternoon",
                PreferredGymLocations = locationBase.Name,
                PreferredLatitude = lat,
                PreferredLongitude = lon,
                NotificationsEnabled = true
            });
        }

        dbContext.Users.AddRange(members);
        dbContext.Preferences.AddRange(preferences);

        var interactions = new List<UserTrainerInteraction>();
        var sessions = new List<TrainingSession>();
        var reviews = new List<Review>();
        var conversations = new List<Conversation>();
        var participants = new List<ConversationParticipant>();
        var messages = new List<Message>();
        var reviewPairs = new HashSet<(Guid UserId, Guid TrainerId)>();
        var conversationPairs = new HashSet<(Guid MemberId, Guid TrainerUserId)>();

        var groupSize = members.Count / 3;
        var groupA = members.Take(groupSize).ToList();
        var groupB = members.Skip(groupSize).Take(groupSize).ToList();
        var groupC = members.Skip(groupSize * 2).ToList();

        SeedGroup(groupA, popularTrainers.First(), 10, 5, 5);
        SeedGroup(groupB, popularTrainers.Last(), 9, 4, 4);
        SeedGroup(groupC, underEngaged.First(), 2, 4, 2);

        foreach (var member in members)
        {
            var viewCount = random.Next(2, 6);
            for (var i = 0; i < viewCount; i++)
            {
                var trainer = trainers[random.Next(trainers.Count)];
                interactions.Add(new UserTrainerInteraction
                {
                    Id = Guid.NewGuid(),
                    UserId = member.Id,
                    TrainerId = trainer.Id,
                    Type = UserTrainerInteractionType.ViewProfile,
                    Weight = 1,
                    CreatedAtUtc = now.AddDays(-random.Next(1, 30))
                });
            }

            if (random.NextDouble() < 0.35)
            {
                var trainer = trainers[random.Next(trainers.Count)];
                interactions.Add(new UserTrainerInteraction
                {
                    Id = Guid.NewGuid(),
                    UserId = member.Id,
                    TrainerId = trainer.Id,
                    Type = UserTrainerInteractionType.Favorite,
                    Weight = 2,
                    CreatedAtUtc = now.AddDays(-random.Next(1, 30))
                });
            }
        }

        foreach (var trainer in underEngaged)
        {
            var reviewer = members[random.Next(members.Count)];
            if (reviewPairs.Add((reviewer.Id, trainer.Id)))
            {
                reviews.Add(new Review
                {
                    Id = Guid.NewGuid(),
                    UserId = reviewer.Id,
                    TrainerId = trainer.Id,
                    Rating = random.Next(4, 6),
                    Comment = "Excellent coaching.",
                    CreatedAtUtc = now.AddDays(-random.Next(1, 30))
                });
            }
        }

        foreach (var trainer in mediumTrainers)
        {
            var reviewCount = random.Next(2, 4);
            for (var i = 0; i < reviewCount; i++)
            {
                var reviewer = members[random.Next(members.Count)];
                if (reviewPairs.Add((reviewer.Id, trainer.Id)))
                {
                    reviews.Add(new Review
                    {
                        Id = Guid.NewGuid(),
                        UserId = reviewer.Id,
                        TrainerId = trainer.Id,
                        Rating = random.Next(3, 5),
                        Comment = "Solid session.",
                        CreatedAtUtc = now.AddDays(-random.Next(1, 30))
                    });
                }
            }
        }

        foreach (var gym in gyms)
        {
            var gymTrainerIds = gymTrainerPairs
                .Where(gt => gt.GymId == gym.Id)
                .Select(gt => gt.TrainerId)
                .ToList();

            if (gymTrainerIds.Count == 0)
            {
                continue;
            }

            var reviewCount = random.Next(2, 5);
            for (var i = 0; i < reviewCount; i++)
            {
                var trainerId = gymTrainerIds[random.Next(gymTrainerIds.Count)];
                var reviewer = members[random.Next(members.Count)];
                if (reviewPairs.Add((reviewer.Id, trainerId)))
                {
                    reviews.Add(new Review
                    {
                        Id = Guid.NewGuid(),
                        UserId = reviewer.Id,
                        TrainerId = trainerId,
                        GymId = gym.Id,
                        Rating = random.Next(3, 6),
                        Comment = "Great gym experience.",
                        CreatedAtUtc = now.AddDays(-random.Next(1, 30))
                    });
                }
            }
        }

        SeedChats(popularTrainers.First(), members.Take(6).ToList());
        SeedChats(popularTrainers.Last(), members.Skip(6).Take(6).ToList());

        dbContext.UserTrainerInteractions.AddRange(interactions);
        dbContext.TrainingSessions.AddRange(sessions);
        dbContext.Reviews.AddRange(reviews);
        dbContext.Conversations.AddRange(conversations);
        dbContext.ConversationParticipants.AddRange(participants);
        dbContext.Messages.AddRange(messages);

        await dbContext.SaveChangesAsync(cancellationToken);

        var sampleUsers = members.Take(3).ToList();
        foreach (var member in sampleUsers)
        {
            var recommendations = await recommendationService.RecommendTrainersForUserAsync(member.Id, 3, cancellationToken);
            var trainerNames = string.Join(", ", recommendations.Select(r => r.TrainerName));
            var message = $"Seed user {member.Email} top trainers: {trainerNames}";
            logger.LogInformation(message);
            Console.WriteLine(message);
        }

        void SeedGroup(List<User> groupMembers, Trainer trainer, int bookings, int messagesToSend, int reviewsToCreate)
        {
            var gymId = dbContext.GymTrainers
                .AsNoTracking()
                .Where(gt => gt.TrainerId == trainer.Id)
                .Select(gt => (Guid?)gt.GymId)
                .FirstOrDefault();

            for (var i = 0; i < bookings; i++)
            {
                var member = groupMembers[random.Next(groupMembers.Count)];
                var start = now.AddDays(-random.Next(1, 30)).Date.AddHours(random.Next(7, 20));
                sessions.Add(new TrainingSession
                {
                    Id = Guid.NewGuid(),
                    UserId = member.Id,
                    TrainerId = trainer.Id,
                    GymId = gymId,
                    StartUtc = start,
                    EndUtc = start.AddHours(1),
                    Status = TrainingSessionStatus.Confirmed
                });

                interactions.Add(new UserTrainerInteraction
                {
                    Id = Guid.NewGuid(),
                    UserId = member.Id,
                    TrainerId = trainer.Id,
                    Type = UserTrainerInteractionType.Booking,
                    Weight = 3,
                    CreatedAtUtc = start.AddMinutes(5)
                });
            }

            for (var i = 0; i < reviewsToCreate; i++)
            {
                var reviewer = groupMembers[random.Next(groupMembers.Count)];
                if (reviewPairs.Add((reviewer.Id, trainer.Id)))
                {
                    reviews.Add(new Review
                    {
                        Id = Guid.NewGuid(),
                        UserId = reviewer.Id,
                        TrainerId = trainer.Id,
                        Rating = random.Next(4, 6),
                        Comment = "Great session.",
                        CreatedAtUtc = now.AddDays(-random.Next(1, 30))
                    });
                }
            }

            for (var i = 0; i < messagesToSend; i++)
            {
                var member = groupMembers[random.Next(groupMembers.Count)];
                var conversationId = Guid.NewGuid();
                var trainerUserId = trainer.UserId;
                var created = now.AddDays(-random.Next(1, 30));

                if (!conversationPairs.Add((member.Id, trainerUserId)))
                {
                    continue;
                }

                conversations.Add(new Conversation
                {
                    Id = conversationId,
                    MemberId = member.Id,
                    TrainerId = trainerUserId,
                    Title = "Training chat",
                    CreatedAtUtc = created,
                    UpdatedAtUtc = created.AddHours(2),
                    LastMessageAtUtc = created.AddHours(2)
                });

                participants.Add(new ConversationParticipant
                {
                    Id = Guid.NewGuid(),
                    ConversationId = conversationId,
                    UserId = member.Id,
                    JoinedAtUtc = created,
                    LastReadAtUtc = created.AddHours(2)
                });

                participants.Add(new ConversationParticipant
                {
                    Id = Guid.NewGuid(),
                    ConversationId = conversationId,
                    UserId = trainerUserId,
                    JoinedAtUtc = created,
                    LastReadAtUtc = created.AddHours(2)
                });

                messages.Add(new Message
                {
                    Id = Guid.NewGuid(),
                    ConversationId = conversationId,
                    SenderUserId = member.Id,
                    SenderRole = UserRole.User.ToString(),
                    Content = "Can we schedule a session?",
                    SentAtUtc = created.AddMinutes(15)
                });

                messages.Add(new Message
                {
                    Id = Guid.NewGuid(),
                    ConversationId = conversationId,
                    SenderUserId = trainerUserId,
                    SenderRole = UserRole.Trainer.ToString(),
                    Content = "Sure, let's find a slot.",
                    SentAtUtc = created.AddMinutes(45)
                });

                interactions.Add(new UserTrainerInteraction
                {
                    Id = Guid.NewGuid(),
                    UserId = member.Id,
                    TrainerId = trainer.Id,
                    Type = UserTrainerInteractionType.Message,
                    Weight = 2,
                    CreatedAtUtc = created.AddMinutes(10)
                });
            }
        }

        void SeedChats(Trainer trainer, List<User> membersForChat)
        {
            foreach (var member in membersForChat)
            {
                if (random.NextDouble() > 0.5)
                {
                    continue;
                }

                var conversationId = Guid.NewGuid();
                var created = now.AddDays(-random.Next(1, 30));

                if (!conversationPairs.Add((member.Id, trainer.UserId)))
                {
                    continue;
                }
                conversations.Add(new Conversation
                {
                    Id = conversationId,
                    MemberId = member.Id,
                    TrainerId = trainer.UserId,
                    Title = "Quick question",
                    CreatedAtUtc = created,
                    UpdatedAtUtc = created.AddHours(1),
                    LastMessageAtUtc = created.AddHours(1)
                });

                participants.Add(new ConversationParticipant
                {
                    Id = Guid.NewGuid(),
                    ConversationId = conversationId,
                    UserId = member.Id,
                    JoinedAtUtc = created,
                    LastReadAtUtc = created.AddHours(1)
                });

                participants.Add(new ConversationParticipant
                {
                    Id = Guid.NewGuid(),
                    ConversationId = conversationId,
                    UserId = trainer.UserId,
                    JoinedAtUtc = created,
                    LastReadAtUtc = created.AddHours(1)
                });

                messages.Add(new Message
                {
                    Id = Guid.NewGuid(),
                    ConversationId = conversationId,
                    SenderUserId = member.Id,
                    SenderRole = UserRole.User.ToString(),
                    Content = "Interested in your training style.",
                    SentAtUtc = created.AddMinutes(10)
                });

                interactions.Add(new UserTrainerInteraction
                {
                    Id = Guid.NewGuid(),
                    UserId = member.Id,
                    TrainerId = trainer.Id,
                    Type = UserTrainerInteractionType.Message,
                    Weight = 2,
                    CreatedAtUtc = created.AddMinutes(10)
                });
            }
        }
    }
}
