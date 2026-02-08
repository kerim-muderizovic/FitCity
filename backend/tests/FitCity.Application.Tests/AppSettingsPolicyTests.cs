using FitCity.Application.DTOs;
using FitCity.Application.Exceptions;
using FitCity.Application.Interfaces;
using FitCity.Application.Options;
using FitCity.Application.Security;
using FitCity.Application.Services;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using MicrosoftOptions = Microsoft.Extensions.Options.Options;
using Xunit;

namespace FitCity.Application.Tests;

public class AppSettingsPolicyTests
{
    private sealed class NoopEmailSender : IEmailSender
    {
        public Task SendWelcomeEmailAsync(string email, string? fullName, CancellationToken cancellationToken)
            => Task.CompletedTask;
    }

    private sealed class StubJwtTokenService : IJwtTokenService
    {
        public string CreateToken(User user, DateTime expiresAtUtc) => "token";
    }

    [Fact]
    public async Task RegisterAsync_Throws_WhenUserRegistrationDisabled()
    {
        var options = new DbContextOptionsBuilder<FitCityDbContext>()
            .UseInMemoryDatabase(nameof(RegisterAsync_Throws_WhenUserRegistrationDisabled))
            .Options;

        await using var db = new FitCityDbContext(options);
        db.AppSettings.Add(new AppSettings
        {
            Id = AppSettings.DefaultId,
            AllowGymRegistrations = true,
            AllowUserRegistration = false,
            AllowTrainerCreation = true
        });
        await db.SaveChangesAsync();

        var settingsService = new AppSettingsService(db);
        var authService = new AuthService(
            db,
            new StubJwtTokenService(),
            MicrosoftOptions.Create(new JwtOptions { ExpirationMinutes = 60, SecretKey = "test-secret-key" }),
            new NoopEmailSender(),
            NullLogger<AuthService>.Instance,
            settingsService);

        var request = new RegisterRequest
        {
            Email = "user@test.local",
            Password = "password123",
            FullName = "Test User"
        };

        await Assert.ThrowsAsync<UserException>(() => authService.RegisterAsync(request, CancellationToken.None));
    }

    [Fact]
    public async Task CreateTrainer_Throws_WhenTrainerCreationDisabled()
    {
        var options = new DbContextOptionsBuilder<FitCityDbContext>()
            .UseInMemoryDatabase(nameof(CreateTrainer_Throws_WhenTrainerCreationDisabled))
            .Options;

        var gymId = Guid.NewGuid();
        var adminUserId = Guid.NewGuid();

        await using var db = new FitCityDbContext(options);
        db.Gyms.Add(new Gym { Id = gymId, Name = "Test Gym" });
        db.Users.Add(new User
        {
            Id = adminUserId,
            Email = "admin@test.local",
            FullName = "Admin",
            PasswordHash = "x",
            Role = UserRole.GymAdministrator,
            CreatedAtUtc = DateTime.UtcNow
        });
        db.GymAdministrators.Add(new GymAdministrator
        {
            Id = Guid.NewGuid(),
            UserId = adminUserId,
            GymId = gymId,
            AssignedAtUtc = DateTime.UtcNow
        });
        db.AppSettings.Add(new AppSettings
        {
            Id = AppSettings.DefaultId,
            AllowGymRegistrations = true,
            AllowUserRegistration = true,
            AllowTrainerCreation = false
        });
        await db.SaveChangesAsync();

        var settingsService = new AppSettingsService(db);
        var trainerService = new TrainerService(db, settingsService);

        var request = new GymAdminTrainerCreateRequest
        {
            Email = "trainer@test.local",
            FullName = "Trainer",
            Password = "trainerpass",
            HourlyRate = 30
        };

        await Assert.ThrowsAsync<UserException>(() => trainerService.CreateForGymAdminAsync(adminUserId, request, CancellationToken.None));
    }

    [Fact]
    public async Task CreateMember_Throws_WhenUserRegistrationDisabled()
    {
        var options = new DbContextOptionsBuilder<FitCityDbContext>()
            .UseInMemoryDatabase(nameof(CreateMember_Throws_WhenUserRegistrationDisabled))
            .Options;

        var adminUserId = Guid.NewGuid();

        await using var db = new FitCityDbContext(options);
        db.Users.Add(new User
        {
            Id = adminUserId,
            Email = "admin@test.local",
            FullName = "Admin",
            PasswordHash = "x",
            Role = UserRole.CentralAdministrator,
            CreatedAtUtc = DateTime.UtcNow
        });
        db.AppSettings.Add(new AppSettings
        {
            Id = AppSettings.DefaultId,
            AllowGymRegistrations = true,
            AllowUserRegistration = false,
            AllowTrainerCreation = true
        });
        await db.SaveChangesAsync();

        var settingsService = new AppSettingsService(db);
        var memberService = new MemberService(db, new NoopEmailSender(), NullLogger<MemberService>.Instance, settingsService);

        var request = new MemberCreateRequest
        {
            Email = "member@test.local",
            FullName = "Member",
            Password = "memberpass"
        };

        await Assert.ThrowsAsync<UserException>(() =>
            memberService.CreateMemberAsync(request, adminUserId, UserRole.CentralAdministrator.ToString(), CancellationToken.None));
    }
}
