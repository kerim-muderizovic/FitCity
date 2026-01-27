using System.Text;
using DotNetEnv;
using FitCity.Api.Filters;
using FitCity.Api.Hubs;
using FitCity.Api.Services;
using FitCity.Application.Interfaces;
using FitCity.Application.Options;
using FitCity.Application.Services;
using FitCity.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

Env.Load();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpContextAccessor();

builder.Services.AddControllers(options => options.Filters.Add<ExceptionFilter>());
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.Configure<JwtOptions>(builder.Configuration.GetSection(JwtOptions.SectionName));
builder.Services.Configure<RabbitMqOptions>(builder.Configuration.GetSection(RabbitMqOptions.SectionName));

builder.Services.AddDbContext<FitCityDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IGymService, GymService>();
builder.Services.AddScoped<ITrainerService, TrainerService>();
builder.Services.AddScoped<IMembershipService, MembershipService>();
builder.Services.AddScoped<IQrService, QrService>();
builder.Services.AddScoped<IBookingService, BookingService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IChatService, ChatService>();
builder.Services.AddScoped<IReportsService, ReportsService>();
builder.Services.AddScoped<IRecommendationService, RecommendationService>();
builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IEventPublisher, RabbitMqEventPublisher>();
builder.Services.AddScoped<IEmailQueueService, RabbitMqEmailQueueService>();
builder.Services.AddScoped<IMemberService, MemberService>();
builder.Services.AddScoped<IAdminSearchService, AdminSearchService>();
builder.Services.AddScoped<IGymPlanService, GymPlanService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IAccessLogService, AccessLogService>();
builder.Services.AddScoped<INotificationPusher, SignalRNotificationPusher>();
builder.Services.AddScoped<IProfileService, ProfileService>();

var jwtOptions = builder.Configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>() ?? new JwtOptions();
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
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<ChatHub>("/hubs/chat");
app.MapHub<NotificationsHub>("/hubs/notifications");

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<FitCityDbContext>();
    try
    {
        dbContext.Database.Migrate();
    }
    catch (SqlException ex) when (ex.Number == 1801)
    {
        // Database already exists; continue with startup.
    }
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
