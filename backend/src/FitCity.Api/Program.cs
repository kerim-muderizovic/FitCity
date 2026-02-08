using System.Text;
using FitCity.Api.Filters;
using FitCity.Api.Hubs;
using FitCity.Api.Services;
using FitCity.Application.Interfaces;
using FitCity.Application.Options;
using FitCity.Application.Services;
using FitCity.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

const long maxPhotoUploadBytes = 10 * 1024 * 1024;

builder.Services.AddHttpContextAccessor();
builder.Services.Configure<FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = maxPhotoUploadBytes;
});
builder.WebHost.ConfigureKestrel(options =>
{
    options.Limits.MaxRequestBodySize = maxPhotoUploadBytes;
});

builder.Services.AddControllers(options => options.Filters.Add<ExceptionFilter>());
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.Configure<JwtOptions>(builder.Configuration.GetSection(JwtOptions.SectionName));
builder.Services.Configure<RabbitMqOptions>(builder.Configuration.GetSection(RabbitMqOptions.SectionName));
builder.Services.Configure<EmailOptions>(builder.Configuration.GetSection(EmailOptions.SectionName));
builder.Services.Configure<StripeOptions>(builder.Configuration.GetSection(StripeOptions.SectionName));
builder.Services.PostConfigure<EmailOptions>(options =>
{
    var provider = Environment.GetEnvironmentVariable("EMAIL_PROVIDER");
    if (!string.IsNullOrWhiteSpace(provider))
    {
        options.Provider = provider;
    }

    var host = Environment.GetEnvironmentVariable("EMAIL_HOST");
    if (!string.IsNullOrWhiteSpace(host))
    {
        options.Host = host;
    }

    var portValue = Environment.GetEnvironmentVariable("EMAIL_PORT");
    if (int.TryParse(portValue, out var port))
    {
        options.Port = port;
    }

    var username = Environment.GetEnvironmentVariable("EMAIL_USER");
    if (!string.IsNullOrWhiteSpace(username))
    {
        options.Username = username;
    }

    var password = Environment.GetEnvironmentVariable("EMAIL_PASS");
    if (!string.IsNullOrWhiteSpace(password))
    {
        options.Password = password;
    }

    var from = Environment.GetEnvironmentVariable("EMAIL_FROM");
    if (!string.IsNullOrWhiteSpace(from))
    {
        options.From = from;
    }
});

builder.Services.PostConfigure<StripeOptions>(options =>
{
    var secretKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");
    if (!string.IsNullOrWhiteSpace(secretKey))
    {
        options.SecretKey = secretKey;
    }

    var publishableKey = Environment.GetEnvironmentVariable("STRIPE_PUBLISHABLE_KEY");
    if (!string.IsNullOrWhiteSpace(publishableKey))
    {
        options.PublishableKey = publishableKey;
    }

    var webhookSecret = Environment.GetEnvironmentVariable("STRIPE_WEBHOOK_SECRET");
    if (!string.IsNullOrWhiteSpace(webhookSecret))
    {
        options.WebhookSecret = webhookSecret;
    }

    var currency = Environment.GetEnvironmentVariable("STRIPE_CURRENCY");
    if (!string.IsNullOrWhiteSpace(currency))
    {
        options.Currency = currency;
    }

    var successUrl = Environment.GetEnvironmentVariable("STRIPE_SUCCESS_URL");
    if (!string.IsNullOrWhiteSpace(successUrl))
    {
        options.SuccessUrl = successUrl;
    }

    var cancelUrl = Environment.GetEnvironmentVariable("STRIPE_CANCEL_URL");
    if (!string.IsNullOrWhiteSpace(cancelUrl))
    {
        options.CancelUrl = cancelUrl;
    }
});

builder.Services.AddDbContext<FitCityDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IAppSettingsService, AppSettingsService>();
builder.Services.AddScoped<IGymService, GymService>();
builder.Services.AddScoped<ITrainerService, TrainerService>();
builder.Services.AddScoped<IMembershipService, MembershipService>();
builder.Services.AddScoped<IQrService, QrService>();
builder.Services.AddScoped<IGymQrService, GymQrService>();
builder.Services.AddScoped<IEntryService, EntryService>();
builder.Services.AddScoped<IBookingService, BookingService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IChatService, ChatService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IStripePaymentService, StripePaymentService>();
builder.Services.AddScoped<IReportsService, ReportsService>();
builder.Services.AddScoped<IRecommendationService, RecommendationService>();
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IEventPublisher, RabbitMqEventPublisher>();
builder.Services.AddScoped<IEmailQueueService, RabbitMqEmailQueueService>();
builder.Services.AddTransient<SmtpEmailSender>();
builder.Services.AddTransient<ConsoleEmailSender>();
builder.Services.AddTransient<FileEmailSender>();
builder.Services.AddSingleton<IEmailSender>(sp =>
{
    var options = sp.GetRequiredService<IOptions<EmailOptions>>().Value;
    var provider = (options.Provider ?? string.Empty).Trim().ToLowerInvariant();
    return provider switch
    {
        "console" => sp.GetRequiredService<ConsoleEmailSender>(),
        "file" => sp.GetRequiredService<FileEmailSender>(),
        "smtp" => sp.GetRequiredService<SmtpEmailSender>(),
        "mailtrap" => sp.GetRequiredService<SmtpEmailSender>(),
        _ => sp.GetRequiredService<SmtpEmailSender>()
    };
});
builder.Services.AddScoped<IMemberService, MemberService>();
builder.Services.AddScoped<IAdminSearchService, AdminSearchService>();
builder.Services.AddScoped<IGymPlanService, GymPlanService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IAccessLogService, AccessLogService>();
builder.Services.AddScoped<INotificationPusher, SignalRNotificationPusher>();
builder.Services.AddScoped<IProfileService, ProfileService>();

