using FitCity.Application.DTOs;
using FitCity.Application.Exceptions;
using FitCity.Application.Interfaces;
using FitCity.Application.Messaging;
using FitCity.Application.Options;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Stripe;
using Stripe.Checkout;
using PaymentMethod = FitCity.Domain.Enums.PaymentMethod;

namespace FitCity.Application.Services;

public class StripePaymentService : IStripePaymentService
{
    private const decimal DefaultMembershipPlanPrice = 49.99m;
    private const int DefaultMembershipPlanDurationMonths = 1;
    private const string DefaultMembershipPlanName = "Standard Membership";
    private const string DefaultMembershipPlanDescription = "Auto-created default membership plan.";

    private readonly FitCityDbContext _dbContext;
    private readonly IEmailQueueService _emailQueueService;
    private readonly IChatService _chatService;
    private readonly StripeOptions _options;
    private readonly ILogger<StripePaymentService> _logger;

    public StripePaymentService(
        FitCityDbContext dbContext,
        IEmailQueueService emailQueueService,
        IChatService chatService,
        IOptions<StripeOptions> options,
        ILogger<StripePaymentService> logger)
    {
        _dbContext = dbContext;
        _emailQueueService = emailQueueService;
        _chatService = chatService;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<StripeCheckoutResponse> CreateMembershipCheckoutAsync(
        Guid requestId,
        Guid userId,
        CancellationToken cancellationToken,
        string? requestOrigin = null)
    {
        EnsureStripeConfigured();

        var request = await _dbContext.MembershipRequests
            .FirstOrDefaultAsync(r => r.Id == requestId, cancellationToken);
        if (request is null)
        {
            throw new UserException("Membership request not found.");
        }

        if (request.UserId != userId)
        {
            throw new UserException("You can only pay for your own membership request.");
        }

        if (request.Status != MembershipRequestStatus.Approved)
        {
            throw new UserException("Membership request must be approved before payment.");
        }

        if (request.PaymentStatus == PaymentStatus.Paid)
        {
            throw new UserException("Membership request is already paid.");
        }

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

        var plan = await ResolveMembershipPlanAsync(request, cancellationToken);
        var planPrice = plan.Price;
        if (planPrice <= 0m)
        {
            throw new UserException("Membership plan price is not available.");
        }

        var gymName = await _dbContext.Gyms.AsNoTracking()
            .Where(g => g.Id == request.GymId)
            .Select(g => g.Name)
            .FirstOrDefaultAsync(cancellationToken);
        var userEmail = await _dbContext.Users.AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => u.Email)
            .FirstOrDefaultAsync(cancellationToken);

        var session = await CreateCheckoutSessionAsync(
            amount: planPrice,
            description: $"Membership {plan?.Name ?? "Plan"}{(gymName == null ? string.Empty : $" - {gymName}")}",
            customerEmail: userEmail,
            metadata: new Dictionary<string, string>
            {
                ["type"] = "membership",
                ["requestId"] = request.Id.ToString(),
                ["userId"] = userId.ToString(),
                ["gymId"] = request.GymId.ToString(),
                ["planId"] = plan.Id.ToString()
            },
            requestOrigin: requestOrigin,
            cancellationToken: cancellationToken);

        return new StripeCheckoutResponse { Url = session.Url ?? string.Empty };
    }

    public async Task<StripeCheckoutResponse> CreateBookingCheckoutAsync(
        Guid bookingId,
        Guid userId,
        CancellationToken cancellationToken,
        string? requestOrigin = null)
    {
        EnsureStripeConfigured();

        var booking = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Include(s => s.Trainer)
                .ThenInclude(t => t.User)
            .FirstOrDefaultAsync(s => s.Id == bookingId, cancellationToken);
        if (booking is null)
        {
            throw new UserException("Booking not found.");
        }

        if (booking.UserId != userId)
        {
            throw new UserException("You can only pay for your own booking.");
        }

        if (booking.PaymentStatus == PaymentStatus.Paid)
        {
            throw new UserException("Booking is already paid.");
        }

        if (booking.PaymentMethod != PaymentMethod.Card)
        {
            throw new UserException("Only card bookings can be paid online.");
        }

        var userEmail = await _dbContext.Users.AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => u.Email)
            .FirstOrDefaultAsync(cancellationToken);

        var trainerName = booking.Trainer?.User?.FullName ?? "Trainer";
        var gymName = await _dbContext.Gyms.AsNoTracking()
            .Where(g => g.Id == booking.GymId)
            .Select(g => g.Name)
            .FirstOrDefaultAsync(cancellationToken);

