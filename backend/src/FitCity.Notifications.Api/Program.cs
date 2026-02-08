using FitCity.Notifications.Api.Options;
using FitCity.Notifications.Api.Persistence;
using FitCity.Notifications.Api.Services;
using Microsoft.Data.SqlClient;
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

await ApplyDatabaseMigrationsWithRetryAsync(host.Services);

await host.RunAsync();

static async Task ApplyDatabaseMigrationsWithRetryAsync(IServiceProvider services)
{
    var logger = services.GetRequiredService<ILoggerFactory>().CreateLogger("StartupMigration");
    const int maxAttempts = 5;

    for (var attempt = 1; attempt <= maxAttempts; attempt++)
    {
        using var scope = services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<NotificationsDbContext>();

        try
        {
            await dbContext.Database.MigrateAsync();
            return;
        }
        catch (SqlException ex) when (IsConcurrentMigrationSqlError(ex))
        {
            if (attempt == maxAttempts)
            {
                throw;
            }

            var delay = TimeSpan.FromSeconds(Math.Pow(2, attempt));
            logger.LogWarning(
                ex,
                "Database migration concurrency error on attempt {Attempt}/{MaxAttempts}. Retrying in {DelaySeconds} seconds.",
                attempt,
                maxAttempts,
                delay.TotalSeconds);
            await Task.Delay(delay);
        }
    }
}

static bool IsConcurrentMigrationSqlError(SqlException ex)
{
    return ex.Number is 1801 or 1802 or 2714 or 2627;
}
