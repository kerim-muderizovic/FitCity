using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class EntryService : IEntryService
{
    private readonly FitCityDbContext _dbContext;

    public EntryService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<QrScanResultResponse> ValidateAsync(
        Guid requesterId,
        string requesterRole,
        EntryValidateRequest request,
        CancellationToken cancellationToken)
    {
        var payload = request.Payload?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(payload))
        {
            return Denied("Invalid code.");
        }

        if (TryParseMemberPayload(payload, out var memberToken, out var memberPayloadError))
        {
            return await ValidateMembershipQrAsync(requesterId, requesterRole, memberToken, cancellationToken);
        }
        if (!string.IsNullOrWhiteSpace(memberPayloadError))
        {
            throw new InvalidOperationException(memberPayloadError);
        }

        var parsed = TryParseEntryPayload(payload, out var gymId, out var token);
        if (parsed)
        {
            if (!string.Equals(requesterRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase)
                && !request.MemberId.HasValue)
            {
                throw new InvalidOperationException("This is a gym/entry QR. Scan a member QR.");
            }
            return await ValidateGymQrAsync(requesterId, requesterRole, request.MemberId, gymId, token, payload, cancellationToken);
        }

        return await ValidateMembershipQrAsync(requesterId, requesterRole, payload, cancellationToken);
    }

    private async Task<QrScanResultResponse> ValidateGymQrAsync(
        Guid requesterId,
        string requesterRole,
        Guid? memberIdOverride,
        Guid gymId,
        string token,
        string payload,
        CancellationToken cancellationToken)
    {
        var memberId = requesterId;
        if (!string.Equals(requesterRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            if (!memberIdOverride.HasValue)
            {
                return Denied("Member QR is required for gym entry codes.", gymId: gymId);
            }
            memberId = memberIdOverride.Value;
        }

        var qr = await _dbContext.GymQrCodes
            .AsNoTracking()
            .FirstOrDefaultAsync(q => q.GymId == gymId && q.IsActive, cancellationToken);

        var scannedByUserId = string.Equals(requesterRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase)
            ? (Guid?)null
            : requesterId;

        if (qr == null || !string.Equals(qr.Token, token, StringComparison.Ordinal))
        {
            const string reason = "QR code is invalid or inactive.";
            await CreateCheckInAsync(gymId, memberId, scannedByUserId, payload, false, reason, cancellationToken);
            return Denied(reason, gymId: gymId, memberId: memberId);
        }

        var membership = await _dbContext.Memberships
            .AsNoTracking()
            .FirstOrDefaultAsync(m =>
                m.UserId == memberId &&
                m.GymId == gymId &&
                m.Status == MembershipStatus.Active &&
                m.EndDateUtc.Date >= DateTime.UtcNow.Date, cancellationToken);

        if (membership == null)
        {
            const string reason = "No active membership for this gym.";
            await CreateCheckInAsync(gymId, memberId, scannedByUserId, payload, false, reason, cancellationToken);
            return Denied(reason, gymId: gymId, memberId: memberId);
        }

        await CreateCheckInAsync(gymId, memberId, scannedByUserId, payload, true, "Access granted.", cancellationToken);
        return Granted(gymId, memberId, membership.Id);
    }

    private async Task<QrScanResultResponse> ValidateMembershipQrAsync(
        Guid requesterId,
        string requesterRole,
        string token,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase)
            && !string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            return Denied("Only administrators can scan membership QR codes.");
        }

        var now = DateTime.UtcNow;
        var hash = HashToken(token);
        var qr = await _dbContext.QRCodes
            .Include(q => q.Membership)
                .ThenInclude(m => m.User)
            .Include(q => q.Membership)
                .ThenInclude(m => m.Gym)
            .FirstOrDefaultAsync(q => q.TokenHash == hash, cancellationToken);

        if (qr == null || qr.ExpiresAtUtc < now)
        {
            return Denied("QR code is invalid or expired.");
        }

        var membership = qr.Membership;
        if (membership.Status != MembershipStatus.Active || membership.EndDateUtc.Date < now.Date)
        {
            const string reason = "Membership is inactive or expired.";
            await CreateCheckInAsync(membership.GymId, membership.UserId, requesterId, token, false, reason, cancellationToken);
            return Denied(reason, membership.GymId, membership.UserId, membership.Id);
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            if (adminGymId != membership.GymId)
            {
                const string reason = "Gym administrator access is limited to their assigned gym.";
                await CreateCheckInAsync(membership.GymId, membership.UserId, requesterId, token, false, reason, cancellationToken);
                return Denied(reason, membership.GymId, membership.UserId, membership.Id);
            }
        }

        await CreateCheckInAsync(membership.GymId, membership.UserId, requesterId, token, true, "Access granted.", cancellationToken);
        return Granted(membership.GymId, membership.UserId, membership.Id, membership.User.FullName, membership.Gym.Name);
    }

    private static bool TryParseEntryPayload(string payload, out Guid gymId, out string token)
    {
        gymId = Guid.Empty;
        token = string.Empty;

        if (!Uri.TryCreate(payload, UriKind.Absolute, out var uri))
        {
            return false;
        }

        if (!string.Equals(uri.Scheme, "fitcity", StringComparison.OrdinalIgnoreCase) ||
            !string.Equals(uri.Host, "entry", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var query = ParseQuery(uri.Query);
        query.TryGetValue("gymId", out var gymIdValue);
        query.TryGetValue("token", out var tokenValue);
        if (!Guid.TryParse(gymIdValue, out gymId) || string.IsNullOrWhiteSpace(tokenValue))
        {
            return false;
        }

        token = tokenValue;
        return true;
    }

    private static bool TryParseMemberPayload(string payload, out string token, out string? error)
    {
        token = string.Empty;
        error = null;
        if (!payload.StartsWith("fitcity://", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        if (!Uri.TryCreate(payload, UriKind.Absolute, out var uri))
        {
            error = "Invalid member QR format.";
            return false;
        }

        if (!string.Equals(uri.Host, "member", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var query = ParseQuery(uri.Query);
        query.TryGetValue("token", out var tokenValue);
        if (string.IsNullOrWhiteSpace(tokenValue))
        {
            error = "Member QR token missing.";
            return false;
        }

        token = tokenValue;
        return true;
    }

    private static Dictionary<string, string> ParseQuery(string query)
    {
        var result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (string.IsNullOrWhiteSpace(query))
        {
            return result;
        }

        var trimmed = query.StartsWith("?") ? query[1..] : query;
        var parts = trimmed.Split('&', StringSplitOptions.RemoveEmptyEntries);
        foreach (var part in parts)
        {
            var kv = part.Split('=', 2);
            if (kv.Length == 0)
            {
                continue;
            }
            var key = Uri.UnescapeDataString(kv[0]);
            var value = kv.Length > 1 ? Uri.UnescapeDataString(kv[1]) : string.Empty;
            if (!string.IsNullOrWhiteSpace(key))
            {
                result[key] = value;
            }
        }

        return result;
    }

    private static string HashToken(string token)
    {
        using var sha = System.Security.Cryptography.SHA256.Create();
        var bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(token));
        return Convert.ToBase64String(bytes);
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

    private QrScanResultResponse Granted(
        Guid gymId,
        Guid memberId,
        Guid? membershipId = null,
        string? memberName = null,
        string? gymName = null)
    {
        return new QrScanResultResponse
        {
            Status = "Granted",
            Reason = "Access granted.",
            Entered = true,
            GymId = gymId,
            GymName = gymName,
            MemberId = memberId,
            MemberName = memberName,
            MembershipId = membershipId,
            ScannedAtUtc = DateTime.UtcNow
        };
    }

    private QrScanResultResponse Denied(
        string reason,
        Guid? gymId = null,
        Guid? memberId = null,
        Guid? membershipId = null)
    {
        return new QrScanResultResponse
        {
            Status = "Denied",
            Reason = reason,
            Entered = false,
            GymId = gymId,
            MemberId = memberId,
            MembershipId = membershipId,
            ScannedAtUtc = DateTime.UtcNow
        };
    }
}
