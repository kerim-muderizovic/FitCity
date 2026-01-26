using DotNetEnv;
using FitCity.Notifications.Api.Models;
using MailKit.Net.Smtp;
using MimeKit;
using MimeKit.Text;

namespace FitCity.Notifications.Api.Services;

public class MailSenderService
{
    public async Task SendEmailAsync(EmailMessage emailObj, CancellationToken cancellationToken)
    {
        if (emailObj is null)
        {
            return;
        }

        Env.Load();

        var fromAddress = Environment.GetEnvironmentVariable("_fromAddress") ?? "example@example.com";
        var password = Environment.GetEnvironmentVariable("_password") ?? string.Empty;
        var host = Environment.GetEnvironmentVariable("_host") ?? "smtp.gmail.com";
        var port = int.TryParse(Environment.GetEnvironmentVariable("_port"), out var parsedPort) ? parsedPort : 465;
        var enableSsl = bool.TryParse(Environment.GetEnvironmentVariable("_enableSSL"), out var parsedSsl) ? parsedSsl : true;
        var displayName = Environment.GetEnvironmentVariable("_displayName") ?? "no-reply";
        var timeout = int.TryParse(Environment.GetEnvironmentVariable("_timeout"), out var parsedTimeout) ? parsedTimeout : 255;

        if (string.IsNullOrWhiteSpace(password))
        {
            return;
        }

        var email = new MimeMessage();
        email.From.Add(new MailboxAddress(displayName, fromAddress));
        email.To.Add(new MailboxAddress(emailObj.ReceiverName, emailObj.EmailTo));
        email.Subject = emailObj.Subject;
        email.Body = new TextPart(TextFormat.Html) { Text = emailObj.Message };

        using var smtp = new SmtpClient();
        smtp.Timeout = timeout * 1000;
        await smtp.ConnectAsync(host, port, enableSsl, cancellationToken);
        await smtp.AuthenticateAsync(fromAddress, password, cancellationToken);
        await smtp.SendAsync(email, cancellationToken);
        await smtp.DisconnectAsync(true, cancellationToken);
    }
}
