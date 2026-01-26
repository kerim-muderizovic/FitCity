namespace FitCity.Domain.Entities;

public class TrainerSchedule
{
    public Guid Id { get; set; }
    public Guid TrainerId { get; set; }
    public Guid? GymId { get; set; }
    public DateTime StartUtc { get; set; }
    public DateTime EndUtc { get; set; }
    public bool IsAvailable { get; set; } = true;

    public Trainer Trainer { get; set; } = null!;
    public Gym? Gym { get; set; }
}
