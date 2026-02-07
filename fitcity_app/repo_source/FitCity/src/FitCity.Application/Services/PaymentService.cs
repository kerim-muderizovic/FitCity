using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class PaymentService : IPaymentService
{
    private readonly FitCityDbContext _dbContext;

    public PaymentService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<AdminPaymentDto>> GetPaymentsAsync(
        Guid requesterId,
        string requesterRole,
        DateTime? fromUtc,
        DateTime? toUtc,
        string? query,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only Central Administrators can access payments.");
        }

        var paymentsQuery = _dbContext.Payments
            .AsNoTracking()
            .Include(p => p.Membership)
                .ThenInclude(m => m.User)
            .Include(p => p.Membership)
                .ThenInclude(m => m.Gym)
            .Include(p => p.TrainingSession)
                .ThenInclude(s => s.User)
            .Include(p => p.TrainingSession)
                .ThenInclude(s => s.Gym)
            .AsQueryable();

        if (fromUtc.HasValue)
        {
            paymentsQuery = paymentsQuery.Where(p => p.PaidAtUtc >= fromUtc.Value);
        }

        if (toUtc.HasValue)
        {
            paymentsQuery = paymentsQuery.Where(p => p.PaidAtUtc <= toUtc.Value);
        }

        if (!string.IsNullOrWhiteSpace(query))
        {
            var term = query.Trim().ToLower();
            paymentsQuery = paymentsQuery.Where(p =>
                (p.Membership != null && p.Membership.User.FullName.ToLower().Contains(term)) ||
                (p.TrainingSession != null && p.TrainingSession.User.FullName.ToLower().Contains(term)) ||
                (p.Membership != null && p.Membership.Gym.Name.ToLower().Contains(term)) ||
                (p.TrainingSession != null && p.TrainingSession.Gym.Name.ToLower().Contains(term)) ||
                p.Method.ToString().ToLower().Contains(term));
        }

        var payments = await paymentsQuery
            .OrderByDescending(p => p.PaidAtUtc)
            .Take(200)
            .ToListAsync(cancellationToken);

        return payments.Select(p =>
        {
            var isMembership = p.Membership != null;
            var isSession = p.TrainingSession != null;
            var member = isMembership ? p.Membership!.User : p.TrainingSession?.User;
            var gym = isMembership ? p.Membership!.Gym : p.TrainingSession?.Gym;
            var status = "Paid";
            if (p.TrainingSession != null)
            {
                status = p.TrainingSession.PaymentStatus.ToString();
            }

            return new AdminPaymentDto
            {
                Id = p.Id,
                Amount = p.Amount,
                Method = p.Method.ToString(),
                PaidAtUtc = p.PaidAtUtc,
                Type = isMembership ? "Membership" : isSession ? "TrainingSession" : "Payment",
                MemberId = member?.Id,
                MemberName = member?.FullName,
                GymId = gym?.Id,
                GymName = gym?.Name,
                ReferenceId = isMembership ? p.MembershipId : p.TrainingSessionId,
                Status = status
            };
        }).ToList();
    }
}
