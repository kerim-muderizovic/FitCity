namespace FitCity.Domain.Entities;

public class PaymentAudit
{
    public Guid Id { get; set; }
    public string EventType { get; set; } = string.Empty;
    public Guid UserId { get; set; }
    public Guid GymId { get; set; }
    public Guid? GymPlanId { get; set; }
    public decimal Amount { get; set; }
    public string Provider { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
