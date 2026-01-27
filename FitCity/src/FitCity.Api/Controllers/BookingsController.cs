using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/bookings")]
public class BookingsController : ControllerBase
{
    private readonly IBookingService _bookingService;

    public BookingsController(IBookingService bookingService)
    {
        _bookingService = bookingService;
    }

    [HttpPost]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<BookingDto>> Create([FromBody] BookingCreateRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var booking = await _bookingService.CreateAsync(userId, request, cancellationToken);
        return Ok(booking);
    }

    [HttpPost("{id:guid}/pay")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<BookingDto>> Pay(Guid id, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var booking = await _bookingService.PayBookingAsync(id, userId, cancellationToken);
        return Ok(booking);
    }

    [HttpPost("{id:guid}/status")]
    [Authorize(Roles = "Trainer,GymAdministrator,CentralAdministrator")]
    public async Task<ActionResult<BookingDto>> UpdateStatus(Guid id, [FromBody] BookingStatusUpdate request, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var booking = await _bookingService.UpdateStatusAsync(id, request.Confirm, requesterId, requesterRole, cancellationToken);
            return booking is null ? NotFound() : Ok(booking);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("history")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<BookingDto>>> History(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var history = await _bookingService.GetHistoryAsync(userId, cancellationToken);
        return Ok(history);
    }

    [HttpGet]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<BookingDto>>> GetByStatus([FromQuery] string? status, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var bookings = await _bookingService.GetByStatusAsync(userId, status, cancellationToken);
        return Ok(bookings);
    }
}
