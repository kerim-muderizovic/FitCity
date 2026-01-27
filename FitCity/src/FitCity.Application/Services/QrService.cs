using System.Security.Cryptography;
using System.Text;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class QrService : IQrService
{
    private readonly FitCityDbContext _dbContext;

    public QrService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<QrIssueResponse?> IssueAsync(
        Guid membershipId,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var membership = await _dbContext.Memberships
            .FirstOrDefaultAsync(m => m.Id == membershipId, cancellationToken);

        if (membership is null || membership.Status != MembershipStatus.Active)
        {
            return null;
        }

        if (string.Equals(requesterRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase)
            && membership.UserId != requesterId)
        {
            throw new InvalidOperationException("Members can only issue their own QR pass.");
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            if (adminGymId != membership.GymId)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }

        if (string.Equals(requesterRole, UserRole.Trainer.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Trainer accounts cannot issue QR passes.");
        }

        var token = Guid.NewGuid().ToString("N");
        var hash = HashToken(token);
        var expiresAt = DateTime.UtcNow.AddHours(12);

        var existing = await _dbContext.QRCodes.FirstOrDefaultAsync(q => q.MembershipId == membershipId, cancellationToken);
        if (existing is null)
        {
            existing = new QRCode
            {
                Id = Guid.NewGuid(),
                MembershipId = membershipId,
                TokenHash = hash,
                ExpiresAtUtc = expiresAt
            };
            _dbContext.QRCodes.Add(existing);
        }
        else
        {
            existing.TokenHash = hash;
            existing.ExpiresAtUtc = expiresAt;
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        return new QrIssueResponse { Token = token, ExpiresAtUtc = expiresAt };
    }

    public async Task<bool> ScanAsync(Guid userId, string requesterRole, QrScanRequest request, CancellationToken cancellationToken)
    {
        var hash = HashToken(request.Token);
        var qr = await _dbContext.QRCodes
            .Include(q => q.Membership)
            .FirstOrDefaultAsync(q => q.TokenHash == hash, cancellationToken);

        if (qr is null || qr.ExpiresAtUtc < DateTime.UtcNow)
        {
            return false;
        }

        var membership = qr.Membership;
        if (membership.Status != MembershipStatus.Active)
        {
            return false;
        }

        if (request.GymId.HasValue && request.GymId.Value != membership.GymId)
        {
            return false;
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(userId, cancellationToken);
            if (adminGymId != membership.GymId)
            {
                return false;
            }
        }

        var log = new CheckInLog
        {
            Id = Guid.NewGuid(),
            GymId = membership.GymId,
            UserId = membership.UserId,
            ScannedByUserId = userId,
            CheckInAtUtc = DateTime.UtcNow
        };

        _dbContext.CheckInLogs.Add(log);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<QrScanResultResponse> ValidateAsync(Guid userId, string userRole, QrScanRequest request, CancellationToken cancellationToken)
    {
        var result = new QrScanResultResponse
        {
            Status = "Denied",
            Reason = "Invalid code.",
            ScannedAtUtc = DateTime.UtcNow
        };

        if (string.IsNullOrWhiteSpace(userRole))
        {
            result.Reason = "User role not available.";
            return result;
        }

        if (string.Equals(userRole, UserRole.Trainer.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            result.Reason = "Trainer accounts cannot validate QR passes.";
            return result;
        }

        var hash = HashToken(request.Token);
        var qr = await _dbContext.QRCodes
            .Include(q => q.Membership)
                .ThenInclude(m => m.Gym)
            .Include(q => q.Membership)
                .ThenInclude(m => m.User)
            .FirstOrDefaultAsync(q => q.TokenHash == hash, cancellationToken);

        if (qr is null)
        {
            return result;
        }

        var membership = qr.Membership;
        result.MembershipId = membership.Id;
        result.MemberId = membership.UserId;
        result.MemberName = membership.User.FullName;
        result.GymId = membership.GymId;
        result.GymName = membership.Gym.Name;

        if (qr.ExpiresAtUtc < DateTime.UtcNow)
        {
            result.Reason = "QR code expired.";
            return result;
        }

        if (membership.Status != MembershipStatus.Active)
        {
            result.Reason = "Membership is not active.";
            return result;
        }

        if (membership.EndDateUtc.Date < DateTime.UtcNow.Date)
        {
            result.Reason = "Membership expired.";
            return result;
        }

        if (request.GymId.HasValue && request.GymId.Value != membership.GymId)
        {
            result.Reason = "QR pass is for a different gym.";
            return result;
        }

        if (string.Equals(userRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(userId, cancellationToken);
            if (adminGymId != membership.GymId)
            {
                result.Reason = "Gym administrator access is limited to their assigned gym.";
                return result;
            }
        }

        if (string.Equals(userRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase)
            && membership.UserId != userId)
        {
            result.Reason = "You cannot validate another member's pass.";
            return result;
        }

        var log = new CheckInLog
        {
            Id = Guid.NewGuid(),
            GymId = membership.GymId,
            UserId = membership.UserId,
            ScannedByUserId = userId,
            CheckInAtUtc = DateTime.UtcNow
        };

        _dbContext.CheckInLogs.Add(log);
        await _dbContext.SaveChangesAsync(cancellationToken);

        result.Status = "Granted";
        result.Reason = "Access granted.";
        return result;
    }

    private static string HashToken(string token)
    {
        using var sha = SHA256.Create();
        var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(token));
        return Convert.ToBase64String(bytes);
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
