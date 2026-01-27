using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class NotificationService : INotificationService
{
    private readonly FitCityDbContext _dbContext;

    public NotificationService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<NotificationDto>> GetForUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        return await _dbContext.Notifications
            .AsNoTracking()
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAtUtc)
            .Select(n => new NotificationDto
            {
                Id = n.Id,
                Title = n.Title,
                Message = n.Message,
                Category = n.Category,
                IsRead = n.IsRead,
                CreatedAtUtc = n.CreatedAtUtc
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> MarkReadAsync(Guid userId, Guid notificationId, CancellationToken cancellationToken)
    {
        var notification = await _dbContext.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId, cancellationToken);

        if (notification is null)
        {
            return false;
        }

        if (!notification.IsRead)
        {
            notification.IsRead = true;
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        return true;
    }

    public async Task<int> MarkAllReadAsync(Guid userId, CancellationToken cancellationToken)
    {
        var unread = await _dbContext.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ToListAsync(cancellationToken);

        if (unread.Count == 0)
        {
            return 0;
        }

        foreach (var item in unread)
        {
            item.IsRead = true;
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        return unread.Count;
    }
}
