using FitCity.Application.Messaging;

namespace FitCity.Application.Interfaces;

public interface IEmailQueueService
{
    Task SendEmailAsync(EmailMessage email, CancellationToken cancellationToken);
}
