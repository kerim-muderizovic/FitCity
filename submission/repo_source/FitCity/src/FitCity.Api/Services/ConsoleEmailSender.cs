using FitCity.Application.Interfaces;

namespace FitCity.Api.Services;

public class ConsoleEmailSender : IEmailSender
{
    public Task SendWelcomeEmailAsync(string email, string? fullName, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return Task.CompletedTask;
        }

        Console.WriteLine("----- FitCity Email (Console) -----");
        Console.WriteLine($"To: {email}");
        Console.WriteLine($"Name: {fullName}");
        Console.WriteLine("Subject: Welcome to FitCity");
        Console.WriteLine("Body: You successfully registered, congratulations!");
        Console.WriteLine("-----------------------------------");

        return Task.CompletedTask;
    }
}
