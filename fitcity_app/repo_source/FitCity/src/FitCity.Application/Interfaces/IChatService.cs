using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IChatService
{
    Task<ConversationDto> CreateConversationAsync(Guid userId, ConversationCreateRequest request, CancellationToken cancellationToken);
    Task<IReadOnlyList<ConversationSummaryDto>> GetMyConversationsAsync(Guid userId, CancellationToken cancellationToken);
    Task<IReadOnlyList<MessageDto>> GetMessagesAsync(Guid userId, Guid conversationId, DateTime? beforeUtc, int take, CancellationToken cancellationToken);
    Task<MessageDto> SendMessageAsync(Guid userId, MessageCreateRequest request, CancellationToken cancellationToken);
    Task<int> MarkConversationReadAsync(Guid userId, Guid conversationId, CancellationToken cancellationToken);
}
