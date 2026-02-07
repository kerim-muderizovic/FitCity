using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IGymService
{
    Task<GymDto> CreateAsync(GymCreateRequest request, CancellationToken cancellationToken);
    Task<GymDto?> UpdateAsync(Guid id, GymUpdateRequest request, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken);
    Task<IReadOnlyList<GymDto>> GetAllAsync(string? search, CancellationToken cancellationToken);
    Task<GymDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<GymDto?> GetForAdminAsync(Guid adminUserId, CancellationToken cancellationToken);
}
