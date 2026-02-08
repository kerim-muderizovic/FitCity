using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IAdminSearchService
{
    Task<AdminSearchResponse> SearchAsync(
        string? query,
        string? type,
        Guid? gymId,
        string? city,
        string? status,
        CancellationToken cancellationToken);
}
