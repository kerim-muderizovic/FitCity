using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class UserTrainerInteraction
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid TrainerId { get; set; }
    public UserTrainerInteractionType Type { get; set; }
    public int Weight { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public Trainer Trainer { get; set; } = null!;
}