var jwtOptions = builder.Configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>() ?? new JwtOptions();
if (string.IsNullOrWhiteSpace(jwtOptions.SecretKey))
{
    throw new InvalidOperationException("Jwt:SecretKey is not configured.");
}
if (string.IsNullOrWhiteSpace(jwtOptions.Issuer))
{
    throw new InvalidOperationException("Jwt:Issuer is not configured.");
}
if (string.IsNullOrWhiteSpace(jwtOptions.Audience))
{
    throw new InvalidOperationException("Jwt:Audience is not configured.");
}

var key = Encoding.UTF8.GetBytes(jwtOptions.SecretKey);
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtOptions.Issuer,
        ValidAudience = jwtOptions.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(key)
    };
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            var path = context.HttpContext.Request.Path;
            if (!string.IsNullOrEmpty(accessToken)
                && (path.StartsWithSegments("/hubs/chat") || path.StartsWithSegments("/hubs/notifications")))
            {
                context.Token = accessToken;
            }
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddAuthorization();
builder.Services.AddCors();
builder.Services.AddSignalR();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(options => options
    .AllowAnyOrigin()
    .AllowAnyMethod()
    .AllowAnyHeader());

if (app.Urls.Any(url => url.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
{
    app.UseHttpsRedirection();
}
var webRootPath = string.IsNullOrWhiteSpace(app.Environment.WebRootPath)
    ? Path.Combine(app.Environment.ContentRootPath, "wwwroot")
    : app.Environment.WebRootPath;
Directory.CreateDirectory(webRootPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(webRootPath)
});
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<ChatHub>("/hubs/chat");
app.MapHub<NotificationsHub>("/hubs/notifications");

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<FitCityDbContext>();
    dbContext.Database.Migrate();
    dbContext.Database.ExecuteSqlRaw(
        """
        UPDATE [Gyms]
        SET [Latitude] = 43.8563
        WHERE [Latitude] IS NULL;
        UPDATE [Gyms]
        SET [Longitude] = 18.4131
        WHERE [Longitude] IS NULL;
        UPDATE [Gyms]
        SET [City] = 'Sarajevo'
        WHERE [City] IS NULL OR LTRIM(RTRIM([City])) = '';
        UPDATE [Gyms]
        SET [Address] = 'City Center, Sarajevo'
        WHERE [Address] IS NULL OR LTRIM(RTRIM([Address])) = '';
        """);
}

if (app.Environment.IsDevelopment())
{
    await DevSeedData.SeedTrainerAvailabilityAsync(app.Services, app.Logger);
    await DevSeedData.SeedRecommendationDataAsync(app.Services, app.Logger);
    await DevSeedData.SeedGymPhotosAsync(app.Services, app.Logger);
    Console.WriteLine("Seeded gym admins (desktop only):");
    Console.WriteLine(" - admin.novosarajevo@fitcity.local / gymnovo1");
    Console.WriteLine(" - admin.grbavica@fitcity.local / gymgrb1");
    Console.WriteLine(" - admin.bosna@fitcity.local / gymbosna1");
    Console.WriteLine(" - admin.grada@fitcity.local / gymgrada1");
    Console.WriteLine("Seeded trainer accounts (mobile only):");
    Console.WriteLine(" - trainer1@gym.local / trainer1pass (Trainer Mustafa)");
    Console.WriteLine(" - trainer2@gym.local / trainer2pass (Trainer Halid)");
    Console.WriteLine(" - trainer3@gym.local / trainer3pass (Trainer Velid)");
    Console.WriteLine(" - trainer4@gym.local / trainer4pass (Trainer Edis)");
    Console.WriteLine(" - trainer5@gym.local / trainer5pass (Trainer Mahmut)");
    Console.WriteLine(" - trainer6@gym.local / trainer6pass (Trainer Elvis)");
}

await app.RunAsync();
