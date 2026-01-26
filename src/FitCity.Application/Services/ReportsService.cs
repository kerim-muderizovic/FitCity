using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class ReportsService : IReportsService
{
    private readonly FitCityDbContext _dbContext;

    public ReportsService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<MonthlyCountDto>> MembershipsPerMonthAsync(
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var query = _dbContext.Memberships.AsNoTracking();

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            query = query.Where(m => m.GymId == gymId);
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access reports.");
        }

        var results = await query
            .GroupBy(m => new { m.StartDateUtc.Year, m.StartDateUtc.Month })
            .Select(g => new MonthlyCountDto
            {
                Year = g.Key.Year,
                Month = g.Key.Month,
                Count = g.Count()
            })
            .OrderBy(x => x.Year).ThenBy(x => x.Month)
            .ToListAsync(cancellationToken);

        return results;
    }

    public async Task<IReadOnlyList<TopTrainerDto>> TopTrainersByBookingsAsync(
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var query = _dbContext.TrainingSessions.AsNoTracking();

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            query = query.Where(s => s.GymId == gymId);
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access reports.");
        }

        var results = await query
            .GroupBy(s => s.TrainerId)
            .Select(g => new { g.Key, Count = g.Count() })
            .OrderByDescending(x => x.Count)
            .Take(5)
            .ToListAsync(cancellationToken);

        var trainerIds = results.Select(r => r.Key).ToList();
        var trainerNames = await _dbContext.Trainers
            .AsNoTracking()
            .Where(t => trainerIds.Contains(t.Id))
            .Include(t => t.User)
            .ToDictionaryAsync(t => t.Id, t => t.User.FullName, cancellationToken);

        return results.Select(r => new TopTrainerDto
        {
            TrainerId = r.Key,
            TrainerName = trainerNames.TryGetValue(r.Key, out var name) ? name : string.Empty,
            BookingCount = r.Count
        }).ToList();
    }

    public async Task<IReadOnlyList<MonthlyRevenueDto>> RevenueByMonthAsync(
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var query = _dbContext.Payments.AsNoTracking();

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            query = query.Where(p =>
                (p.Membership != null && p.Membership.GymId == gymId) ||
                (p.TrainingSession != null && p.TrainingSession.GymId == gymId));
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access reports.");
        }

        var results = await query
            .GroupBy(p => new { p.PaidAtUtc.Year, p.PaidAtUtc.Month })
            .Select(g => new MonthlyRevenueDto
            {
                Year = g.Key.Year,
                Month = g.Key.Month,
                Revenue = g.Sum(p => p.Amount)
            })
            .OrderBy(x => x.Year).ThenBy(x => x.Month)
            .ToListAsync(cancellationToken);

        return results;
    }

    private async Task<Guid> GetGymIdForAdminAsync(Guid adminUserId, CancellationToken cancellationToken)
    {
        var admin = await _dbContext.GymAdministrators
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.UserId == adminUserId, cancellationToken);

        if (admin is null)
        {
            throw new InvalidOperationException("Gym administrator is not assigned to a gym.");
        }

        return admin.GymId;
    }
}
