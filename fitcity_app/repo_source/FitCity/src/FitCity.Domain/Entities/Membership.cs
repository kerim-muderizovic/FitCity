using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class Membership
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid GymId { get; set; }
    public Guid? GymPlanId { get; set; }
    public DateTime StartDateUtc { get; set; }
    public DateTime EndDateUtc { get; set; }
    public MembershipStatus Status { get; set; } = MembershipStatus.Active;

    public User User { get; set; } = null!;
    public Gym Gym { get; set; } = null!;
    public GymPlan? GymPlan { get; set; }
    public QRCode? QRCode { get; set; }
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
