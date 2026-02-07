namespace FitCity.Domain.Entities;

public class CentralAdministrator
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public DateTime AssignedAtUtc { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
}
