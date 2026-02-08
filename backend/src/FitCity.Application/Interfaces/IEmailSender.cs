namespace FitCity.Application.Interfaces;

public interface IEmailSender
{
    Task SendWelcomeEmailAsync(string email, string? fullName, CancellationToken cancellationToken);
}
