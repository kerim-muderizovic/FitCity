using FitCity.Application.DTOs;
using FitCity.Application.Exceptions;
using FitCity.Application.Interfaces;
using FitCity.Application.Messaging;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitCity.Application.Services;

public class MembershipService : IMembershipService
{
    private const decimal DefaultMembershipPlanPrice = 49.99m;
    private const int DefaultMembershipPlanDurationMonths = 1;
    private const string DefaultMembershipPlanName = "Standard Membership";
    private const string DefaultMembershipPlanDescription = "Auto-created default membership plan.";

    private readonly FitCityDbContext _dbContext;
    private readonly IEmailQueueService _emailQueueService;
    private readonly IQrService _qrService;
    private readonly INotificationPusher _notificationPusher;
    private readonly ILogger<MembershipService> _logger;

    public MembershipService(
        FitCityDbContext dbContext,
        IEmailQueueService emailQueueService,
        IQrService qrService,
        INotificationPusher notificationPusher,
        ILogger<MembershipService> logger)
    {
        _dbContext = dbContext;
        _emailQueueService = emailQueueService;
        _qrService = qrService;
        _notificationPusher = notificationPusher;
        _logger = logger;
    }

    public async Task<MembershipRequestDto> RequestMembershipAsync(Guid userId, MembershipRequestCreate request, CancellationToken cancellationToken)
    {
        var gymExists = await _dbContext.Gyms.AnyAsync(g => g.Id == request.GymId, cancellationToken);
        if (!gymExists)
        {
            throw new UserException("Gym not found.");
        }

        var plan = await TryResolveMembershipPlanAsync(request.GymId, request.GymPlanId, cancellationToken);

        var now = DateTime.UtcNow;
        var hasActiveMembership = await _dbContext.Memberships
            .AsNoTracking()
            .AnyAsync(m => m.UserId == userId
                && m.GymId == request.GymId
                && m.Status == MembershipStatus.Active
                && m.EndDateUtc.Date >= now.Date, cancellationToken);
        if (hasActiveMembership)
        {
            throw new UserException("You already have an active membership for this gym.");
        }

        var existingRequest = await _dbContext.MembershipRequests
            .Where(r => r.UserId == userId && r.GymId == request.GymId)
            .OrderByDescending(r => r.RequestedAtUtc)
            .FirstOrDefaultAsync(cancellationToken);
        if (existingRequest is not null
            && existingRequest.Status != MembershipRequestStatus.Rejected
            && existingRequest.Status != MembershipRequestStatus.Cancelled
            && existingRequest.PaymentStatus != PaymentStatus.Paid)
        {
            if (plan is not null && existingRequest.GymPlanId != plan.Id)
            {
                existingRequest.GymPlanId = plan.Id;
                await _dbContext.SaveChangesAsync(cancellationToken);
            }
            return MapRequest(existingRequest);
        }

        var membershipRequest = new MembershipRequest
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            GymId = request.GymId,
            GymPlanId = plan?.Id,
            Status = MembershipRequestStatus.Pending,
            PaymentStatus = PaymentStatus.Unpaid,
            RequestedAtUtc = now
        };

