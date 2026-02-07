namespace FitCity.Domain.Entities;

public class GymAdministrator
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid GymId { get; set; }
    public DateTime AssignedAtUtc { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public Gym Gym { get; set; } = null!;
}
