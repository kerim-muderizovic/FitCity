using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class ReviewCreateRequest
{
    [Required]
    public Guid TrainerId { get; set; }

    public Guid? GymId { get; set; }

    [Range(1, 5)]
    public int Rating { get; set; }

    [MaxLength(1000)]
    public string? Comment { get; set; }
}

public class ReviewDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid TrainerId { get; set; }
    public Guid? GymId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
