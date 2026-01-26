using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public UserRole Role { get; set; } = UserRole.User;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public Preference? Preference { get; set; }
    public Trainer? TrainerProfile { get; set; }
    public GymAdministrator? GymAdministratorProfile { get; set; }
    public CentralAdministrator? CentralAdministratorProfile { get; set; }

    public ICollection<MembershipRequest> MembershipRequests { get; set; } = new List<MembershipRequest>();
    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
    public ICollection<CheckInLog> CheckIns { get; set; } = new List<CheckInLog>();
    public ICollection<CheckInLog> ScannedCheckIns { get; set; } = new List<CheckInLog>();
    public ICollection<TrainingSession> TrainingSessions { get; set; } = new List<TrainingSession>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
    public ICollection<ConversationParticipant> Conversations { get; set; } = new List<ConversationParticipant>();
    public ICollection<Message> Messages { get; set; } = new List<Message>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
}
