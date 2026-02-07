using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class GymCreateRequest
{
    [Required, MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(200)]
    public string? Address { get; set; }

    [MaxLength(100)]
    public string? City { get; set; }

    public double? Latitude { get; set; }
    public double? Longitude { get; set; }

    [MaxLength(40)]
    public string? PhoneNumber { get; set; }

    [MaxLength(1000)]
    public string? Description { get; set; }

    [MaxLength(500)]
    public string? PhotoUrl { get; set; }

    [MaxLength(200)]
    public string? WorkHours { get; set; }
}

public class GymUpdateRequest : GymCreateRequest
{
    public bool IsActive { get; set; } = true;
}

public class GymDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? PhoneNumber { get; set; }
    public string? Description { get; set; }
    public string? PhotoUrl { get; set; }
    public string? WorkHours { get; set; }
    public List<string> PhotoUrls { get; set; } = new();
    public bool IsActive { get; set; }
}
