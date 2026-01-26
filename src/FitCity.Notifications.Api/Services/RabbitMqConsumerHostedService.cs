using System.Text;
using DotNetEnv;
using FitCity.Notifications.Api.Entities;
using FitCity.Notifications.Api.Models;
using FitCity.Notifications.Api.Options;
using FitCity.Notifications.Api.Persistence;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace FitCity.Notifications.Api.Services;

public class RabbitMqConsumerHostedService : BackgroundService
{
    private const string QueueName = "mail_sending";
    private readonly RabbitMqOptions _options;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly MailSenderService _mailSenderService;
    private IConnection? _connection;
    private IModel? _channel;

    public RabbitMqConsumerHostedService(IOptions<RabbitMqOptions> options, IServiceScopeFactory scopeFactory)
    {
        _options = options.Value;
        _scopeFactory = scopeFactory;
        _mailSenderService = new MailSenderService();
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        Env.Load();

        var hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? _options.HostName ?? "localhost";
        var username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? _options.UserName ?? "guest";
        var password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? _options.Password ?? "guest";
        var portValue = Environment.GetEnvironmentVariable("_rabbitMqPort");
        var port = int.TryParse(portValue, out var parsedPort) ? parsedPort : _options.Port;

        var factory = new ConnectionFactory
        {
            HostName = hostname,
            Port = port,
            UserName = username,
            Password = password
        };

        _connection = factory.CreateConnection();
        _channel = _connection.CreateModel();
        _channel.QueueDeclare(queue: QueueName, durable: false, exclusive: false, autoDelete: false, arguments: null);

        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += async (_, ea) =>
        {
            var body = ea.Body.ToArray();
            var message = Encoding.UTF8.GetString(body);

            EmailMessage? email = null;
            try
            {
                email = JsonConvert.DeserializeObject<EmailMessage>(message);
            }
            catch (JsonException)
            {
            }

            if (email is not null)
            {
                await _mailSenderService.SendEmailAsync(email, stoppingToken);
            }

            using var scope = _scopeFactory.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<NotificationsDbContext>();
            dbContext.NotificationLogs.Add(new NotificationLog
            {
                Id = Guid.NewGuid(),
                EventName = email?.Subject ?? "Email",
                Payload = message,
                ReceivedAtUtc = DateTime.UtcNow
            });
            await dbContext.SaveChangesAsync(stoppingToken);
        };

        _channel.BasicConsume(queue: QueueName, autoAck: true, consumer: consumer);
        return Task.CompletedTask;
    }

    public override void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
        base.Dispose();
    }
}
