using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Application.Security;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class MemberService : IMemberService
{
    private readonly FitCityDbContext _dbContext;

    public MemberService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<MemberDto>> GetMembersAsync(Guid requesterId, string requesterRole, CancellationToken cancellationToken)
    {
        var query = _dbContext.Users.AsNoTracking()
            .Where(u => u.Role == UserRole.User);

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            var membershipIds = _dbContext.Memberships
                .AsNoTracking()
                .Where(m => m.GymId == gymId)
                .Select(m => m.UserId);
            var requestIds = _dbContext.MembershipRequests
                .AsNoTracking()
                .Where(r => r.GymId == gymId)
                .Select(r => r.UserId);
            var memberIds = membershipIds.Concat(requestIds).Distinct();
            query = query.Where(u => memberIds.Contains(u.Id));
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access members.");
        }

        return await query
            .OrderByDescending(u => u.CreatedAtUtc)
            .Select(u => new MemberDto
            {
                Id = u.Id,
                Email = u.Email,
                FullName = u.FullName,
                PhoneNumber = u.PhoneNumber,
                CreatedAtUtc = u.CreatedAtUtc
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<MemberDto> CreateMemberAsync(MemberCreateRequest request, CancellationToken cancellationToken)
    {
        var exists = await _dbContext.Users.AnyAsync(u => u.Email == request.Email, cancellationToken);
        if (exists)
        {
            throw new InvalidOperationException("Email already exists.");
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = PasswordHasher.Hash(request.Password),
            Role = UserRole.User,
            CreatedAtUtc = DateTime.UtcNow
        };

        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new MemberDto
        {
            Id = user.Id,
            Email = user.Email,
            FullName = user.FullName,
            PhoneNumber = user.PhoneNumber,
            CreatedAtUtc = user.CreatedAtUtc
        };
    }

    public async Task<bool> DeleteMemberAsync(Guid memberId, Guid requesterId, string requesterRole, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == memberId, cancellationToken);
        if (user is null)
        {
            return false;
        }

        if (user.Role != UserRole.User)
        {
            throw new InvalidOperationException("Only member accounts can be deleted.");
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            var belongsToGym = await _dbContext.Memberships
                .AsNoTracking()
                .AnyAsync(m => m.UserId == memberId && m.GymId == gymId, cancellationToken);
            var hasRequest = await _dbContext.MembershipRequests
                .AsNoTracking()
                .AnyAsync(m => m.UserId == memberId && m.GymId == gymId, cancellationToken);

            if (!belongsToGym && !hasRequest)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }

        var hasDependencies = await _dbContext.Memberships.AnyAsync(m => m.UserId == memberId, cancellationToken)
            || await _dbContext.MembershipRequests.AnyAsync(m => m.UserId == memberId, cancellationToken)
            || await _dbContext.TrainingSessions.AnyAsync(s => s.UserId == memberId, cancellationToken)
            || await _dbContext.Reviews.AnyAsync(r => r.UserId == memberId, cancellationToken)
            || await _dbContext.Messages.AnyAsync(m => m.SenderUserId == memberId, cancellationToken)
            || await _dbContext.ConversationParticipants.AnyAsync(p => p.UserId == memberId, cancellationToken)
            || await _dbContext.CheckInLogs.AnyAsync(c => c.UserId == memberId || c.ScannedByUserId == memberId, cancellationToken);

        if (hasDependencies)
        {
            throw new InvalidOperationException("Member has related records and cannot be deleted.");
        }

        _dbContext.Users.Remove(user);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<MemberDetailDto?> GetMemberDetailAsync(
        Guid memberId,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == memberId, cancellationToken);

        if (user is null)
        {
            return null;
        }

        if (user.Role != UserRole.User)
        {
            throw new InvalidOperationException("Only member accounts are available here.");
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            var hasMembership = await _dbContext.Memberships
                .AsNoTracking()
                .AnyAsync(m => m.UserId == memberId && m.GymId == gymId, cancellationToken);
            var hasRequest = await _dbContext.MembershipRequests
                .AsNoTracking()
                .AnyAsync(m => m.UserId == memberId && m.GymId == gymId, cancellationToken);

            if (!hasMembership && !hasRequest)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access member details.");
        }

        var memberships = await _dbContext.Memberships
            .AsNoTracking()
            .Where(m => m.UserId == memberId)
            .OrderByDescending(m => m.EndDateUtc)
            .ToListAsync(cancellationToken);

        var bookings = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => s.UserId == memberId)
            .Include(s => s.Trainer)
                .ThenInclude(t => t.User)
            .Include(s => s.Gym)
            .OrderByDescending(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        var latestQr = await _dbContext.QRCodes
            .AsNoTracking()
            .Where(q => memberships.Select(m => m.Id).Contains(q.MembershipId))
            .OrderByDescending(q => q.ExpiresAtUtc)
            .FirstOrDefaultAsync(cancellationToken);

        var lastAccess = await _dbContext.CheckInLogs
            .AsNoTracking()
            .Where(c => c.UserId == memberId)
            .OrderByDescending(c => c.CheckInAtUtc)
            .Select(c => new { c.CheckInAtUtc, GymName = c.Gym.Name })
            .FirstOrDefaultAsync(cancellationToken);

        var qrStatus = "None";
        if (latestQr != null)
        {
            qrStatus = latestQr.ExpiresAtUtc >= DateTime.UtcNow ? "Active" : "Expired";
        }

        return new MemberDetailDto
        {
            Member = new MemberDto
            {
                Id = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                PhoneNumber = user.PhoneNumber,
                CreatedAtUtc = user.CreatedAtUtc
            },
            Memberships = memberships.Select(m => new MembershipDto
            {
                Id = m.Id,
                UserId = m.UserId,
                GymId = m.GymId,
                GymPlanId = m.GymPlanId,
                StartDateUtc = m.StartDateUtc,
                EndDateUtc = m.EndDateUtc,
                Status = m.Status.ToString()
            }).ToList(),
            Bookings = bookings.Select(s => new BookingDto
            {
                Id = s.Id,
                UserId = s.UserId,
                TrainerId = s.TrainerId,
                TrainerUserId = s.Trainer.UserId,
                TrainerName = s.Trainer.User.FullName,
                GymId = s.GymId,
                GymName = s.Gym?.Name,
                StartUtc = s.StartUtc,
                EndUtc = s.EndUtc,
                Status = s.Status.ToString(),
                PaymentMethod = s.PaymentMethod.ToString(),
                PaymentStatus = s.PaymentStatus.ToString(),
                Price = s.Price,
                PaidAtUtc = s.PaidAtUtc
            }).ToList(),
            QrStatus = qrStatus,
            QrExpiresAtUtc = latestQr?.ExpiresAtUtc,
            LastAccessAtUtc = lastAccess?.CheckInAtUtc,
            LastAccessGymName = lastAccess?.GymName
        };
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
