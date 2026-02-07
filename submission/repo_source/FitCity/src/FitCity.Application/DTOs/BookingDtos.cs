using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class BookingCreateRequest
{
    [Required]
    public Guid TrainerId { get; set; }

    public Guid? GymId { get; set; }

    [Required]
    public DateTime StartUtc { get; set; }

    [Required]
    public DateTime EndUtc { get; set; }

    public string? PaymentMethod { get; set; }
}

public class BookingStatusUpdate
{
    [Required]
    public bool Confirm { get; set; }
}

public class BookingDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid TrainerId { get; set; }
    public Guid TrainerUserId { get; set; }
    public string TrainerName { get; set; } = string.Empty;
    public Guid? GymId { get; set; }
    public string? GymName { get; set; }
    public DateTime StartUtc { get; set; }
    public DateTime EndUtc { get; set; }
    public string Status { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
    public string PaymentStatus { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public DateTime? PaidAtUtc { get; set; }
}
