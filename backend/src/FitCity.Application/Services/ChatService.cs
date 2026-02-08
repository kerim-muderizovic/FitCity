using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class ChatService : IChatService
{
    private readonly FitCityDbContext _dbContext;

    public ChatService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<ConversationDto> CreateConversationAsync(Guid userId, ConversationCreateRequest request, CancellationToken cancellationToken)
    {
        var requester = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (requester is null)
        {
            throw new InvalidOperationException("User not found.");
        }

        var otherUser = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == request.OtherUserId, cancellationToken);
        if (otherUser is null)
        {
            throw new InvalidOperationException("Other user not found.");
        }

        if (!IsChatRole(requester.Role) || !IsChatRole(otherUser.Role))
        {
            throw new InvalidOperationException("Only members and trainers can use chat.");
        }

        Guid memberId;
        Guid trainerId;
        if (requester.Role == UserRole.User && otherUser.Role == UserRole.Trainer)
        {
            memberId = requester.Id;
            trainerId = otherUser.Id;
        }
        else if (requester.Role == UserRole.Trainer && otherUser.Role == UserRole.User)
        {
            memberId = otherUser.Id;
            trainerId = requester.Id;
        }
        else
        {
            throw new InvalidOperationException("Chats must be between one member and one trainer.");
        }

        var existing = await _dbContext.Conversations
            .FirstOrDefaultAsync(c => c.MemberId == memberId && c.TrainerId == trainerId, cancellationToken);
        if (existing != null)
        {
            await EnsureParticipantsAsync(existing.Id, memberId, trainerId, cancellationToken);
            return MapConversation(existing);
        }

        var now = DateTime.UtcNow;
        var conversation = new Conversation
        {
            Id = Guid.NewGuid(),
            MemberId = memberId,
            TrainerId = trainerId,
            Title = request.Title,
            CreatedAtUtc = now,
            UpdatedAtUtc = now
        };

        _dbContext.Conversations.Add(conversation);
        _dbContext.ConversationParticipants.AddRange(new[]
        {
            new ConversationParticipant
            {
                Id = Guid.NewGuid(),
                ConversationId = conversation.Id,
                UserId = memberId,
                JoinedAtUtc = now,
                LastReadAtUtc = memberId == userId ? now : null
            },
            new ConversationParticipant
            {
                Id = Guid.NewGuid(),
                ConversationId = conversation.Id,
                UserId = trainerId,
                JoinedAtUtc = now,
                LastReadAtUtc = trainerId == userId ? now : null
            }
        });
        await _dbContext.SaveChangesAsync(cancellationToken);

        return MapConversation(conversation);
    }

    public async Task<IReadOnlyList<ConversationSummaryDto>> GetMyConversationsAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (user is null || !IsChatRole(user.Role))
        {
            throw new InvalidOperationException("Only members and trainers can access chats.");
        }

        var query = _dbContext.Conversations
            .AsNoTracking()
            .Include(c => c.Member)
            .Include(c => c.Trainer)
            .AsQueryable();

        query = user.Role == UserRole.User
            ? query.Where(c => c.MemberId == userId)
            : query.Where(c => c.TrainerId == userId);

        var conversations = await query
            .OrderByDescending(c => c.LastMessageAtUtc ?? c.UpdatedAtUtc)
            .ToListAsync(cancellationToken);

        if (conversations.Count == 0)
        {
            return Array.Empty<ConversationSummaryDto>();
        }

        var conversationIds = conversations.Select(c => c.Id).ToList();
        var participants = await _dbContext.ConversationParticipants
            .AsNoTracking()
            .Where(p => p.UserId == userId && conversationIds.Contains(p.ConversationId))
            .ToListAsync(cancellationToken);
        var lastReads = participants.ToDictionary(p => p.ConversationId, p => p.LastReadAtUtc);

        var lastMessages = await _dbContext.Messages
            .AsNoTracking()
            .Where(m => conversationIds.Contains(m.ConversationId))
            .GroupBy(m => m.ConversationId)
            .Select(g => g.OrderByDescending(m => m.SentAtUtc).First())
            .ToListAsync(cancellationToken);
        var lastMessageLookup = lastMessages.ToDictionary(m => m.ConversationId, m => m);

        var summaries = new List<ConversationSummaryDto>();
        foreach (var conversation in conversations)
        {
            var otherUser = user.Role == UserRole.User ? conversation.Trainer : conversation.Member;
            var lastReadAt = lastReads.TryGetValue(conversation.Id, out var lastRead) ? lastRead : null;
            var unreadCount = await _dbContext.Messages
                .AsNoTracking()
                .CountAsync(m => m.ConversationId == conversation.Id
                                 && m.SenderUserId != userId
                                 && m.SentAtUtc > (lastReadAt ?? DateTime.MinValue), cancellationToken);

            lastMessageLookup.TryGetValue(conversation.Id, out var lastMessage);

            summaries.Add(new ConversationSummaryDto
            {
                Id = conversation.Id,
                MemberId = conversation.MemberId,
                TrainerId = conversation.TrainerId,
                OtherUserId = otherUser.Id,
                OtherUserName = otherUser.FullName,
                OtherUserRole = otherUser.Role.ToString(),
                LastMessage = lastMessage?.Content,
                LastMessageAtUtc = lastMessage?.SentAtUtc ?? conversation.LastMessageAtUtc,
                UnreadCount = unreadCount
            });
        }

        return summaries;
    }

    public async Task<IReadOnlyList<MessageDto>> GetMessagesAsync(
        Guid userId,
        Guid conversationId,
        DateTime? beforeUtc,
        int take,
        CancellationToken cancellationToken)
    {
        var isParticipant = await _dbContext.ConversationParticipants
            .AsNoTracking()
            .AnyAsync(p => p.ConversationId == conversationId && p.UserId == userId, cancellationToken);

        if (!isParticipant)
        {
            throw new InvalidOperationException("User is not a participant.");
        }

        var query = _dbContext.Messages
            .AsNoTracking()
            .Where(m => m.ConversationId == conversationId);

        if (beforeUtc.HasValue)
        {
            query = query.Where(m => m.SentAtUtc < beforeUtc.Value);
        }

        var messages = await query
            .OrderByDescending(m => m.SentAtUtc)
            .Take(take)
            .OrderBy(m => m.SentAtUtc)
            .ToListAsync(cancellationToken);

        return messages.Select(m => new MessageDto
        {
            Id = m.Id,
            ConversationId = m.ConversationId,
            SenderUserId = m.SenderUserId,
            SenderRole = m.SenderRole,
            Content = m.Content,
            SentAtUtc = m.SentAtUtc
        }).ToList();
    }

    public async Task<MessageDto> SendMessageAsync(Guid userId, MessageCreateRequest request, CancellationToken cancellationToken)
    {
        var participant = await _dbContext.ConversationParticipants
            .FirstOrDefaultAsync(p => p.ConversationId == request.ConversationId && p.UserId == userId, cancellationToken);

        if (participant is null)
        {
            throw new InvalidOperationException("User is not a participant.");
        }

        var sender = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (sender is null)
        {
            throw new InvalidOperationException("User not found.");
        }

        var now = DateTime.UtcNow;
        var message = new Message
        {
            Id = Guid.NewGuid(),
            ConversationId = request.ConversationId,
            SenderUserId = userId,
            SenderRole = sender.Role.ToString(),
            Content = request.Content,
            SentAtUtc = now
        };

        var conversation = await _dbContext.Conversations
            .FirstOrDefaultAsync(c => c.Id == request.ConversationId, cancellationToken);
        if (conversation is null)
        {
            throw new InvalidOperationException("Conversation not found.");
        }

        conversation.LastMessageAtUtc = now;
        conversation.UpdatedAtUtc = now;

        _dbContext.Messages.Add(message);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new MessageDto
        {
            Id = message.Id,
            ConversationId = message.ConversationId,
            SenderUserId = message.SenderUserId,
            SenderRole = message.SenderRole,
            Content = message.Content,
            SentAtUtc = message.SentAtUtc
        };
    }

    public async Task<int> MarkConversationReadAsync(Guid userId, Guid conversationId, CancellationToken cancellationToken)
    {
        var participant = await _dbContext.ConversationParticipants
            .FirstOrDefaultAsync(p => p.ConversationId == conversationId && p.UserId == userId, cancellationToken);

        if (participant is null)
        {
            throw new InvalidOperationException("User is not a participant.");
        }

        var lastReadAt = participant.LastReadAtUtc ?? DateTime.MinValue;
        var unreadCount = await _dbContext.Messages
            .AsNoTracking()
            .CountAsync(m => m.ConversationId == conversationId
                             && m.SenderUserId != userId
                             && m.SentAtUtc > lastReadAt, cancellationToken);

        participant.LastReadAtUtc = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);

        return unreadCount;
    }

    private static bool IsChatRole(UserRole role)
        => role == UserRole.User || role == UserRole.Trainer;

    private static ConversationDto MapConversation(Conversation conversation) => new()
    {
        Id = conversation.Id,
        MemberId = conversation.MemberId,
        TrainerId = conversation.TrainerId,
        Title = conversation.Title,
        CreatedAtUtc = conversation.CreatedAtUtc,
        UpdatedAtUtc = conversation.UpdatedAtUtc,
        LastMessageAtUtc = conversation.LastMessageAtUtc
    };

    private async Task EnsureParticipantsAsync(Guid conversationId, Guid memberId, Guid trainerId, CancellationToken cancellationToken)
    {
        var existing = await _dbContext.ConversationParticipants
            .AsNoTracking()
            .Where(p => p.ConversationId == conversationId)
            .Select(p => p.UserId)
            .ToListAsync(cancellationToken);

        if (!existing.Contains(memberId))
        {
            _dbContext.ConversationParticipants.Add(new ConversationParticipant
            {
                Id = Guid.NewGuid(),
                ConversationId = conversationId,
                UserId = memberId,
                JoinedAtUtc = DateTime.UtcNow
            });
        }

        if (!existing.Contains(trainerId))
        {
            _dbContext.ConversationParticipants.Add(new ConversationParticipant
            {
                Id = Guid.NewGuid(),
                ConversationId = conversationId,
                UserId = trainerId,
                JoinedAtUtc = DateTime.UtcNow
            });
        }

        if (_dbContext.ChangeTracker.HasChanges())
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
    }
}