        var session = await CreateCheckoutSessionAsync(
            amount: booking.Price,
            description: $"Training session with {trainerName}{(gymName == null ? string.Empty : $" - {gymName}")}",
            customerEmail: userEmail,
            metadata: new Dictionary<string, string>
            {
                ["type"] = "booking",
                ["bookingId"] = booking.Id.ToString(),
                ["userId"] = userId.ToString(),
                ["gymId"] = booking.GymId?.ToString() ?? string.Empty
            },
            requestOrigin: requestOrigin,
            cancellationToken: cancellationToken);

        return new StripeCheckoutResponse { Url = session.Url ?? string.Empty };
    }

    public async Task HandleWebhookAsync(string payload, string signatureHeader, CancellationToken cancellationToken)
    {
        EnsureStripeConfigured();

        Event stripeEvent;
        try
        {
            stripeEvent = EventUtility.ConstructEvent(
                payload,
                signatureHeader,
                _options.WebhookSecret,
                throwOnApiVersionMismatch: false);
        }
        catch (StripeException ex)
        {
            _logger.LogWarning(ex, "Stripe webhook signature validation failed.");
            throw new UserException("Invalid payment signature.");
        }
        if (stripeEvent is null)
        {
            return;
        }

        if (!string.Equals(stripeEvent.Type, Events.CheckoutSessionCompleted, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (stripeEvent.Data.Object is not Session session)
        {
            return;
        }

        if (string.Equals(session.PaymentStatus, "unpaid", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        var metadata = session.Metadata ?? new Dictionary<string, string>();
        if (!metadata.TryGetValue("type", out var type) || string.IsNullOrWhiteSpace(type))
        {
            _logger.LogWarning("Stripe webhook missing type metadata. Session {SessionId}", session.Id);
            return;
        }

        if (await _dbContext.Payments.AnyAsync(p => p.ProviderEventId == stripeEvent.Id, cancellationToken))
        {
            return;
        }

        if (string.Equals(type, "membership", StringComparison.OrdinalIgnoreCase))
        {
            await HandleMembershipPaymentAsync(session, stripeEvent.Id, cancellationToken);
        }
        else if (string.Equals(type, "booking", StringComparison.OrdinalIgnoreCase))
        {
            await HandleBookingPaymentAsync(session, stripeEvent.Id, cancellationToken);
        }
    }

    private async Task HandleMembershipPaymentAsync(Session session, string eventId, CancellationToken cancellationToken)
    {
        if (!session.Metadata.TryGetValue("requestId", out var requestIdRaw)
            || !Guid.TryParse(requestIdRaw, out var requestId))
        {
            _logger.LogWarning("Stripe membership payment missing requestId metadata.");
            return;
        }

        var request = await _dbContext.MembershipRequests
            .FirstOrDefaultAsync(r => r.Id == requestId, cancellationToken);
        if (request is null)
        {
            return;
        }

        if (request.PaymentStatus == PaymentStatus.Paid)
        {
            return;
        }

        if (request.Status != MembershipRequestStatus.Approved)
        {
            _logger.LogWarning("Stripe payment received for non-approved request {RequestId}.", requestId);
            return;
        }

        var now = DateTime.UtcNow;
        var plan = await ResolveMembershipPlanAsync(request, cancellationToken);
        var planPrice = plan.Price;
        var durationMonths = plan.DurationMonths;

        var latestEnd = await _dbContext.Memberships
            .AsNoTracking()
            .Where(m => m.UserId == request.UserId && m.GymId == request.GymId)
            .OrderByDescending(m => m.EndDateUtc)
            .Select(m => (DateTime?)m.EndDateUtc)
            .FirstOrDefaultAsync(cancellationToken);

        var start = latestEnd.HasValue && latestEnd.Value > now ? latestEnd.Value : now;
        var end = start.AddMonths(Math.Max(1, durationMonths));

        var membership = new Membership
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            GymId = request.GymId,
            GymPlanId = plan.Id,
            StartDateUtc = start,
            EndDateUtc = end,
            Status = MembershipStatus.Active
        };

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            Amount = planPrice,
            Method = PaymentMethod.Card,
            PaidAtUtc = now,
            MembershipId = membership.Id,
            Provider = "Stripe",
            ProviderSessionId = session.Id,
            ProviderPaymentIntentId = session.PaymentIntentId,
            ProviderEventId = eventId
        };

        request.PaymentStatus = PaymentStatus.Paid;
        request.PaidAtUtc = now;
        request.PaymentId = payment.Id;

        _dbContext.Memberships.Add(membership);
        _dbContext.Payments.Add(payment);
        _dbContext.PaymentAudits.Add(new PaymentAudit
        {
            Id = Guid.NewGuid(),
            EventType = "MembershipPaymentSuccess",
            UserId = request.UserId,
            GymId = request.GymId,
            GymPlanId = plan.Id,
            Amount = planPrice,
            Provider = "Stripe",
            CreatedAtUtc = now
        });

        _dbContext.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            Title = "Membership activated",
            Message = "Your membership payment was confirmed. Your pass is now active.",
            Category = "membership",
            IsRead = false,
            CreatedAtUtc = now
        });

        await _dbContext.SaveChangesAsync(cancellationToken);
        await SendMembershipEmailAsync(request, cancellationToken);
    }

    private async Task HandleBookingPaymentAsync(Session session, string eventId, CancellationToken cancellationToken)
    {
        if (!session.Metadata.TryGetValue("bookingId", out var bookingIdRaw)
            || !Guid.TryParse(bookingIdRaw, out var bookingId))
        {
            _logger.LogWarning("Stripe booking payment missing bookingId metadata.");
            return;
        }

        var booking = await _dbContext.TrainingSessions
            .FirstOrDefaultAsync(s => s.Id == bookingId, cancellationToken);
        if (booking is null)
        {
            return;
        }

        if (booking.PaymentStatus == PaymentStatus.Paid)
        {
            return;
        }

        var now = DateTime.UtcNow;
        booking.PaymentStatus = PaymentStatus.Paid;
        booking.PaidAtUtc = now;

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            Amount = booking.Price,
            Method = booking.PaymentMethod,
            PaidAtUtc = now,
            TrainingSessionId = booking.Id,
            Provider = "Stripe",
            ProviderSessionId = session.Id,
            ProviderPaymentIntentId = session.PaymentIntentId,
            ProviderEventId = eventId
        };

        _dbContext.Payments.Add(payment);
        _dbContext.PaymentAudits.Add(new PaymentAudit
        {
            Id = Guid.NewGuid(),
            EventType = "TrainingPaymentSuccess",
            UserId = booking.UserId,
            GymId = booking.GymId ?? Guid.Empty,
            GymPlanId = null,
            Amount = booking.Price,
            Provider = "Stripe",
            CreatedAtUtc = now
        });

        _dbContext.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = booking.UserId,
            Title = "Booking payment received",
            Message = "Your booking payment was processed successfully.",
            Category = "booking",
            IsRead = false,
            CreatedAtUtc = now
        });

        await _dbContext.SaveChangesAsync(cancellationToken);
        await SendBookingPaymentChatMessageAsync(booking, cancellationToken);
    }

    private async Task SendMembershipEmailAsync(MembershipRequest request, CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken);
        if (user is null)
        {
            return;
        }

        var gymName = await _dbContext.Gyms.AsNoTracking()
            .Where(g => g.Id == request.GymId)
            .Select(g => g.Name)
            .FirstOrDefaultAsync(cancellationToken);

        await _emailQueueService.SendEmailAsync(new EmailMessage
        {
            EmailTo = user.Email,
            ReceiverName = user.FullName,
            Subject = "Membership activated",
            Message = $"Your payment was confirmed. Your membership for {gymName ?? "the gym"} is now active."
        }, cancellationToken);
    }

    private async Task SendBookingPaymentChatMessageAsync(TrainingSession session, CancellationToken cancellationToken)
    {
        var trainerUserId = await _dbContext.Trainers
            .AsNoTracking()
            .Where(t => t.Id == session.TrainerId)
            .Select(t => t.UserId)
            .FirstOrDefaultAsync(cancellationToken);

        if (trainerUserId == Guid.Empty)
        {
            return;
        }

        var conversation = await _chatService.CreateConversationAsync(session.UserId, new ConversationCreateRequest
        {
            OtherUserId = trainerUserId,
            Title = "Training booking"
        }, cancellationToken);

        await _chatService.SendMessageAsync(session.UserId, new MessageCreateRequest
        {
            ConversationId = conversation.Id,
            Content = "Payment received for the booking."
        }, cancellationToken);
    }

    private async Task<Session> CreateCheckoutSessionAsync(
        decimal amount,
        string description,
        string? customerEmail,
        Dictionary<string, string> metadata,
        string? requestOrigin,
        CancellationToken cancellationToken)
    {
        var sessionService = new SessionService();
        StripeConfiguration.ApiKey = _options.SecretKey;

        var unitAmount = (long)Math.Round(amount * 100m, MidpointRounding.AwayFromZero);
        var successUrl = ResolveRedirectUrl(_options.SuccessUrl, "/payments/stripe/success", requestOrigin);
        var cancelUrl = ResolveRedirectUrl(_options.CancelUrl, "/payments/stripe/cancel", requestOrigin);
        var sessionIdSeparator = successUrl.Contains('?') ? "&" : "?";
        var options = new SessionCreateOptions
        {
            Mode = "payment",
            SuccessUrl = $"{successUrl}{sessionIdSeparator}session_id={{CHECKOUT_SESSION_ID}}",
            CancelUrl = cancelUrl,
            CustomerEmail = string.IsNullOrWhiteSpace(customerEmail) ? null : customerEmail,
            Metadata = metadata,
            LineItems = new List<SessionLineItemOptions>
            {
                new SessionLineItemOptions
                {
                    Quantity = 1,
                    PriceData = new SessionLineItemPriceDataOptions
                    {
                        Currency = _options.Currency,
                        UnitAmount = unitAmount,
                        ProductData = new SessionLineItemPriceDataProductDataOptions
                        {
                            Name = description
                        }
                    }
                }
            }
        };

        return await sessionService.CreateAsync(options, cancellationToken: cancellationToken);
    }

    private async Task<GymPlan> ResolveMembershipPlanAsync(MembershipRequest request, CancellationToken cancellationToken)
    {
        GymPlan? plan = null;
        if (request.GymPlanId.HasValue)
        {
            plan = await _dbContext.GymPlans
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    p => p.Id == request.GymPlanId.Value && p.GymId == request.GymId && p.IsActive,
                    cancellationToken);
        }

        plan ??= await _dbContext.GymPlans
            .AsNoTracking()
            .Where(p => p.GymId == request.GymId && p.IsActive)
            .OrderBy(p => p.Price)
            .ThenBy(p => p.DurationMonths)
            .FirstOrDefaultAsync(cancellationToken);

        if (plan is null)
        {
            plan = await EnsureDefaultMembershipPlanAsync(request.GymId, cancellationToken);
        }

        if (request.GymPlanId != plan.Id)
        {
            request.GymPlanId = plan.Id;
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

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

    private static string ResolveRedirectUrl(string configuredUrl, string defaultPath, string? requestOrigin)
    {
        var originUri = NormalizeOriginUri(requestOrigin);
        if (Uri.TryCreate(configuredUrl, UriKind.Absolute, out var configuredUri))
        {
            if (originUri is not null
                && IsLoopbackHost(configuredUri.Host)
                && !IsLoopbackHost(originUri.Host))
            {
                return $"{originUri.Scheme}://{originUri.Authority}{configuredUri.PathAndQuery}";
            }

            return configuredUri.ToString();
        }

        if (originUri is null)
        {
            throw new UserException("Payment redirect URL is not configured.");
        }

        var path = string.IsNullOrWhiteSpace(configuredUrl) ? defaultPath : configuredUrl.Trim();
        if (!path.StartsWith("/"))
        {
            path = "/" + path;
        }

        return $"{originUri.Scheme}://{originUri.Authority}{path}";
    }

    private static Uri? NormalizeOriginUri(string? requestOrigin)
    {
        if (string.IsNullOrWhiteSpace(requestOrigin))
        {
            return null;
        }

        return Uri.TryCreate(requestOrigin.Trim(), UriKind.Absolute, out var parsed) ? parsed : null;
    }

    private static bool IsLoopbackHost(string host)
    {
        if (string.IsNullOrWhiteSpace(host))
        {
            return false;
        }

        var normalized = host.Trim().Trim('[', ']').ToLowerInvariant();
        return normalized == "localhost"
            || normalized == "127.0.0.1"
            || normalized == "::1"
            || normalized == "0.0.0.0";
    }

    private void EnsureStripeConfigured()
    {
        if (string.IsNullOrWhiteSpace(_options.SecretKey)
            || string.IsNullOrWhiteSpace(_options.WebhookSecret))
        {
            throw new UserException("Payment provider is not configured.");
        }
    }
}
