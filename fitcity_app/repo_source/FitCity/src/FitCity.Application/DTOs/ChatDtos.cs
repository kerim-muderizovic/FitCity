using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class ConversationCreateRequest
{
    [Required]
    public Guid OtherUserId { get; set; }

    [MaxLength(200)]
    public string? Title { get; set; }
}

public class MessageCreateRequest
{
    [Required]
    public Guid ConversationId { get; set; }

    [Required, MaxLength(2000)]
    public string Content { get; set; } = string.Empty;
}

public class MessageSendRequest
{
    [Required, MaxLength(2000)]
    public string Content { get; set; } = string.Empty;
}

public class ConversationDto
{
    public Guid Id { get; set; }
    public Guid MemberId { get; set; }
    public Guid TrainerId { get; set; }
    public string? Title { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime UpdatedAtUtc { get; set; }
    public DateTime? LastMessageAtUtc { get; set; }
}

public class ConversationSummaryDto
{
    public Guid Id { get; set; }
    public Guid MemberId { get; set; }
    public Guid TrainerId { get; set; }
    public Guid OtherUserId { get; set; }
    public string OtherUserName { get; set; } = string.Empty;
    public string OtherUserRole { get; set; } = string.Empty;
    public string? LastMessage { get; set; }
    public DateTime? LastMessageAtUtc { get; set; }
    public int UnreadCount { get; set; }
}

public class MessageDto
{
    public Guid Id { get; set; }
    public Guid ConversationId { get; set; }
    public Guid SenderUserId { get; set; }
    public string SenderRole { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime SentAtUtc { get; set; }
}
