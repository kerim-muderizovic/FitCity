using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Application.Services;
using FitCity.Application.Messaging;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace FitCity.Application.Tests;

public class MembershipPaymentTests
{
    private sealed class NoopEmailQueueService : IEmailQueueService
    {
        public Task SendEmailAsync(EmailMessage email, CancellationToken cancellationToken) => Task.CompletedTask;
    }

    private sealed class NoopQrService : IQrService
    {
        public Task<QrIssueResponse> IssueAsync(Guid membershipId, Guid requesterId, string requesterRole, CancellationToken cancellationToken)
        {
            return Task.FromResult(new QrIssueResponse
            {
                Token = "test-token",
                ExpiresAtUtc = DateTime.UtcNow.AddDays(30)
            });
        }

        public Task<QrScanResultResponse> ScanAsync(Guid userId, string requesterRole, QrScanRequest request, CancellationToken cancellationToken)
        {
            return Task.FromResult(new QrScanResultResponse
            {
                Status = "Granted",
                Reason = string.Empty,
                ScannedAtUtc = DateTime.UtcNow
            });
        }

        public Task<QrScanResultResponse> ValidateAsync(Guid userId, string userRole, QrScanRequest request, CancellationToken cancellationToken)
        {
            return Task.FromResult(new QrScanResultResponse
            {
                Status = "Granted",
                Reason = string.Empty,
                ScannedAtUtc = DateTime.UtcNow
            });
        }
    }

    private sealed class NoopNotificationPusher : INotificationPusher
    {
        public Task SendToUserAsync(Guid userId, NotificationDto notification, CancellationToken cancellationToken)
            => Task.CompletedTask;
    }

    [Fact]
    public async Task PayMembershipRequestExtendsFromLatestEndDate()
    {
        var options = new DbContextOptionsBuilder<FitCityDbContext>()
            .UseInMemoryDatabase(nameof(PayMembershipRequestExtendsFromLatestEndDate))
            .Options;

        var gymId = Guid.NewGuid();
        var planId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var requestId = Guid.NewGuid();
        var existingEnd = DateTime.UtcNow.AddDays(10);

        await using var db = new FitCityDbContext(options);
        db.Gyms.Add(new Gym { Id = gymId, Name = "Test Gym" });
        db.GymPlans.Add(new GymPlan
        {
            Id = planId,
            GymId = gymId,
            Name = "Monthly",
            Price = 50m,
            DurationMonths = 2
        });
        db.Users.Add(new User
        {
            Id = userId,
            Email = "member@test.local",
            FullName = "Member",
            PasswordHash = "x",
            Role = UserRole.User,
            CreatedAtUtc = DateTime.UtcNow
        });
        db.Memberships.Add(new Membership
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            GymId = gymId,
            GymPlanId = planId,
            StartDateUtc = DateTime.UtcNow.AddDays(-20),
            EndDateUtc = existingEnd,
            Status = MembershipStatus.Active
        });
        db.MembershipRequests.Add(new MembershipRequest
        {
            Id = requestId,
            UserId = userId,
            GymId = gymId,
            GymPlanId = planId,
            Status = MembershipRequestStatus.Approved,
            PaymentStatus = PaymentStatus.Unpaid,
            ApprovedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        var service = new MembershipService(
            db,
            new NoopEmailQueueService(),
            new NoopQrService(),
            new NoopNotificationPusher(),
            NullLogger<MembershipService>.Instance);

        var response = await service.PayMembershipRequestAsync(
            requestId,
            userId,
            new MembershipPaymentRequest { PaymentMethod = "Card" },
            CancellationToken.None);

        Assert.Equal(existingEnd, response.Membership.StartDateUtc);
        Assert.Equal(existingEnd.AddMonths(2), response.Membership.EndDateUtc);
    }
}
