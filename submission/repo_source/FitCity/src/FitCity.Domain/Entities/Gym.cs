namespace FitCity.Domain.Entities;

public class Gym
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? PhoneNumber { get; set; }
    public string? Description { get; set; }
    public string? PhotoUrl { get; set; }
    public string? WorkHours { get; set; }
    public bool IsActive { get; set; } = true;

    public ICollection<GymPlan> Plans { get; set; } = new List<GymPlan>();
    public ICollection<GymPhoto> Photos { get; set; } = new List<GymPhoto>();
    public ICollection<GymTrainer> GymTrainers { get; set; } = new List<GymTrainer>();
    public ICollection<GymAdministrator> Administrators { get; set; } = new List<GymAdministrator>();
    public ICollection<MembershipRequest> MembershipRequests { get; set; } = new List<MembershipRequest>();
    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
    public ICollection<CheckInLog> CheckIns { get; set; } = new List<CheckInLog>();
    public GymQrCode? QrCode { get; set; }
    public ICollection<TrainerSchedule> TrainerSchedules { get; set; } = new List<TrainerSchedule>();
    public ICollection<TrainingSession> TrainingSessions { get; set; } = new List<TrainingSession>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
