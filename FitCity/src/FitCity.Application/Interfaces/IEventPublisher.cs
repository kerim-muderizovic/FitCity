namespace FitCity.Application.Interfaces;

public interface IEventPublisher
{
    Task PublishAsync(string eventName, object payload, CancellationToken cancellationToken);
}
