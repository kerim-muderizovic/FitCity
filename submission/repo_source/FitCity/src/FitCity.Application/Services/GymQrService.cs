using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class GymQrService : IGymQrService
{
    private readonly FitCityDbContext _dbContext;

    public GymQrService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<GymQrDto> GetGymQrAsync(
        Guid gymId,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            if (adminGymId != gymId)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access gym QR codes.");
        }

        var gym = await _dbContext.Gyms.AsNoTracking().FirstOrDefaultAsync(g => g.Id == gymId, cancellationToken);
        if (gym is null)
        {
            throw new InvalidOperationException("Gym not found.");
        }

        var qr = await _dbContext.GymQrCodes.FirstOrDefaultAsync(q => q.GymId == gymId, cancellationToken);
        if (qr is null)
        {
            qr = new GymQrCode
            {
                Id = Guid.NewGuid(),
                GymId = gymId,
                Token = Guid.NewGuid().ToString("N"),
                CreatedAtUtc = DateTime.UtcNow,
                IsActive = true
            };
            _dbContext.GymQrCodes.Add(qr);
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        var payload = $"fitcity://entry?gymId={gymId}&token={qr.Token}";
        return new GymQrDto
        {
            GymId = gymId,
            GymName = gym.Name,
            Payload = payload
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
