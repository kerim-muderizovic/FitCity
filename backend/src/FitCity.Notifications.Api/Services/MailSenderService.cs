using FitCity.Notifications.Api.Models;
using FitCity.Notifications.Api.Options;
using MailKit.Net.Smtp;
using MimeKit;
using MimeKit.Text;
using Microsoft.Extensions.Options;

namespace FitCity.Notifications.Api.Services;

public class MailSenderService
{
    private readonly EmailOptions _options;

    public MailSenderService(IOptions<EmailOptions> options)
    {
        _options = options.Value;
    }

    public async Task SendEmailAsync(EmailMessage emailObj, CancellationToken cancellationToken)
    {
        if (emailObj is null)
        {
            return;
        }

        if (string.IsNullOrWhiteSpace(_options.Host) ||
            string.IsNullOrWhiteSpace(_options.Password) ||
            string.IsNullOrWhiteSpace(_options.From))
        {
            return;
        }

        var username = string.IsNullOrWhiteSpace(_options.Username) ? _options.From : _options.Username;

        var email = new MimeMessage();
        email.From.Add(new MailboxAddress(_options.DisplayName, _options.From));
        email.To.Add(new MailboxAddress(emailObj.ReceiverName, emailObj.EmailTo));
        email.Subject = emailObj.Subject;
        email.Body = new TextPart(TextFormat.Html) { Text = emailObj.Message };

        using var smtp = new SmtpClient();
        smtp.Timeout = _options.TimeoutSeconds * 1000;
        await smtp.ConnectAsync(_options.Host, _options.Port, _options.EnableSsl, cancellationToken);
        await smtp.AuthenticateAsync(username, _options.Password, cancellationToken);
        await smtp.SendAsync(email, cancellationToken);
        await smtp.DisconnectAsync(true, cancellationToken);
    }
}
