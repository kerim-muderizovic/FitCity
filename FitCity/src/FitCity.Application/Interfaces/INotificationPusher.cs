using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface INotificationPusher
{
    Task SendToUserAsync(Guid userId, NotificationDto notification, CancellationToken cancellationToken);
}
