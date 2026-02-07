namespace FitCity.Domain.Entities;

public class GymQrCode
{
    public Guid Id { get; set; }
    public Guid GymId { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public bool IsActive { get; set; } = true;

    public Gym Gym { get; set; } = null!;
}
