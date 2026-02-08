using System.Net;
using System.Net.Mail;
using FitCity.Application.Interfaces;
using FitCity.Application.Options;
using Microsoft.Extensions.Options;

namespace FitCity.Api.Services;

public class SmtpEmailSender : IEmailSender
{
    private readonly EmailOptions _options;

    public SmtpEmailSender(IOptions<EmailOptions> options)
    {
        _options = options.Value;
    }

    public async Task SendWelcomeEmailAsync(string email, string? fullName, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return;
        }

        using var message = new MailMessage
        {
            From = new MailAddress(_options.From),
            Subject = "Welcome to FitCity",
            Body = "You successfully registered, congratulations!",
            IsBodyHtml = false
        };
        message.To.Add(new MailAddress(email, fullName ?? string.Empty));

        using var client = new SmtpClient(_options.Host, _options.Port)
        {
            EnableSsl = true
        };

        if (!string.IsNullOrWhiteSpace(_options.Username) || !string.IsNullOrWhiteSpace(_options.Password))
        {
            client.Credentials = new NetworkCredential(_options.Username, _options.Password);
        }

        await client.SendMailAsync(message, cancellationToken);
    }
}
