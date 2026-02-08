using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IStripePaymentService
{
    Task<StripeCheckoutResponse> CreateMembershipCheckoutAsync(
        Guid requestId,
        Guid userId,
        CancellationToken cancellationToken,
        string? requestOrigin = null);
    Task<StripeCheckoutResponse> CreateBookingCheckoutAsync(
        Guid bookingId,
        Guid userId,
        CancellationToken cancellationToken,
        string? requestOrigin = null);
    Task<bool> FinalizeCheckoutSessionAsync(string? sessionId, CancellationToken cancellationToken);
    Task HandleWebhookAsync(string payload, string signatureHeader, CancellationToken cancellationToken);
}
