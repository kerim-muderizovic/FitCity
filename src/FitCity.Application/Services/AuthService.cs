using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Application.Options;
using FitCity.Application.Security;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace FitCity.Application.Services;

public class AuthService : IAuthService
{
    private readonly FitCityDbContext _dbContext;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly JwtOptions _jwtOptions;

    public AuthService(FitCityDbContext dbContext, IJwtTokenService jwtTokenService, IOptions<JwtOptions> jwtOptions)
    {
        _dbContext = dbContext;
        _jwtTokenService = jwtTokenService;
        _jwtOptions = jwtOptions.Value;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken)
    {
        var exists = await _dbContext.Users.AnyAsync(u => u.Email == request.Email, cancellationToken);
        if (exists)
        {
            throw new InvalidOperationException("Email already exists.");
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = PasswordHasher.Hash(request.Password),
            Role = UserRole.User,
            CreatedAtUtc = DateTime.UtcNow
        };

        _dbContext.Users.Add(user);

        var hasPreferences = request.TrainingGoals.Count > 0
                             || request.WorkoutTypes.Count > 0
                             || request.FitnessLevel.HasValue
                             || !string.IsNullOrWhiteSpace(request.PreferredGymLocations)
                             || request.PreferredLatitude.HasValue
                             || request.PreferredLongitude.HasValue;

        if (hasPreferences)
        {
            _dbContext.Preferences.Add(new Preference
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                FitnessGoal = request.TrainingGoals.Count > 0 ? request.TrainingGoals[0].ToString() : null,
                TrainingGoals = request.TrainingGoals.ToList(),
                WorkoutTypes = request.WorkoutTypes.ToList(),
                FitnessLevel = request.FitnessLevel,
                PreferredGymLocations = request.PreferredGymLocations,
                PreferredLatitude = request.PreferredLatitude,
                PreferredLongitude = request.PreferredLongitude,
                NotificationsEnabled = true
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        return BuildAuthResponse(user);
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var user = await ValidateCredentialsAsync(request, cancellationToken);
        return BuildAuthResponse(user);
    }

    public async Task<AuthResponse> LoginCentralAdminAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var user = await ValidateCredentialsAsync(request, cancellationToken);
        if (user.Role != UserRole.CentralAdministrator)
        {
            throw new InvalidOperationException("Only Central Administrator accounts can sign in here.");
        }

        return BuildAuthResponse(user);
    }

    public async Task<AuthResponse> LoginGymAdminAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var user = await ValidateCredentialsAsync(request, cancellationToken);
        if (user.Role != UserRole.GymAdministrator)
        {
            throw new InvalidOperationException("Only Gym Administrator accounts can sign in here.");
        }

        return BuildAuthResponse(user);
    }

    public async Task<AuthResponse> LoginMobileAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var user = await ValidateCredentialsAsync(request, cancellationToken);
        if (user.Role is UserRole.CentralAdministrator or UserRole.GymAdministrator)
        {
            throw new InvalidOperationException("Administrator accounts are not allowed to sign in on mobile.");
        }

        return BuildAuthResponse(user);
    }

    public async Task<CurrentUserResponse> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (user is null)
        {
            throw new InvalidOperationException("User not found.");
        }

        return new CurrentUserResponse
        {
            Id = user.Id,
            Email = user.Email,
            FullName = user.FullName,
            PhoneNumber = user.PhoneNumber,
            Role = user.Role.ToString()
        };
    }

    public async Task ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (user is null)
        {
            throw new InvalidOperationException("User not found.");
        }

        if (!PasswordHasher.Verify(request.CurrentPassword, user.PasswordHash))
        {
            throw new InvalidOperationException("Current password is incorrect.");
        }

        if (string.Equals(request.CurrentPassword, request.NewPassword, StringComparison.Ordinal))
        {
            throw new InvalidOperationException("New password must be different from the current password.");
        }

        user.PasswordHash = PasswordHasher.Hash(request.NewPassword);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private AuthResponse BuildAuthResponse(User user)
    {
        var expiresAtUtc = DateTime.UtcNow.AddMinutes(_jwtOptions.ExpirationMinutes);
        return new AuthResponse
        {
            AccessToken = _jwtTokenService.CreateToken(user, expiresAtUtc),
            ExpiresAtUtc = expiresAtUtc
        };
    }

    private async Task<User> ValidateCredentialsAsync(LoginRequest request, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken);
        if (user is null || !PasswordHasher.Verify(request.Password, user.PasswordHash))
        {
            throw new InvalidOperationException("Invalid credentials.");
        }

        return user;
    }
}
