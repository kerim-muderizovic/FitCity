using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface INotificationService
{
    Task<IReadOnlyList<NotificationDto>> GetForUserAsync(Guid userId, CancellationToken cancellationToken);
    Task<bool> MarkReadAsync(Guid userId, Guid notificationId, CancellationToken cancellationToken);
    Task<int> MarkAllReadAsync(Guid userId, CancellationToken cancellationToken);
}
