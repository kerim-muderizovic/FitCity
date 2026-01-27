using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IProfileService
{
    Task<CurrentUserResponse> UpdateProfileAsync(Guid userId, ProfileUpdateRequest request, CancellationToken cancellationToken);
}
