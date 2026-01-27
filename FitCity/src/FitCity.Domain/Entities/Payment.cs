using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class Payment
{
    public Guid Id { get; set; }
    public decimal Amount { get; set; }
    public PaymentMethod Method { get; set; } = PaymentMethod.Card;
    public DateTime PaidAtUtc { get; set; } = DateTime.UtcNow;
    public Guid? MembershipId { get; set; }
    public Guid? TrainingSessionId { get; set; }

    public Membership? Membership { get; set; }
    public TrainingSession? TrainingSession { get; set; }
}
