using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IRecommendationService
{
    Task<IReadOnlyList<RecommendedTrainerDto>> RecommendTrainersForUserAsync(Guid userId, int limit, CancellationToken cancellationToken);
    Task<IReadOnlyList<RecommendedGymDto>> RecommendGymsForUserAsync(Guid userId, int limit, CancellationToken cancellationToken);
}
