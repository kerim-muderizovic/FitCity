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

    public async Task<QrScanResultResponse> ScanAsync(Guid userId, string requesterRole, QrScanRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(requesterRole))
        {
            throw new InvalidOperationException("User role not available.");
        }

        if (!string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase)
            && !string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can scan QR codes.");
        }

        var result = new QrScanResultResponse
        {
            Status = "Denied",
            Reason = "Invalid code.",
            ScannedAtUtc = DateTime.UtcNow
        };

        var now = DateTime.UtcNow;
        var hash = HashToken(request.Token);
        var qr = await _dbContext.QRCodes
            .Include(q => q.Membership)
                .ThenInclude(m => m.User)
            .Include(q => q.Membership)
                .ThenInclude(m => m.Gym)
            .FirstOrDefaultAsync(q => q.TokenHash == hash, cancellationToken);

        if (qr == null || qr.ExpiresAtUtc < now)
        {
            result.Reason = "QR code is invalid or expired.";
            return result;
        }

        var membership = qr.Membership;
        result.MembershipId = membership.Id;
        result.MemberId = membership.UserId;
        result.MemberName = membership.User.FullName;
        result.GymId = membership.GymId;
        result.GymName = membership.Gym.Name;

        if (membership.Status != MembershipStatus.Active || membership.EndDateUtc.Date < now.Date)
        {
            result.Reason = "Membership is inactive or expired.";
            return result;
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(userId, cancellationToken);
            if (adminGymId != membership.GymId)
            {
                result.Reason = "Gym administrator access is limited to their assigned gym.";
                return result;
            }
        }

        await CreateCheckInAsync(membership.GymId, membership.UserId, userId, request.Token, true, "Access granted.", cancellationToken);
        result.Status = "Granted";
        result.Reason = "Access granted.";
        result.Entered = true;
        return result;
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

        var now = DateTime.UtcNow;
        var hash = HashToken(request.Token);
        var qr = await _dbContext.QRCodes
            .Include(q => q.Membership)
                .ThenInclude(m => m.Gym)
            .Include(q => q.Membership)
                .ThenInclude(m => m.User)
            .FirstOrDefaultAsync(q => q.TokenHash == hash, cancellationToken);

        if (qr != null && qr.ExpiresAtUtc >= now)
        {
            var membership = qr.Membership;
            result.MembershipId = membership.Id;
            result.MemberId = membership.UserId;
            result.MemberName = membership.User.FullName;
            result.GymId = membership.GymId;
            result.GymName = membership.Gym.Name;

            if (membership.Status == MembershipStatus.Active && membership.EndDateUtc.Date >= now.Date)
            {
                if (!request.GymId.HasValue || request.GymId.Value == membership.GymId)
                {
                    if (string.Equals(userRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
                    {
                        var adminGymId = await GetGymIdForAdminAsync(userId, cancellationToken);
                        if (adminGymId != membership.GymId)
                        {
                            result.Reason = "Gym administrator access is limited to their assigned gym.";
                        }
                        else
                        {
                            await CreateCheckInAsync(membership.GymId, membership.UserId, userId, request.Token, true, "Access granted.", cancellationToken);
                            result.Status = "Granted";
                            result.Reason = "Access granted.";
                            result.Entered = true;
                            return result;
                        }
                    }
                    else
                    {
                        await CreateCheckInAsync(membership.GymId, membership.UserId, userId, request.Token, true, "Access granted.", cancellationToken);
                        result.Status = "Granted";
                        result.Reason = "Access granted.";
                        result.Entered = true;
                        return result;
                    }
                }
            }
        }

        var fallbackGymId = await ResolveGymIdAsync(userId, userRole, request.GymId, cancellationToken);
        var scannedByUserId = string.Equals(userRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase)
            ? (Guid?)null
            : userId;
        await CreateCheckInAsync(fallbackGymId, userId, scannedByUserId, request.Token, false, "Entry denied.", cancellationToken);
        result.GymId = fallbackGymId;
        result.Status = "Denied";
        result.Reason = "Entry denied.";
        result.Entered = false;
        return result;
    }

    private static string HashToken(string token)
    {
        using var sha = SHA256.Create();
        var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(token));
        return Convert.ToBase64String(bytes);
    }

    private async Task<Guid> ResolveGymIdAsync(
        Guid requesterId,
        string requesterRole,
        Guid? requestedGymId,
        CancellationToken cancellationToken)
    {
        if (requestedGymId.HasValue)
        {
            return requestedGymId.Value;
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            try
            {
                return await GetGymIdForAdminAsync(requesterId, cancellationToken);
            }
            catch (InvalidOperationException)
            {
                var fallback = await _dbContext.Gyms.AsNoTracking().Select(g => g.Id).FirstOrDefaultAsync(cancellationToken);
                if (fallback != Guid.Empty)
                {
                    return fallback;
                }
            }
        }

        if (string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var fallback = await _dbContext.Gyms.AsNoTracking().Select(g => g.Id).FirstOrDefaultAsync(cancellationToken);
            if (fallback != Guid.Empty)
            {
                return fallback;
            }
        }

        throw new InvalidOperationException("Gym selection is required for this scan.");
    }

    private async Task CreateCheckInAsync(
        Guid gymId,
        Guid userId,
        Guid? scannedByUserId,
        string payload,
        bool isSuccessful,
        string reason,
        CancellationToken cancellationToken)
    {
        var log = new CheckInLog
        {
            Id = Guid.NewGuid(),
            GymId = gymId,
            UserId = userId,
            ScannedByUserId = scannedByUserId,
            QrPayload = payload,
            IsSuccessful = isSuccessful,
            Reason = reason,
            CheckInAtUtc = DateTime.UtcNow
        };

        _dbContext.CheckInLogs.Add(log);
        await _dbContext.SaveChangesAsync(cancellationToken);
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
