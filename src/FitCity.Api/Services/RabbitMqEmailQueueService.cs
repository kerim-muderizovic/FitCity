using System.Text;
using DotNetEnv;
using FitCity.Application.Interfaces;
using FitCity.Application.Messaging;
using FitCity.Application.Options;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using RabbitMQ.Client;

namespace FitCity.Api.Services;

public class RabbitMqEmailQueueService : IEmailQueueService
{
    private const string QueueName = "mail_sending";
    private readonly RabbitMqOptions _options;

    public RabbitMqEmailQueueService(IOptions<RabbitMqOptions> options)
    {
        _options = options.Value;
    }

    public Task SendEmailAsync(EmailMessage email, CancellationToken cancellationToken)
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
            UserName = username,
            Password = password,
            Port = port
        };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();
        channel.QueueDeclare(queue: QueueName, durable: false, exclusive: false, autoDelete: false, arguments: null);

        var body = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(email));
        channel.BasicPublish(exchange: string.Empty, routingKey: QueueName, basicProperties: null, body: body);

        return Task.CompletedTask;
    }
}
