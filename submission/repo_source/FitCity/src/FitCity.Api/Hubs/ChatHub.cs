using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace FitCity.Api.Hubs;

[Authorize]
public class ChatHub : Hub
{
    private readonly IChatService _chatService;

    public ChatHub(IChatService chatService)
    {
        _chatService = chatService;
    }

    public static string ConversationGroup(Guid conversationId) => $"conversation:{conversationId}";

    [HubMethodName("conversation:join")]
    public async Task JoinConversation(Guid conversationId)
    {
        var userId = Context.User.GetUserId();
        var messages = await _chatService.GetMessagesAsync(userId, conversationId, null, 1, Context.ConnectionAborted);
        if (messages.Count >= 0)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, ConversationGroup(conversationId));
        }
    }

    [HubMethodName("conversation:leave")]
    public Task LeaveConversation(Guid conversationId)
        => Groups.RemoveFromGroupAsync(Context.ConnectionId, ConversationGroup(conversationId));

    [HubMethodName("message:send")]
    public async Task SendMessage(Guid conversationId, string text)
    {
        var userId = Context.User.GetUserId();
        var message = await _chatService.SendMessageAsync(userId, new MessageCreateRequest
        {
            ConversationId = conversationId,
            Content = text
        }, Context.ConnectionAborted);

        await Clients.Group(ConversationGroup(conversationId))
            .SendAsync("message:new", new { conversationId, message }, Context.ConnectionAborted);
    }
}
