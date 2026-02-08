using System.Text;
using System.Text.Json;
using FitCity.Application.Interfaces;
using FitCity.Application.Options;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

namespace FitCity.Api.Services;

public class RabbitMqEventPublisher : IEventPublisher
{
    private readonly RabbitMqOptions _options;

    public RabbitMqEventPublisher(IOptions<RabbitMqOptions> options)
    {
        _options = options.Value;
    }

    public Task PublishAsync(string eventName, object payload, CancellationToken cancellationToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _options.HostName,
            Port = _options.Port,
            UserName = _options.UserName,
            Password = _options.Password
        };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();
        channel.ExchangeDeclare(_options.Exchange, ExchangeType.Fanout, durable: true);

        var message = JsonSerializer.Serialize(new
        {
            Event = eventName,
            TimestampUtc = DateTime.UtcNow,
            Payload = payload
        });

        var body = Encoding.UTF8.GetBytes(message);
        channel.BasicPublish(exchange: _options.Exchange, routingKey: string.Empty, basicProperties: null, body: body);

        return Task.CompletedTask;
    }
}
