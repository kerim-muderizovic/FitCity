namespace FitCity.Domain.Entities;

public class ConversationParticipant
{
    public Guid Id { get; set; }
    public Guid ConversationId { get; set; }
    public Guid UserId { get; set; }
    public DateTime JoinedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? LastReadAtUtc { get; set; }

    public Conversation Conversation { get; set; } = null!;
    public User User { get; set; } = null!;
}
