using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IAuthService
{
    Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken);
    Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken);
    Task<AuthResponse> LoginCentralAdminAsync(LoginRequest request, CancellationToken cancellationToken);
    Task<AuthResponse> LoginGymAdminAsync(LoginRequest request, CancellationToken cancellationToken);
    Task<AuthResponse> LoginMobileAsync(LoginRequest request, CancellationToken cancellationToken);
    Task<CurrentUserResponse> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken);
    Task ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken cancellationToken);
}
