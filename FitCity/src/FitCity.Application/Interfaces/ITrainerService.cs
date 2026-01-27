using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface ITrainerService
{
    Task<TrainerDto> CreateAsync(TrainerCreateRequest request, CancellationToken cancellationToken);
    Task<IReadOnlyList<TrainerDto>> GetAllAsync(string? search, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<IReadOnlyList<TrainerDto>> GetByGymAsync(Guid gymId, CancellationToken cancellationToken);
    Task<TrainerDto?> GetByIdAsync(Guid trainerId, CancellationToken cancellationToken);
    Task<TrainerDetailDto?> GetDetailAsync(Guid trainerId, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<TrainerDetailDto?> GetPublicDetailAsync(Guid trainerId, CancellationToken cancellationToken);
    Task<TrainerScheduleResponseDto> GetMyScheduleAsync(Guid userId, CancellationToken cancellationToken);
    Task<TrainerScheduleResponseDto> GetAvailabilityAsync(Guid trainerId, DateTime fromUtc, DateTime toUtc, CancellationToken cancellationToken);
}
