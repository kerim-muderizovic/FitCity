namespace FitCity.Domain.Entities;

public class CheckInLog
{
    public Guid Id { get; set; }
    public Guid GymId { get; set; }
    public Guid UserId { get; set; }
    public Guid? ScannedByUserId { get; set; }
    public bool IsSuccessful { get; set; } = true;
    public string? QrPayload { get; set; }
    public string? Reason { get; set; }
    public DateTime CheckInAtUtc { get; set; } = DateTime.UtcNow;

    public Gym Gym { get; set; } = null!;
    public User User { get; set; } = null!;
    public User? ScannedByUser { get; set; }
}
