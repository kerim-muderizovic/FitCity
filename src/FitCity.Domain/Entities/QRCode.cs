namespace FitCity.Domain.Entities;

public class QRCode
{
    public Guid Id { get; set; }
    public Guid MembershipId { get; set; }
    public string TokenHash { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }

    public Membership Membership { get; set; } = null!;
}
