using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class MembershipRequest
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid GymId { get; set; }
    public Guid? GymPlanId { get; set; }
    public MembershipRequestStatus Status { get; set; } = MembershipRequestStatus.Pending;
    public DateTime? ApprovedAtUtc { get; set; }
    public Guid? ApprovedByUserId { get; set; }
    public PaymentStatus PaymentStatus { get; set; } = PaymentStatus.Unpaid;
    public DateTime? PaidAtUtc { get; set; }
    public Guid? PaymentId { get; set; }
    public DateTime RequestedAtUtc { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public Gym Gym { get; set; } = null!;
    public GymPlan? GymPlan { get; set; }
}
