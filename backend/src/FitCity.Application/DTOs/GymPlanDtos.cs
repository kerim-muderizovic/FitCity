using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class GymPlanDto
{
    public Guid Id { get; set; }
    public Guid GymId { get; set; }
    public string GymName { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationMonths { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}

public class GymPlanCreateRequest
{
    [Required]
    public Guid GymId { get; set; }

    [Required, MaxLength(150)]
    public string Name { get; set; } = string.Empty;

    [Range(0, 10000)]
    public decimal Price { get; set; }

    [Range(1, 36)]
    public int DurationMonths { get; set; }

    [MaxLength(1000)]
    public string? Description { get; set; }

    public bool IsActive { get; set; } = true;
}

public class GymPlanUpdateRequest : GymPlanCreateRequest
{
}
