using DotNetEnv;
using FitCity.Notifications.Api.Options;
using FitCity.Notifications.Api.Persistence;
using FitCity.Notifications.Api.Services;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

Env.Load();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.Configure<RabbitMqOptions>(builder.Configuration.GetSection(RabbitMqOptions.SectionName));

builder.Services.AddDbContext<NotificationsDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddHostedService<RabbitMqConsumerHostedService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (app.Urls.Any(url => url.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
{
    app.UseHttpsRedirection();
}

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<NotificationsDbContext>();
    try
    {
        dbContext.Database.Migrate();
    }
    catch (SqlException ex) when (ex.Number == 1801)
    {
        // Database already exists; continue with startup.
    }
}

app.Run();
