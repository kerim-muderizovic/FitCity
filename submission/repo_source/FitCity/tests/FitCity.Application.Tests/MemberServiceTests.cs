using FitCity.Application.Interfaces;
using FitCity.Application.Services;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace FitCity.Application.Tests;

public class MemberServiceTests
{
    private sealed class NoopEmailSender : IEmailSender
    {
        public Task SendWelcomeEmailAsync(string email, string? fullName, CancellationToken cancellationToken)
            => Task.CompletedTask;
    }

    [Fact]
    public async Task GymAdminMembersIncludeUsersWithCheckInsForGym()
    {
        var options = new DbContextOptionsBuilder<FitCityDbContext>()
            .UseInMemoryDatabase(nameof(GymAdminMembersIncludeUsersWithCheckInsForGym))
            .Options;

        var gymId = Guid.NewGuid();
        var adminUserId = Guid.NewGuid();
        var memberUserId = Guid.NewGuid();

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
        db.Users.Add(new User
        {
            Id = memberUserId,
            Email = "member@test.local",
            FullName = "Member",
            PasswordHash = "x",
            Role = UserRole.User,
            CreatedAtUtc = DateTime.UtcNow
        });
        db.CheckInLogs.Add(new CheckInLog
        {
            Id = Guid.NewGuid(),
            GymId = gymId,
            UserId = memberUserId,
            IsSuccessful = false,
            Reason = "Entry denied.",
            CheckInAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        var settingsService = new AppSettingsService(db);
        var service = new MemberService(db, new NoopEmailSender(), NullLogger<MemberService>.Instance, settingsService);
        var members = await service.GetMembersAsync(adminUserId, UserRole.GymAdministrator.ToString(), CancellationToken.None);

        Assert.Contains(members, m => m.Id == memberUserId);
    }

    [Fact]
    public async Task MemberDetailReturnsMembershipStatus()
    {
        var options = new DbContextOptionsBuilder<FitCityDbContext>()
            .UseInMemoryDatabase(nameof(MemberDetailReturnsMembershipStatus))
            .Options;

        var gymId = Guid.NewGuid();
        var adminUserId = Guid.NewGuid();
        var memberUserId = Guid.NewGuid();

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
        db.Users.Add(new User
        {
            Id = memberUserId,
            Email = "member@test.local",
            FullName = "Member",
            PasswordHash = "x",
            Role = UserRole.User,
            CreatedAtUtc = DateTime.UtcNow
        });
        db.Memberships.Add(new Membership
        {
            Id = Guid.NewGuid(),
            UserId = memberUserId,
            GymId = gymId,
            StartDateUtc = DateTime.UtcNow.AddDays(-10),
            EndDateUtc = DateTime.UtcNow.AddDays(20),
            Status = MembershipStatus.Active
        });
        await db.SaveChangesAsync();

        var settingsService = new AppSettingsService(db);
        var service = new MemberService(db, new NoopEmailSender(), NullLogger<MemberService>.Instance, settingsService);
        var detail = await service.GetMemberDetailAsync(memberUserId, adminUserId, UserRole.GymAdministrator.ToString(), CancellationToken.None);

        Assert.NotNull(detail);
        Assert.Contains(detail!.Memberships, m => m.Status == MembershipStatus.Active.ToString());
    }
}
