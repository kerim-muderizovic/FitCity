using FitCity.Api.Hubs;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.SignalR;

namespace FitCity.Api.Services;

public class SignalRNotificationPusher : INotificationPusher
{
    private readonly IHubContext<NotificationsHub> _hubContext;

    public SignalRNotificationPusher(IHubContext<NotificationsHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public Task SendToUserAsync(Guid userId, NotificationDto notification, CancellationToken cancellationToken)
    {
        return _hubContext.Clients.User(userId.ToString())
            .SendAsync("notification:new", notification, cancellationToken);
    }
}
