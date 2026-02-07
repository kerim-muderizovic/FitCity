using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IGymQrService
{
    Task<GymQrDto> GetGymQrAsync(Guid gymId, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
}
