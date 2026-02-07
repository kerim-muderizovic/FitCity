using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class AccessLogService : IAccessLogService
{
    private readonly FitCityDbContext _dbContext;

    public AccessLogService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<AccessLogDto>> GetAccessLogsAsync(
        Guid requesterId,
        string requesterRole,
        Guid? gymId,
        DateTime? fromUtc,
        DateTime? toUtc,
        string? status,
        string? query,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase)
            && !string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access access logs.");
        }

        var scopedGymId = gymId;
        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            scopedGymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
        }

        var queryable = _dbContext.CheckInLogs
            .AsNoTracking()
            .Include(c => c.Gym)
            .Include(c => c.User)
            .AsQueryable();

        if (scopedGymId.HasValue)
        {
            queryable = queryable.Where(c => c.GymId == scopedGymId.Value);
        }

        if (fromUtc.HasValue)
        {
            queryable = queryable.Where(c => c.CheckInAtUtc >= fromUtc.Value);
        }

        if (toUtc.HasValue)
        {
            queryable = queryable.Where(c => c.CheckInAtUtc <= toUtc.Value);
        }

        if (!string.IsNullOrWhiteSpace(query))
        {
            var term = query.Trim().ToLower();
            queryable = queryable.Where(c =>
                c.User.FullName.ToLower().Contains(term) ||
                c.User.Email.ToLower().Contains(term));
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            if (status.Equals("denied", StringComparison.OrdinalIgnoreCase))
            {
                queryable = queryable.Where(c => !c.IsSuccessful);
            }
            else if (status.Equals("granted", StringComparison.OrdinalIgnoreCase))
            {
                queryable = queryable.Where(c => c.IsSuccessful);
            }
        }

        var logs = await queryable
            .OrderByDescending(c => c.CheckInAtUtc)
            .Take(200)
            .ToListAsync(cancellationToken);

        return logs.Select(log => new AccessLogDto
        {
            Id = log.Id,
            GymId = log.GymId,
            GymName = log.Gym.Name,
            MemberId = log.UserId,
            MemberName = log.User.FullName,
            Status = log.IsSuccessful ? "Granted" : "Denied",
            Reason = log.IsSuccessful ? "Access granted." : "Access denied.",
            CheckedAtUtc = log.CheckInAtUtc
        }).ToList();
    }

    public async Task<IReadOnlyList<AccessLogDto>> GetMemberEntriesAsync(
        Guid memberId,
        DateTime? fromUtc,
        DateTime? toUtc,
        CancellationToken cancellationToken)
    {
        var queryable = _dbContext.CheckInLogs
            .AsNoTracking()
            .Include(c => c.Gym)
            .Where(c => c.UserId == memberId);

        if (fromUtc.HasValue)
        {
            queryable = queryable.Where(c => c.CheckInAtUtc >= fromUtc.Value);
        }

        if (toUtc.HasValue)
        {
            queryable = queryable.Where(c => c.CheckInAtUtc <= toUtc.Value);
        }

        var logs = await queryable
            .OrderByDescending(c => c.CheckInAtUtc)
            .Take(200)
            .ToListAsync(cancellationToken);

        return logs.Select(log => new AccessLogDto
        {
            Id = log.Id,
            GymId = log.GymId,
            GymName = log.Gym.Name,
            MemberId = log.UserId,
            MemberName = string.Empty,
            Status = log.IsSuccessful ? "Granted" : "Denied",
            Reason = string.IsNullOrWhiteSpace(log.Reason)
                ? (log.IsSuccessful ? "Access granted." : "Access denied.")
                : log.Reason!,
            CheckedAtUtc = log.CheckInAtUtc
        }).ToList();
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