        _dbContext.MembershipRequests.Add(membershipRequest);
        _dbContext.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Title = "Membership requested",
            Message = "Your membership request has been submitted.",
            Category = "membership",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        });

        var gymName = await _dbContext.Gyms.AsNoTracking()
            .Where(g => g.Id == request.GymId)
            .Select(g => g.Name)
            .FirstOrDefaultAsync(cancellationToken);
        var requesterName = await _dbContext.Users.AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => u.FullName)
            .FirstOrDefaultAsync(cancellationToken);
        var adminIds = await _dbContext.GymAdministrators
            .AsNoTracking()
            .Where(a => a.GymId == request.GymId)
            .Select(a => a.UserId)
            .ToListAsync(cancellationToken);

        var adminNotifications = new List<(Guid AdminId, NotificationDto Notification)>();
        foreach (var adminId in adminIds)
        {
            var notification = new Notification
            {
                Id = Guid.NewGuid(),
                UserId = adminId,
                Title = "New membership request",
                Message = $"{requesterName ?? "A member"} requested to join {gymName ?? "your gym"}.",
                Category = "membership_request",
                IsRead = false,
                CreatedAtUtc = now
            };
            _dbContext.Notifications.Add(notification);
            adminNotifications.Add((
                adminId,
                new NotificationDto
                {
                    Id = notification.Id,
                    Title = notification.Title,
                    Message = notification.Message,
                    Category = notification.Category,
                    IsRead = notification.IsRead,
                    CreatedAtUtc = notification.CreatedAtUtc
                }));
        }
        await _dbContext.SaveChangesAsync(cancellationToken);

        foreach (var item in adminNotifications)
        {
            try
            {
                await _notificationPusher.SendToUserAsync(item.AdminId, item.Notification, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to push membership request notification to admin {AdminId}.", item.AdminId);
            }
        }

        return MapRequest(membershipRequest);
    }

    public async Task<MembershipRequestDto?> DecideRequestAsync(
        Guid requestId,
        bool approve,
        string? rejectionReason,
        Guid adminUserId,
        string adminRole,
        CancellationToken cancellationToken)
    {
        var request = await _dbContext.MembershipRequests.FirstOrDefaultAsync(r => r.Id == requestId, cancellationToken);
        if (request is null)
        {
            return null;
        }

        await EnsureGymScopeAsync(request.GymId, adminUserId, adminRole, cancellationToken);
        if (request.Status != MembershipRequestStatus.Pending)
        {
            return MapRequest(request);
        }

        request.Status = approve ? MembershipRequestStatus.Approved : MembershipRequestStatus.Rejected;

        Notification? memberNotification = null;

        if (approve)
        {
            var now = DateTime.UtcNow;
            var plan = await TryResolveMembershipPlanAsync(request.GymId, request.GymPlanId, cancellationToken);
            var hasActiveMembership = await _dbContext.Memberships
                .AsNoTracking()
                .AnyAsync(m => m.UserId == request.UserId
                    && m.GymId == request.GymId
                    && m.Status == MembershipStatus.Active
                    && m.EndDateUtc.Date >= now.Date, cancellationToken);
            if (hasActiveMembership)
            {
                throw new InvalidOperationException("Member already has an active membership for this gym.");
            }

            request.ApprovedAtUtc = now;
            request.ApprovedByUserId = adminUserId;
            request.PaymentStatus = PaymentStatus.Unpaid;
            request.GymPlanId = plan?.Id;
            request.RejectedAtUtc = null;
            request.RejectedByUserId = null;
            request.RejectionReason = null;

            var user = await _dbContext.Users.AsNoTracking()
                .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken);
            var gymName = await _dbContext.Gyms.AsNoTracking()
                .Where(g => g.Id == request.GymId)
                .Select(g => g.Name)
                .FirstOrDefaultAsync(cancellationToken);

            if (user is not null)
            {
                await _emailQueueService.SendEmailAsync(new EmailMessage
                {
                    EmailTo = user.Email,
                    ReceiverName = user.FullName,
                    Subject = "Membership approved",
                    Message = $"Your membership request for {gymName ?? "the gym"} has been approved. You can now complete payment to activate your pass."
                }, cancellationToken);
            }

            memberNotification = new Notification
            {
                Id = Guid.NewGuid(),
                UserId = request.UserId,
                Title = "Membership approved",
                Message = "Your membership request was approved. Complete payment to activate your pass.",
                Category = "membership",
                IsRead = false,
                CreatedAtUtc = now
            };
            _dbContext.Notifications.Add(memberNotification);
        }
        else
        {
            var now = DateTime.UtcNow;
            var reason = string.IsNullOrWhiteSpace(rejectionReason)
                ? "Sorry, we have full capacity right now. Please try again sometime."
                : rejectionReason.Trim();
            request.RejectedAtUtc = now;
            request.RejectedByUserId = adminUserId;
            request.RejectionReason = reason;
            memberNotification = new Notification
            {
                Id = Guid.NewGuid(),
                UserId = request.UserId,
                Title = "Membership rejected",
                Message = $"Your membership request was rejected. Reason: {reason}",
                Category = "membership",
                IsRead = false,
                CreatedAtUtc = now
            };
            _dbContext.Notifications.Add(memberNotification);
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        if (memberNotification != null)
        {
            await PushMembershipDecisionNotificationAsync(memberNotification, request.GymId, cancellationToken);
        }
        return MapRequest(request);
    }

    private async Task PushMembershipDecisionNotificationAsync(
        Notification notification,
        Guid gymId,
        CancellationToken cancellationToken)
    {
        var gymName = await _dbContext.Gyms.AsNoTracking()
            .Where(g => g.Id == gymId)
            .Select(g => g.Name)
            .FirstOrDefaultAsync(cancellationToken);

        var isApproved = notification.Title.Contains("approved", StringComparison.OrdinalIgnoreCase);
        var message = isApproved
            ? $"Your membership request for {gymName ?? "the gym"} was approved."
            : $"Your membership request for {gymName ?? "the gym"} was rejected.";
        if (!isApproved && !string.IsNullOrWhiteSpace(notification.Message))
        {
            var reasonIndex = notification.Message.IndexOf("Reason:", StringComparison.OrdinalIgnoreCase);
            if (reasonIndex >= 0)
            {
                message = $"{message} {notification.Message.Substring(reasonIndex)}";
            }
        }

        notification.Message = message;
        var notificationDto = new NotificationDto
        {
            Id = notification.Id,
            Title = notification.Title,
            Message = message,
            Category = "membership",
            IsRead = false,
            CreatedAtUtc = notification.CreatedAtUtc
        };

        try
        {
            await _notificationPusher.SendToUserAsync(notification.UserId, notificationDto, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to push membership decision notification to user {UserId}.", notification.UserId);
        }
    }

    public async Task<IReadOnlyList<MembershipRequestDto>> GetMembershipRequestsAsync(
        Guid requesterId,
        string requesterRole,
        Guid? gymId,
        Guid? userId,
        string? status,
        CancellationToken cancellationToken)
    {
        var query = _dbContext.MembershipRequests.AsNoTracking();

        if (string.Equals(requesterRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(r => r.UserId == requesterId);
        }
        else if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            query = query.Where(r => r.GymId == adminGymId);
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only member or administrator accounts can access membership requests.");
        }

        if (gymId.HasValue)
        {
            query = query.Where(r => r.GymId == gymId.Value);
        }

        if (userId.HasValue)
        {
            query = query.Where(r => r.UserId == userId.Value);
        }

        if (!string.IsNullOrWhiteSpace(status)
            && Enum.TryParse<MembershipRequestStatus>(status, true, out var parsedStatus))
        {
            query = query.Where(r => r.Status == parsedStatus);
        }

        var requests = await query
            .OrderByDescending(r => r.RequestedAtUtc)
            .ToListAsync(cancellationToken);

        return requests.Select(MapRequest).ToList();
    }

    public async Task<MembershipPaymentResponse> PayMembershipRequestAsync(
        Guid requestId,
        Guid userId,
        MembershipPaymentRequest request,
        CancellationToken cancellationToken)
    {
        var membershipRequest = await _dbContext.MembershipRequests
            .FirstOrDefaultAsync(r => r.Id == requestId, cancellationToken);
        if (membershipRequest is null)
        {
            throw new UserException("Membership request not found.");
        }

        if (membershipRequest.UserId != userId)
        {
            throw new UserException("You can only pay for your own membership request.");
        }

        if (membershipRequest.Status != MembershipRequestStatus.Approved)
        {
            throw new UserException("Membership request must be approved before payment.");
        }

        if (membershipRequest.PaymentStatus == PaymentStatus.Paid)
        {
            throw new UserException("Membership request is already paid.");
        }

        var now = DateTime.UtcNow;
        var hasActiveMembership = await _dbContext.Memberships
            .AsNoTracking()
            .AnyAsync(m => m.UserId == userId
                && m.GymId == membershipRequest.GymId
                && m.Status == MembershipStatus.Active
                && m.EndDateUtc.Date >= now.Date, cancellationToken);
        if (hasActiveMembership)
        {
            throw new UserException("You already have an active membership for this gym.");
        }

        decimal planPrice = 0m;
        var durationMonths = 1;
        var plan = await ResolveMembershipPlanAsync(membershipRequest.GymId, membershipRequest.GymPlanId, cancellationToken);
        membershipRequest.GymPlanId = plan.Id;
        planPrice = plan.Price;
        durationMonths = Math.Max(1, plan.DurationMonths);

        var paymentMethod = PaymentMethod.Card;
        if (!string.IsNullOrWhiteSpace(request.PaymentMethod)
            && Enum.TryParse<PaymentMethod>(request.PaymentMethod, true, out var parsedMethod))
        {
            paymentMethod = parsedMethod;
        }

        var latestEnd = await _dbContext.Memberships
            .AsNoTracking()
            .Where(m => m.UserId == membershipRequest.UserId && m.GymId == membershipRequest.GymId)
            .OrderByDescending(m => m.EndDateUtc)
            .Select(m => (DateTime?)m.EndDateUtc)
            .FirstOrDefaultAsync(cancellationToken);
        var start = latestEnd.HasValue && latestEnd.Value > now ? latestEnd.Value : now;
        var membership = new Membership
        {
            Id = Guid.NewGuid(),
            UserId = membershipRequest.UserId,
            GymId = membershipRequest.GymId,
            GymPlanId = membershipRequest.GymPlanId,
            StartDateUtc = start,
            EndDateUtc = start.AddMonths(durationMonths),
            Status = MembershipStatus.Active
        };

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            Amount = planPrice,
            Method = paymentMethod,
            PaidAtUtc = now,
            MembershipId = membership.Id
        };

        membershipRequest.PaymentStatus = PaymentStatus.Paid;
        membershipRequest.PaidAtUtc = now;
        membershipRequest.PaymentId = payment.Id;

        _dbContext.Memberships.Add(membership);
        _dbContext.Payments.Add(payment);

        _dbContext.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = membershipRequest.UserId,
            Title = "Membership activated",
            Message = "Your membership payment was processed. Your pass is now active.",
            Category = "membership",
            IsRead = false,
            CreatedAtUtc = now
        });

        await _dbContext.SaveChangesAsync(cancellationToken);

        var qr = await _qrService.IssueAsync(membership.Id, membership.UserId, UserRole.User.ToString(), cancellationToken);

        return new MembershipPaymentResponse
        {
            Membership = MapMembership(membership),
            Qr = qr
        };
    }

    public async Task<IReadOnlyList<MembershipDto>> GetMembershipsAsync(
        Guid requesterId,
        string requesterRole,
        Guid? userId,
        CancellationToken cancellationToken)
    {
        var query = _dbContext.Memberships.AsNoTracking();

        if (string.Equals(requesterRole, UserRole.User.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(m => m.UserId == requesterId);
        }
        else if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            query = query.Where(m => m.GymId == gymId);
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only member or administrator accounts can access memberships.");
        }

        if (userId.HasValue)
        {
            query = query.Where(m => m.UserId == userId.Value);
        }

        var memberships = await query.ToListAsync(cancellationToken);
        return memberships.Select(MapMembership).ToList();
    }

    public async Task<ActiveMembershipResponse> GetActiveMembershipAsync(Guid userId, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var membership = await _dbContext.Memberships
            .AsNoTracking()
            .Include(m => m.Gym)
            .Include(m => m.GymPlan)
            .Where(m => m.UserId == userId)
            .OrderByDescending(m => m.EndDateUtc)
            .FirstOrDefaultAsync(cancellationToken);

        if (membership is not null && membership.Status == MembershipStatus.Active && membership.EndDateUtc.Date >= now.Date)
        {
            var remaining = (membership.EndDateUtc.Date - now.Date).Days;
            return new ActiveMembershipResponse
            {
                State = "Active",
                MembershipStatus = membership.Status.ToString(),
                MembershipId = membership.Id,
                GymId = membership.GymId,
                GymName = membership.Gym.Name,
                GymPlanId = membership.GymPlanId,
                PlanName = membership.GymPlan?.Name,
                StartDateUtc = membership.StartDateUtc,
                EndDateUtc = membership.EndDateUtc,
                RemainingDays = remaining
            };
        }

        var request = await _dbContext.MembershipRequests
            .AsNoTracking()
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.RequestedAtUtc)
            .FirstOrDefaultAsync(cancellationToken);

        if (request is not null)
        {
            var gymName = await _dbContext.Gyms
                .AsNoTracking()
                .Where(g => g.Id == request.GymId)
                .Select(g => g.Name)
                .FirstOrDefaultAsync(cancellationToken);
            return new ActiveMembershipResponse
            {
                State = request.Status == MembershipRequestStatus.Pending
                    ? "Pending"
                    : request.Status == MembershipRequestStatus.Approved && request.PaymentStatus != PaymentStatus.Paid
                        ? "Approved"
                        : request.Status == MembershipRequestStatus.Rejected
                            ? "Rejected"
                            : "None",
                RequestStatus = request.Status.ToString(),
                PaymentStatus = request.PaymentStatus.ToString(),
                CanPay = request.Status == MembershipRequestStatus.Approved && request.PaymentStatus == PaymentStatus.Unpaid,
                RequestId = request.Id,
                RequestedAtUtc = request.RequestedAtUtc,
                RejectedAtUtc = request.RejectedAtUtc,
                RejectionReason = request.RejectionReason,
                GymId = request.GymId,
                GymName = gymName,
                GymPlanId = request.GymPlanId
            };
        }

        if (membership is not null)
        {
            return new ActiveMembershipResponse
            {
                State = "Expired",
                MembershipStatus = membership.Status.ToString(),
                MembershipId = membership.Id,
                GymId = membership.GymId,
                GymName = membership.Gym.Name,
                GymPlanId = membership.GymPlanId,
                PlanName = membership.GymPlan?.Name,
                StartDateUtc = membership.StartDateUtc,
                EndDateUtc = membership.EndDateUtc,
                RemainingDays = 0
            };
        }

        return new ActiveMembershipResponse();
    }

    public async Task<bool> ValidateMembershipAsync(
        Guid membershipId,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var membership = await _dbContext.Memberships.AsNoTracking().FirstOrDefaultAsync(m => m.Id == membershipId, cancellationToken);
        if (membership is null)
        {
            return false;
        }

        await EnsureGymScopeAsync(membership.GymId, requesterId, requesterRole, cancellationToken);
        return membership.Status == MembershipStatus.Active && membership.EndDateUtc >= DateTime.UtcNow.Date;
    }

    private static MembershipRequestDto MapRequest(MembershipRequest request) => new()
    {
        Id = request.Id,
        UserId = request.UserId,
        GymId = request.GymId,
        GymPlanId = request.GymPlanId,
        Status = request.Status.ToString(),
        PaymentStatus = request.PaymentStatus.ToString(),
        ApprovedAtUtc = request.ApprovedAtUtc,
        ApprovedByUserId = request.ApprovedByUserId,
        RejectedAtUtc = request.RejectedAtUtc,
        RejectedByUserId = request.RejectedByUserId,
        RejectionReason = request.RejectionReason,
        PaidAtUtc = request.PaidAtUtc,
        PaymentId = request.PaymentId,
        RequestedAtUtc = request.RequestedAtUtc
    };

    private static MembershipDto MapMembership(Membership membership) => new()
    {
        Id = membership.Id,
        UserId = membership.UserId,
        GymId = membership.GymId,
        GymPlanId = membership.GymPlanId,
        StartDateUtc = membership.StartDateUtc,
        EndDateUtc = membership.EndDateUtc,
        Status = membership.Status.ToString()
    };

    private async Task<GymPlan> ResolveMembershipPlanAsync(Guid gymId, Guid? requestedPlanId, CancellationToken cancellationToken)
    {
        var plan = await TryResolveMembershipPlanAsync(gymId, requestedPlanId, cancellationToken);
        if (plan is null)
        {
            plan = await EnsureDefaultMembershipPlanAsync(gymId, cancellationToken);
        }

        return plan;
    }

    private async Task<GymPlan?> TryResolveMembershipPlanAsync(Guid gymId, Guid? requestedPlanId, CancellationToken cancellationToken)
    {
        GymPlan? plan = null;

        if (requestedPlanId.HasValue)
        {
            plan = await _dbContext.GymPlans
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    p => p.Id == requestedPlanId.Value && p.GymId == gymId && p.IsActive,
                    cancellationToken);
        }

        plan ??= await _dbContext.GymPlans
            .AsNoTracking()
            .Where(p => p.GymId == gymId && p.IsActive)
            .OrderBy(p => p.Price)
            .ThenBy(p => p.DurationMonths)
            .FirstOrDefaultAsync(cancellationToken);

        return plan;
    }

    private async Task<GymPlan> EnsureDefaultMembershipPlanAsync(Guid gymId, CancellationToken cancellationToken)
    {
        var template = await _dbContext.GymPlans
            .AsNoTracking()
            .Where(p => p.IsActive && p.Price > 0m && p.DurationMonths > 0)
            .OrderBy(p => p.Price)
            .ThenBy(p => p.DurationMonths)
            .FirstOrDefaultAsync(cancellationToken);

        var fallbackPrice = template?.Price ?? DefaultMembershipPlanPrice;
        var fallbackDurationMonths = template?.DurationMonths ?? DefaultMembershipPlanDurationMonths;
        var fallbackName = string.IsNullOrWhiteSpace(template?.Name)
            ? DefaultMembershipPlanName
            : template.Name;
        var fallbackDescription = string.IsNullOrWhiteSpace(template?.Description)
            ? DefaultMembershipPlanDescription
            : template.Description;

        var existing = await _dbContext.GymPlans
            .Where(p => p.GymId == gymId)
            .OrderByDescending(p => p.IsActive)
            .ThenBy(p => p.Price)
            .ThenBy(p => p.DurationMonths)
            .FirstOrDefaultAsync(cancellationToken);

        if (existing is not null)
        {
            var changed = false;
            if (!existing.IsActive)
            {
                existing.IsActive = true;
                changed = true;
            }
            if (existing.Price <= 0m)
            {
                existing.Price = fallbackPrice;
                changed = true;
            }
            if (existing.DurationMonths <= 0)
            {
                existing.DurationMonths = fallbackDurationMonths;
                changed = true;
            }
            if (string.IsNullOrWhiteSpace(existing.Name))
            {
                existing.Name = fallbackName;
                changed = true;
            }

            if (changed)
            {
                await _dbContext.SaveChangesAsync(cancellationToken);
            }

            return existing;
        }

        var plan = new GymPlan
        {
            Id = Guid.NewGuid(),
            GymId = gymId,
            Name = fallbackName,
            Description = fallbackDescription,
            Price = fallbackPrice,
            DurationMonths = fallbackDurationMonths,
            IsActive = true
        };

        _dbContext.GymPlans.Add(plan);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return plan;
    }

    private async Task<Guid> GetGymIdForAdminAsync(Guid adminUserId, CancellationToken cancellationToken)
    {
        var admin = await _dbContext.GymAdministrators
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.UserId == adminUserId, cancellationToken);

        if (admin is null)
        {
            throw new InvalidOperationException("Gym administrator is not assigned to a gym.");
        }

        return admin.GymId;
    }

    private async Task EnsureGymScopeAsync(Guid gymId, Guid requesterId, string requesterRole, CancellationToken cancellationToken)
    {
        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            if (adminGymId != gymId)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }
    }
}
