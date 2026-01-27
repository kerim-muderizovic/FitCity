namespace FitCity.Domain.Entities;

public class GymPlan
{
    public Guid Id { get; set; }
    public Guid GymId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationMonths { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    public Gym Gym { get; set; } = null!;
    public ICollection<MembershipRequest> MembershipRequests { get; set; } = new List<MembershipRequest>();
    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
}
