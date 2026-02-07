using FitCity.Notifications.Api.Options;
using FitCity.Notifications.Api.Persistence;
using FitCity.Notifications.Api.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureServices((context, services) =>
    {
        services.Configure<RabbitMqOptions>(context.Configuration.GetSection(RabbitMqOptions.SectionName));
        services.Configure<EmailOptions>(context.Configuration.GetSection(EmailOptions.SectionName));

        services.AddDbContext<NotificationsDbContext>(options =>
            options.UseSqlServer(context.Configuration.GetConnectionString("DefaultConnection")));

        services.AddSingleton<MailSenderService>();
        services.AddHostedService<RabbitMqConsumerHostedService>();
    })
    .Build();

using (var scope = host.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<NotificationsDbContext>();
    dbContext.Database.Migrate();
}

await host.RunAsync();
