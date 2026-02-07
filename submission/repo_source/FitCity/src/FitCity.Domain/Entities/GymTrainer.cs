namespace FitCity.Domain.Entities;

public class GymTrainer
{
    public Guid GymId { get; set; }
    public Guid TrainerId { get; set; }
    public DateTime AssignedAtUtc { get; set; } = DateTime.UtcNow;

    public Gym Gym { get; set; } = null!;
    public Trainer Trainer { get; set; } = null!;
}
