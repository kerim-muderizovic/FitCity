using System.ComponentModel.DataAnnotations;
using FitCity.Domain.Enums;

namespace FitCity.Application.DTOs;

public class TrainerCreateRequest
{
    [Required]
    public Guid UserId { get; set; }

    [MaxLength(1000)]
    public string? Bio { get; set; }

    [MaxLength(500)]
    public string? Certifications { get; set; }

    [MaxLength(500)]
    public string? PhotoUrl { get; set; }

    public decimal? HourlyRate { get; set; }

    public List<TrainerSpecialty> Specialties { get; set; } = new();
    public List<TrainerStyle> Styles { get; set; } = new();
    public List<FitnessLevel> SupportedFitnessLevels { get; set; } = new();
}

public class GymAdminTrainerCreateRequest
{
    [Required, EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required, MinLength(2), MaxLength(120)]
    public string FullName { get; set; } = string.Empty;

    [Required, MinLength(6), MaxLength(128)]
    public string Password { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Bio { get; set; }

    [MaxLength(500)]
    public string? PhotoUrl { get; set; }

    [Required, Range(1, 10000)]
    public decimal? HourlyRate { get; set; }
}

public class TrainerDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string? Bio { get; set; }
    public string? Certifications { get; set; }
    public string? PhotoUrl { get; set; }
    [Required, Range(1, 10000)]
    public decimal? HourlyRate { get; set; }
    public List<TrainerSpecialty> Specialties { get; set; } = new();
    public List<TrainerStyle> Styles { get; set; } = new();
    public List<FitnessLevel> SupportedFitnessLevels { get; set; } = new();
    public bool IsActive { get; set; }
    public string UserName { get; set; } = string.Empty;
}

public class TrainerScheduleResponseDto
{
    public List<TrainerScheduleDto> Schedules { get; set; } = new();
    public List<BookingDto> Sessions { get; set; } = new();
    public string? Reason { get; set; }
    public string? ScheduleUsed { get; set; }
}
