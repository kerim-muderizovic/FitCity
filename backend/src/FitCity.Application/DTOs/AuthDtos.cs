using System.ComponentModel.DataAnnotations;
using FitCity.Domain.Enums;

namespace FitCity.Application.DTOs;

public class RegisterRequest
{
    [Required, EmailAddress, MaxLength(200)]
    public string Email { get; set; } = string.Empty;

    [Required, MinLength(6), MaxLength(100)]
    public string Password { get; set; } = string.Empty;

    [Required, MaxLength(200)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(40)]
    public string? PhoneNumber { get; set; }

    public List<TrainingGoal> TrainingGoals { get; set; } = new();
    public List<WorkoutType> WorkoutTypes { get; set; } = new();
    public FitnessLevel? FitnessLevel { get; set; }

    [MaxLength(300)]
    public string? PreferredGymLocations { get; set; }

    public double? PreferredLatitude { get; set; }
    public double? PreferredLongitude { get; set; }
}

public class LoginRequest
{
    [Required, EmailAddress, MaxLength(200)]
    public string Email { get; set; } = string.Empty;

    [Required, MinLength(6), MaxLength(100)]
    public string Password { get; set; } = string.Empty;
}

public class AuthResponse
{
    public string AccessToken { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
}

public class CurrentUserResponse
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public string? PhotoUrl { get; set; }
    public string Role { get; set; } = string.Empty;
}

public class ProfileUpdateRequest
{
    [Required, MaxLength(200)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(40)]
    public string? PhoneNumber { get; set; }

    [EmailAddress, MaxLength(200)]
    public string? Email { get; set; }
}

public class ChangePasswordRequest
{
    [Required, MinLength(6), MaxLength(100)]
    public string CurrentPassword { get; set; } = string.Empty;

    [Required, MinLength(6), MaxLength(100)]
    public string NewPassword { get; set; } = string.Empty;
}
