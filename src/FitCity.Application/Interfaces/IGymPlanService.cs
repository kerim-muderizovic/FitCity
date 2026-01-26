using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IGymPlanService
{
    Task<IReadOnlyList<GymPlanDto>> GetAllAsync(Guid? gymId, string? query, CancellationToken cancellationToken);
    Task<GymPlanDto> CreateAsync(GymPlanCreateRequest request, CancellationToken cancellationToken);
    Task<GymPlanDto?> UpdateAsync(Guid id, GymPlanUpdateRequest request, CancellationToken cancellationToken);
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken);
}
