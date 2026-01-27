namespace FitCity.Application.DTOs;

public class AccessLogDto
{
    public Guid Id { get; set; }
    public Guid GymId { get; set; }
    public string GymName { get; set; } = string.Empty;
    public Guid MemberId { get; set; }
    public string MemberName { get; set; } = string.Empty;
    public string Status { get; set; } = "Granted";
    public string Reason { get; set; } = "Access granted.";
    public DateTime CheckedAtUtc { get; set; }
}

public class MemberDetailDto
{
    public MemberDto Member { get; set; } = new();
    public List<MembershipDto> Memberships { get; set; } = new();
    public List<BookingDto> Bookings { get; set; } = new();
    public string QrStatus { get; set; } = "None";
    public DateTime? QrExpiresAtUtc { get; set; }
    public DateTime? LastAccessAtUtc { get; set; }
    public string? LastAccessGymName { get; set; }
}

public class TrainerScheduleDto
{
    public Guid Id { get; set; }
    public Guid TrainerId { get; set; }
    public Guid? GymId { get; set; }
    public DateTime StartUtc { get; set; }
    public DateTime EndUtc { get; set; }
    public bool IsAvailable { get; set; }
}

public class TrainerDetailDto
{
    public TrainerDto Trainer { get; set; } = new();
    public List<GymDto> Gyms { get; set; } = new();
    public List<TrainerScheduleDto> Schedules { get; set; } = new();
    public List<BookingDto> Sessions { get; set; } = new();
}
