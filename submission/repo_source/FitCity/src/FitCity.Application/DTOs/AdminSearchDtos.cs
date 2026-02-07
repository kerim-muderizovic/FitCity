namespace FitCity.Application.DTOs;

public class AdminGymSearchDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string? WorkHours { get; set; }
    public bool IsActive { get; set; }
    public int MemberCount { get; set; }
    public int TrainerCount { get; set; }
}

public class AdminMemberGymDto
{
    public Guid GymId { get; set; }
    public string GymName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime? EndDateUtc { get; set; }
}

public class AdminMemberSearchDto
{
    public Guid Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public List<AdminMemberGymDto> Memberships { get; set; } = new();
}

public class AdminTrainerSearchDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public double? HourlyRate { get; set; }
    public bool IsActive { get; set; }
    public int UpcomingSessions { get; set; }
    public List<string> Gyms { get; set; } = new();
}

public class AdminSearchResponse
{
    public List<AdminGymSearchDto> Gyms { get; set; } = new();
    public List<AdminMemberSearchDto> Members { get; set; } = new();
    public List<AdminTrainerSearchDto> Trainers { get; set; } = new();
}
