using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using FitCity.Api.Hubs;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/chat")]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;
    private readonly IHubContext<ChatHub> _hubContext;

    public ChatController(IChatService chatService, IHubContext<ChatHub> hubContext)
    {
        _chatService = chatService;
        _hubContext = hubContext;
    }

    [HttpPost("conversations")]
    [Authorize]
    public async Task<ActionResult<ConversationDto>> CreateConversation([FromBody] ConversationCreateRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var conversation = await _chatService.CreateConversationAsync(userId, request, cancellationToken);
            return Ok(conversation);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("me/conversations")]
    [Authorize]
    public async Task<ActionResult<IReadOnlyList<ConversationSummaryDto>>> MyConversations(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var conversations = await _chatService.GetMyConversationsAsync(userId, cancellationToken);
            return Ok(conversations);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("messages")]
    [Authorize]
    public async Task<ActionResult<MessageDto>> SendMessage([FromBody] MessageCreateRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var message = await _chatService.SendMessageAsync(userId, request, cancellationToken);
            await _hubContext.Clients.Group(ChatHub.ConversationGroup(request.ConversationId))
                .SendAsync("message:new", new { conversationId = request.ConversationId, message }, cancellationToken);
            return Ok(message);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("conversations/{conversationId:guid}/messages")]
    [Authorize]
    public async Task<ActionResult<MessageDto>> SendMessageForConversation(
        Guid conversationId,
        [FromBody] MessageSendRequest request,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var message = await _chatService.SendMessageAsync(userId, new MessageCreateRequest
            {
                ConversationId = conversationId,
                Content = request.Content
            }, cancellationToken);
            await _hubContext.Clients.Group(ChatHub.ConversationGroup(conversationId))
                .SendAsync("message:new", new { conversationId, message }, cancellationToken);
            return Ok(message);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("conversations/{conversationId:guid}/messages")]
    [Authorize]
    public async Task<ActionResult<IReadOnlyList<MessageDto>>> Messages(
        Guid conversationId,
        [FromQuery] DateTime? before,
        [FromQuery] int take,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var safeTake = take <= 0 ? 50 : Math.Min(take, 100);
        try
        {
            var messages = await _chatService.GetMessagesAsync(userId, conversationId, before, safeTake, cancellationToken);
            return Ok(messages);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPatch("conversations/{conversationId:guid}/read")]
    [Authorize]
    public async Task<ActionResult<object>> MarkRead(Guid conversationId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var unread = await _chatService.MarkConversationReadAsync(userId, conversationId, cancellationToken);
            await _hubContext.Clients.Group(ChatHub.ConversationGroup(conversationId))
                .SendAsync("conversation:read", new { conversationId, userId }, cancellationToken);
            return Ok(new { updated = unread });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
