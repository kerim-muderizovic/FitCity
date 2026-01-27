using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IReviewService
{
    Task<ReviewDto> CreateAsync(Guid userId, ReviewCreateRequest request, CancellationToken cancellationToken);
    Task<IReadOnlyList<ReviewDto>> GetForTrainerAsync(Guid trainerId, CancellationToken cancellationToken);
}
