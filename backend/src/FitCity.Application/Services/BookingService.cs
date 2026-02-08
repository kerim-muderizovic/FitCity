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

public class BookingService : IBookingService
{
    private readonly FitCityDbContext _dbContext;
    private readonly IEmailQueueService _emailQueueService;
    private readonly IChatService _chatService;
    private readonly ILogger<BookingService> _logger;

    public BookingService(
        FitCityDbContext dbContext,
        IEmailQueueService emailQueueService,
        IChatService chatService,
        ILogger<BookingService> logger)
    {
        _dbContext = dbContext;
        _emailQueueService = emailQueueService;
        _chatService = chatService;
        _logger = logger;
    }

    public async Task<BookingDto> CreateAsync(Guid userId, BookingCreateRequest request, CancellationToken cancellationToken)
    {
        var startUtc = NormalizeUtc(request.StartUtc);
        var endUtc = NormalizeUtc(request.EndUtc);
        if (startUtc >= endUtc)
        {
            _logger.LogWarning("Invalid booking time range: {StartUtc} - {EndUtc}", startUtc, endUtc);
            throw new ConflictException("Invalid time range.", "InvalidTimeRange");
        }

        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == request.TrainerId, cancellationToken);
        if (trainer is null)
        {
            throw new UserException("Trainer not found.");
        }

        if (request.GymId.HasValue)
        {
            var inGym = await _dbContext.GymTrainers
                .AsNoTracking()
                .AnyAsync(gt => gt.TrainerId == request.TrainerId && gt.GymId == request.GymId.Value, cancellationToken);
            if (!inGym)
            {
                _logger.LogWarning("Booking gym mismatch: TrainerId={TrainerId} GymId={GymId}", request.TrainerId, request.GymId);
                throw new ConflictException("Trainer does not work at the selected location.", "MismatchedGym");
            }
        }

        TrainerSchedule? schedule = await _dbContext.TrainerSchedules
            .FirstOrDefaultAsync(s => s.TrainerId == request.TrainerId
                                      && s.IsAvailable
                                      && (!request.GymId.HasValue || s.GymId == null || s.GymId == request.GymId)
                                      && startUtc >= s.StartUtc
                                      && endUtc <= s.EndUtc, cancellationToken);

        var hasScheduleInRange = await _dbContext.TrainerSchedules
            .AsNoTracking()
            .AnyAsync(s => s.TrainerId == request.TrainerId
                           && s.StartUtc < endUtc
                           && s.EndUtc > startUtc, cancellationToken);

        if (schedule is null)
        {
            var withinDefault = IsWithinDefaultSchedule(startUtc, endUtc);
            if (hasScheduleInRange || !withinDefault)
            {
                _logger.LogWarning(
                    "Trainer unavailable for booking: TrainerId={TrainerId} StartUtc={StartUtc} EndUtc={EndUtc} GymId={GymId} HasScheduleInRange={HasScheduleInRange} WithinDefault={WithinDefault}",
                    request.TrainerId,
                    startUtc,
                    endUtc,
                    request.GymId,
                    hasScheduleInRange,
                    withinDefault);
                throw new ConflictException("Trainer is not available for that time.", "OutsideSchedule");
            }
        }

        using var transaction = await _dbContext.Database.BeginTransactionAsync(System.Data.IsolationLevel.Serializable, cancellationToken);

        var hasConflict = await _dbContext.TrainingSessions
            .AnyAsync(s => s.TrainerId == request.TrainerId
                           && s.Status != TrainingSessionStatus.Cancelled
                           && s.StartUtc < endUtc
                           && s.EndUtc > startUtc, cancellationToken);

        if (hasConflict)
        {
            _logger.LogWarning(
                "Booking conflict detected: TrainerId={TrainerId} StartUtc={StartUtc} EndUtc={EndUtc}",
                request.TrainerId,
                startUtc,
                endUtc);
            throw new ConflictException("Trainer is already booked for that time.", "SlotTaken");
        }

        var paymentMethod = PaymentMethod.Cash;
        if (!string.IsNullOrWhiteSpace(request.PaymentMethod)
            && Enum.TryParse<PaymentMethod>(request.PaymentMethod, true, out var parsedPayment))
        {
            paymentMethod = parsedPayment;
        }

        var durationHours = Math.Max(0, (endUtc - startUtc).TotalHours);
        var price = trainer.HourlyRate.HasValue ? trainer.HourlyRate.Value * (decimal)durationHours : 0m;

