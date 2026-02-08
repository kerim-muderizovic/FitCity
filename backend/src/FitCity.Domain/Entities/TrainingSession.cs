using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class TrainingSession
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid TrainerId { get; set; }
    public Guid? GymId { get; set; }
    public DateTime StartUtc { get; set; }
    public DateTime EndUtc { get; set; }
    public TrainingSessionStatus Status { get; set; } = TrainingSessionStatus.Pending;
    public PaymentMethod PaymentMethod { get; set; } = PaymentMethod.Cash;
    public PaymentStatus PaymentStatus { get; set; } = PaymentStatus.Unpaid;
    public decimal Price { get; set; }
    public DateTime? PaidAtUtc { get; set; }

    public User User { get; set; } = null!;
    public Trainer Trainer { get; set; } = null!;
    public Gym? Gym { get; set; }
    public Payment? Payment { get; set; }
}
