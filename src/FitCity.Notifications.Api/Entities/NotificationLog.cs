namespace FitCity.Notifications.Api.Entities;

public class NotificationLog
{
    public Guid Id { get; set; }
    public string EventName { get; set; } = string.Empty;
    public string Payload { get; set; } = string.Empty;
    public DateTime ReceivedAtUtc { get; set; } = DateTime.UtcNow;
}
