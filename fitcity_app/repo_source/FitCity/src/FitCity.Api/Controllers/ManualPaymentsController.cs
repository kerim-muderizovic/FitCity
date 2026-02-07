using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/payments/manual")]
public class ManualPaymentsController : ControllerBase
{
    private readonly IMembershipService _membershipService;
    private readonly IBookingService _bookingService;

    public ManualPaymentsController(IMembershipService membershipService, IBookingService bookingService)
    {
        _membershipService = membershipService;
        _bookingService = bookingService;
    }

    [HttpPost("memberships/{requestId:guid}/pay")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<MembershipPaymentResponse>> PayMembership(Guid requestId, CancellationToken cancellationToken)
    {
        if (!IsManualPaymentsEnabled())
        {
            return BadRequest(new { error = "Manual payments are disabled." });
        }

        var userId = User.GetUserId();
        var response = await _membershipService.PayMembershipRequestAsync(
            requestId,
            userId,
            new MembershipPaymentRequest { PaymentMethod = "Card" },
            cancellationToken);
        return Ok(response);
    }

    [HttpPost("bookings/{bookingId:guid}/pay")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<BookingDto>> PayBooking(Guid bookingId, CancellationToken cancellationToken)
    {
        if (!IsManualPaymentsEnabled())
        {
            return BadRequest(new { error = "Manual payments are disabled." });
        }

        var userId = User.GetUserId();
        var response = await _bookingService.PayBookingAsync(bookingId, userId, cancellationToken);
        return Ok(response);
    }

    private static bool IsManualPaymentsEnabled()
    {
        var flag = Environment.GetEnvironmentVariable("ALLOW_FAKE_PAYMENTS");
        return string.Equals(flag, "true", StringComparison.OrdinalIgnoreCase);
    }
}
