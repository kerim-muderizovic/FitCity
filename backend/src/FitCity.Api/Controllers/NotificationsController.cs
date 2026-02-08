using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/notifications")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet]
    [Authorize]
    public async Task<ActionResult<IReadOnlyList<NotificationDto>>> GetMine(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var notifications = await _notificationService.GetForUserAsync(userId, cancellationToken);
        return Ok(notifications);
    }

    [HttpPatch("{id:guid}/read")]
    [Authorize]
    public async Task<ActionResult<object>> MarkRead(Guid id, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var updated = await _notificationService.MarkReadAsync(userId, id, cancellationToken);
        return updated ? Ok(new { id, isRead = true }) : NotFound();
    }

    [HttpPatch("read-all")]
    [Authorize]
    public async Task<ActionResult<object>> MarkAllRead(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var updated = await _notificationService.MarkAllReadAsync(userId, cancellationToken);
        return Ok(new { updated });
    }
}
