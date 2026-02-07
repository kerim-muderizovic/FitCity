namespace FitCity.Domain.Entities;

public class Conversation
{
    public Guid Id { get; set; }
    public Guid MemberId { get; set; }
    public Guid TrainerId { get; set; }
    public string? Title { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? LastMessageAtUtc { get; set; }

    public ICollection<ConversationParticipant> Participants { get; set; } = new List<ConversationParticipant>();
    public ICollection<Message> Messages { get; set; } = new List<Message>();

    public User Member { get; set; } = null!;
    public User Trainer { get; set; } = null!;
}
