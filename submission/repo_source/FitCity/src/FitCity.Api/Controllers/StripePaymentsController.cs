using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Api.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/payments/stripe")]
public class StripePaymentsController : ControllerBase
{
    private readonly IStripePaymentService _stripePaymentService;

    public StripePaymentsController(IStripePaymentService stripePaymentService)
    {
        _stripePaymentService = stripePaymentService;
    }

    [HttpPost("memberships/{requestId:guid}/checkout")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<StripeCheckoutResponse>> CreateMembershipCheckout(
        Guid requestId,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var response = await _stripePaymentService.CreateMembershipCheckoutAsync(requestId, userId, cancellationToken);
        return Ok(response);
    }

    [HttpPost("bookings/{bookingId:guid}/checkout")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<StripeCheckoutResponse>> CreateBookingCheckout(
        Guid bookingId,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var response = await _stripePaymentService.CreateBookingCheckoutAsync(bookingId, userId, cancellationToken);
        return Ok(response);
    }
}
