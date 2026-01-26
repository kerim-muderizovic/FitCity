using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class AdminSearchService : IAdminSearchService
{
    private const int MaxResults = 50;
    private readonly FitCityDbContext _dbContext;

    public AdminSearchService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<AdminSearchResponse> SearchAsync(
        string? query,
        string? type,
        Guid? gymId,
        string? city,
        string? status,
        CancellationToken cancellationToken)
    {
        var normalized = query?.Trim();
        var hasQuery = !string.IsNullOrWhiteSpace(normalized);
        var normalizedCity = city?.Trim();
        var normalizedStatus = status?.Trim().ToLowerInvariant();
        var typeKey = string.IsNullOrWhiteSpace(type) ? "all" : type!.Trim().ToLowerInvariant();

        var response = new AdminSearchResponse();

        if (typeKey is "all" or "gyms")
        {
            var gymQuery = _dbContext.Gyms.AsNoTracking();

            if (hasQuery)
            {
                var term = normalized!.ToLowerInvariant();
                gymQuery = gymQuery.Where(g =>
                    g.Name.ToLower().Contains(term) ||
                    g.Address.ToLower().Contains(term) ||
                    g.City.ToLower().Contains(term));
            }

            if (!string.IsNullOrWhiteSpace(normalizedCity))
            {
                var cityTerm = normalizedCity!.ToLowerInvariant();
                gymQuery = gymQuery.Where(g => g.City.ToLower().Contains(cityTerm));
            }

            if (normalizedStatus is "active" or "inactive")
            {
                var isActive = normalizedStatus == "active";
                gymQuery = gymQuery.Where(g => g.IsActive == isActive);
            }

            var gyms = await gymQuery
                .OrderBy(g => g.Name)
                .Take(MaxResults)
                .ToListAsync(cancellationToken);

            var gymIds = gyms.Select(g => g.Id).ToList();
            var memberCounts = await _dbContext.Memberships.AsNoTracking()
                .Where(m => gymIds.Contains(m.GymId))
                .GroupBy(m => m.GymId)
                .Select(g => new { g.Key, Count = g.Count() })
                .ToDictionaryAsync(g => g.Key, g => g.Count, cancellationToken);
            var trainerCounts = await _dbContext.GymTrainers.AsNoTracking()
                .Where(gt => gymIds.Contains(gt.GymId))
                .GroupBy(gt => gt.GymId)
                .Select(g => new { g.Key, Count = g.Count() })
                .ToDictionaryAsync(g => g.Key, g => g.Count, cancellationToken);

            response.Gyms = gyms.Select(g => new AdminGymSearchDto
            {
                Id = g.Id,
                Name = g.Name,
                City = g.City,
                Address = g.Address,
                WorkHours = g.WorkHours,
                IsActive = g.IsActive,
                MemberCount = memberCounts.TryGetValue(g.Id, out var members) ? members : 0,
                TrainerCount = trainerCounts.TryGetValue(g.Id, out var trainers) ? trainers : 0
            }).ToList();
        }

        if (typeKey is "all" or "members")
        {
            var memberQuery = _dbContext.Users.AsNoTracking()
                .Where(u => u.Role == UserRole.User);

            if (hasQuery)
            {
                var term = normalized!.ToLowerInvariant();
                memberQuery = memberQuery.Where(u =>
                    u.FullName.ToLower().Contains(term) ||
                    u.Email.ToLower().Contains(term) ||
                    (u.PhoneNumber ?? string.Empty).ToLower().Contains(term));
            }

            if (gymId.HasValue)
            {
                var memberIds = _dbContext.Memberships
                    .AsNoTracking()
                    .Where(m => m.GymId == gymId.Value)
                    .Select(m => m.UserId);
                memberQuery = memberQuery.Where(u => memberIds.Contains(u.Id));
            }

            if (!string.IsNullOrWhiteSpace(normalizedStatus)
                && Enum.TryParse<MembershipStatus>(normalizedStatus, true, out var statusFilter))
            {
                var memberIds = _dbContext.Memberships
                    .AsNoTracking()
                    .Where(m => m.Status == statusFilter)
                    .Select(m => m.UserId);
                memberQuery = memberQuery.Where(u => memberIds.Contains(u.Id));
            }

            var members = await memberQuery
                .OrderByDescending(u => u.CreatedAtUtc)
                .Take(MaxResults)
                .ToListAsync(cancellationToken);

            var memberIdsList = members.Select(m => m.Id).ToList();
            var memberships = await _dbContext.Memberships.AsNoTracking()
                .Where(m => memberIdsList.Contains(m.UserId))
                .Include(m => m.Gym)
                .OrderByDescending(m => m.EndDateUtc)
                .ToListAsync(cancellationToken);

            response.Members = members.Select(m => new AdminMemberSearchDto
            {
                Id = m.Id,
                FullName = m.FullName,
                Email = m.Email,
                PhoneNumber = m.PhoneNumber,
                CreatedAtUtc = m.CreatedAtUtc,
                Memberships = memberships
                    .Where(ms => ms.UserId == m.Id)
                    .Select(ms => new AdminMemberGymDto
                    {
                        GymId = ms.GymId,
                        GymName = ms.Gym?.Name ?? string.Empty,
                        Status = ms.Status.ToString(),
                        EndDateUtc = ms.EndDateUtc
                    })
                    .ToList()
            }).ToList();
        }

        if (typeKey is "all" or "trainers")
        {
            var trainerQuery = _dbContext.Trainers.AsNoTracking()
                .Include(t => t.User)
                .AsQueryable();

            if (hasQuery)
            {
                var term = normalized!.ToLowerInvariant();
                trainerQuery = trainerQuery.Where(t => t.User.FullName.ToLower().Contains(term));
            }

            if (normalizedStatus is "active" or "inactive")
            {
                var isActive = normalizedStatus == "active";
                trainerQuery = trainerQuery.Where(t => t.IsActive == isActive);
            }

            if (gymId.HasValue)
            {
                var trainerIds = _dbContext.GymTrainers.AsNoTracking()
                    .Where(gt => gt.GymId == gymId.Value)
                    .Select(gt => gt.TrainerId);
                trainerQuery = trainerQuery.Where(t => trainerIds.Contains(t.Id));
            }

            if (!string.IsNullOrWhiteSpace(normalizedCity))
            {
                var cityTerm = normalizedCity!.ToLowerInvariant();
                var trainerIds = _dbContext.GymTrainers.AsNoTracking()
                    .Where(gt => gt.Gym.City.ToLower().Contains(cityTerm))
                    .Select(gt => gt.TrainerId);
                trainerQuery = trainerQuery.Where(t => trainerIds.Contains(t.Id));
            }

            var trainers = await trainerQuery
                .OrderBy(t => t.User.FullName)
                .Take(MaxResults)
                .ToListAsync(cancellationToken);

            var trainerIdsList = trainers.Select(t => t.Id).ToList();
            var gymNames = await _dbContext.GymTrainers.AsNoTracking()
                .Where(gt => trainerIdsList.Contains(gt.TrainerId))
                .Include(gt => gt.Gym)
                .ToListAsync(cancellationToken);
            var upcomingSessions = await _dbContext.TrainingSessions.AsNoTracking()
                .Where(s => trainerIdsList.Contains(s.TrainerId) && s.StartUtc >= DateTime.UtcNow)
                .GroupBy(s => s.TrainerId)
                .Select(g => new { g.Key, Count = g.Count() })
                .ToDictionaryAsync(g => g.Key, g => g.Count, cancellationToken);

            response.Trainers = trainers.Select(t => new AdminTrainerSearchDto
            {
                Id = t.Id,
                Name = t.User.FullName,
                HourlyRate = t.HourlyRate.HasValue ? (double?)t.HourlyRate.Value : null,
                IsActive = t.IsActive,
                UpcomingSessions = upcomingSessions.TryGetValue(t.Id, out var count) ? count : 0,
                Gyms = gymNames.Where(gt => gt.TrainerId == t.Id).Select(gt => gt.Gym.Name).Distinct().ToList()
            }).ToList();
        }

        return response;
    }
}