        var session = new TrainingSession
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TrainerId = request.TrainerId,
            GymId = request.GymId,
            StartUtc = startUtc,
            EndUtc = endUtc,
            Status = TrainingSessionStatus.Pending,
            PaymentMethod = paymentMethod,
            PaymentStatus = PaymentStatus.Unpaid,
            Price = price
        };

        if (schedule != null)
        {
            schedule.IsAvailable = false;
        }
        _dbContext.TrainingSessions.Add(session);
        _dbContext.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Title = "Booking requested",
            Message = $"Your booking request for {request.StartUtc:MMM dd, HH:mm} has been submitted.",
            Category = "booking",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        });
        await _dbContext.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        await SendBookingChatMessageAsync(userId, trainer.UserId, session, cancellationToken);

        return Map(session, trainer.UserId, trainer.User.FullName, await ResolveGymNameAsync(session.GymId, cancellationToken));
    }

    private static bool IsWithinDefaultSchedule(DateTime startUtc, DateTime endUtc)
    {
        var timeZone = TimeZoneInfo.Local;
        var startLocal = TimeZoneInfo.ConvertTimeFromUtc(startUtc, timeZone);
        var endLocal = TimeZoneInfo.ConvertTimeFromUtc(endUtc, timeZone);

        if (startLocal.DayOfWeek == DayOfWeek.Sunday || endLocal.DayOfWeek == DayOfWeek.Sunday)
        {
            return false;
        }

        if (startLocal.Date != endLocal.Date)
        {
            return false;
        }

        var duration = endLocal - startLocal;
        if (duration != TimeSpan.FromHours(1))
        {
            return false;
        }

        var startMinutes = startLocal.Hour * 60 + startLocal.Minute;
        var endMinutes = endLocal.Hour * 60 + endLocal.Minute;
        return startMinutes >= 8 * 60 && endMinutes <= 16 * 60;
    }

    private static DateTime NormalizeUtc(DateTime value)
    {
        var utc = value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
        };

        return new DateTime(
            utc.Year,
            utc.Month,
            utc.Day,
            utc.Hour,
            utc.Minute,
            0,
            0,
            DateTimeKind.Utc);
    }

    public async Task<BookingDto?> UpdateStatusAsync(
        Guid bookingId,
        bool confirm,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var session = await _dbContext.TrainingSessions.FirstOrDefaultAsync(s => s.Id == bookingId, cancellationToken);
        if (session is null)
        {
            return null;
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            if (session.GymId != gymId)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }
        else if (string.Equals(requesterRole, UserRole.Trainer.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var trainerId = await GetTrainerIdForUserAsync(requesterId, cancellationToken);
            if (trainerId != session.TrainerId)
            {
                throw new InvalidOperationException("Trainers can only update their own bookings.");
            }
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only trainers or administrators can update bookings.");
        }

        session.Status = confirm ? TrainingSessionStatus.Confirmed : TrainingSessionStatus.Cancelled;
        await _dbContext.SaveChangesAsync(cancellationToken);

        if (confirm)
        {
            var user = await _dbContext.Users.AsNoTracking()
                .FirstOrDefaultAsync(u => u.Id == session.UserId, cancellationToken);

            if (user is not null)
            {
                await _emailQueueService.SendEmailAsync(new EmailMessage
                {
                    EmailTo = user.Email,
                    ReceiverName = user.FullName,
                    Subject = "Your booking is confirmed",
                    Message = "Your training session booking has been confirmed."
                }, cancellationToken);
            }
        }

        _dbContext.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = session.UserId,
            Title = confirm ? "Booking confirmed" : "Booking cancelled",
            Message = confirm
                ? "Your training session has been confirmed."
                : "Your training session has been cancelled.",
            Category = "booking",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        });

        await _dbContext.SaveChangesAsync(cancellationToken);
        return await MapBookingAsync(session, cancellationToken);
    }

    public async Task<IReadOnlyList<BookingDto>> GetHistoryAsync(Guid userId, CancellationToken cancellationToken)
    {
        var sessions = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => s.UserId == userId)
            .OrderByDescending(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        return await MapBookingsAsync(sessions, cancellationToken);
    }

    public async Task<IReadOnlyList<BookingDto>> GetByStatusAsync(Guid userId, string? status, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var query = _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => s.UserId == userId);

        if (string.Equals(status, "upcoming", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(s => s.StartUtc >= now
                                     && (s.Status == TrainingSessionStatus.Pending || s.Status == TrainingSessionStatus.Confirmed));
        }
        else if (string.Equals(status, "past", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(s => s.EndUtc < now
                                     || s.Status == TrainingSessionStatus.Cancelled
                                     || s.Status == TrainingSessionStatus.Completed);
        }

        var sessions = await query
            .OrderByDescending(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        return await MapBookingsAsync(sessions, cancellationToken);
    }

    public async Task<BookingDto> PayBookingAsync(Guid bookingId, Guid userId, CancellationToken cancellationToken)
    {
        var session = await _dbContext.TrainingSessions
            .FirstOrDefaultAsync(s => s.Id == bookingId, cancellationToken);
        if (session is null)
        {
            throw new UserException("Booking not found.");
        }

        if (session.UserId != userId)
        {
            throw new UserException("You can only pay for your own booking.");
        }

        if (session.PaymentMethod != PaymentMethod.Card && session.PaymentMethod != PaymentMethod.PayPal)
        {
            throw new UserException("Only card or PayPal bookings can be paid online.");
        }

        if (session.PaymentStatus == PaymentStatus.Paid)
        {
            throw new UserException("Booking is already paid.");
        }

        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            Amount = session.Price,
            Method = session.PaymentMethod,
            PaidAtUtc = DateTime.UtcNow,
            TrainingSessionId = session.Id
        };

        session.PaymentStatus = PaymentStatus.Paid;
        session.PaidAtUtc = payment.PaidAtUtc;
        _dbContext.Payments.Add(payment);

        _dbContext.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = session.UserId,
            Title = "Booking payment received",
            Message = "Your booking payment was processed successfully.",
            Category = "booking",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        });

        await _dbContext.SaveChangesAsync(cancellationToken);

        await SendPaymentChatMessageAsync(session, cancellationToken);

        return await MapBookingAsync(session, cancellationToken);
    }

    private async Task<List<BookingDto>> MapBookingsAsync(List<TrainingSession> sessions, CancellationToken cancellationToken)
    {
        var trainerIds = sessions.Select(s => s.TrainerId).Distinct().ToList();
        var trainers = await _dbContext.Trainers
            .AsNoTracking()
            .Where(t => trainerIds.Contains(t.Id))
            .Include(t => t.User)
            .ToListAsync(cancellationToken);

        var trainerLookup = trainers.ToDictionary(t => t.Id, t => t);
        var gymIds = sessions.Where(s => s.GymId.HasValue).Select(s => s.GymId!.Value).Distinct().ToList();
        var gyms = await _dbContext.Gyms
            .AsNoTracking()
            .Where(g => gymIds.Contains(g.Id))
            .ToDictionaryAsync(g => g.Id, g => g.Name, cancellationToken);

        return sessions.Select(session =>
        {
            trainerLookup.TryGetValue(session.TrainerId, out var trainer);
            gyms.TryGetValue(session.GymId ?? Guid.Empty, out var gymName);
            return Map(session, trainer?.UserId ?? Guid.Empty, trainer?.User.FullName ?? string.Empty, gymName);
        }).ToList();
    }

    private async Task<BookingDto> MapBookingAsync(TrainingSession session, CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == session.TrainerId, cancellationToken);
        var gymName = await ResolveGymNameAsync(session.GymId, cancellationToken);
        return Map(session, trainer?.UserId ?? Guid.Empty, trainer?.User.FullName ?? string.Empty, gymName);
    }

    private static BookingDto Map(TrainingSession session, Guid trainerUserId, string trainerName, string? gymName) => new()
    {
        Id = session.Id,
        UserId = session.UserId,
        TrainerId = session.TrainerId,
        TrainerUserId = trainerUserId,
        TrainerName = trainerName,
        GymId = session.GymId,
        GymName = gymName,
        StartUtc = session.StartUtc,
        EndUtc = session.EndUtc,
        Status = session.Status.ToString(),
        PaymentMethod = session.PaymentMethod.ToString(),
        PaymentStatus = session.PaymentStatus.ToString(),
        Price = session.Price,
        PaidAtUtc = session.PaidAtUtc
    };

    private async Task<string?> ResolveGymNameAsync(Guid? gymId, CancellationToken cancellationToken)
    {
        if (!gymId.HasValue)
        {
            return null;
        }
        return await _dbContext.Gyms.AsNoTracking()
            .Where(g => g.Id == gymId.Value)
            .Select(g => g.Name)
            .FirstOrDefaultAsync(cancellationToken);
    }

    private async Task SendBookingChatMessageAsync(
        Guid memberUserId,
        Guid trainerUserId,
        TrainingSession session,
        CancellationToken cancellationToken)
    {
        var gymName = await ResolveGymNameAsync(session.GymId, cancellationToken);
        var when = session.StartUtc.ToLocalTime().ToString("MMM dd, HH:mm");
        var paymentLabel = session.PaymentMethod == PaymentMethod.Cash ? "Cash" : "Card";
        var message = $"Hi, I booked training with you for {when}{(gymName == null ? string.Empty : $" at {gymName}")}. Payment method: {paymentLabel}.";

        var conversation = await _chatService.CreateConversationAsync(memberUserId, new ConversationCreateRequest
        {
            OtherUserId = trainerUserId,
            Title = "Training booking"
        }, cancellationToken);

        await _chatService.SendMessageAsync(memberUserId, new MessageCreateRequest
        {
            ConversationId = conversation.Id,
            Content = message
        }, cancellationToken);
    }

    private async Task SendPaymentChatMessageAsync(TrainingSession session, CancellationToken cancellationToken)
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

    private async Task<Guid> GetTrainerIdForUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.UserId == userId, cancellationToken);

        if (trainer is null)
        {
            throw new InvalidOperationException("Trainer profile not found.");
        }

        return trainer.Id;
    }
}
