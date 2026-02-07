using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IPaymentService
{
    Task<IReadOnlyList<AdminPaymentDto>> GetPaymentsAsync(
        Guid requesterId,
        string requesterRole,
        DateTime? fromUtc,
        DateTime? toUtc,
        string? query,
        CancellationToken cancellationToken);
}
