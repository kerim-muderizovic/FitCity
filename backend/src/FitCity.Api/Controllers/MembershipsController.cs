using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/memberships")]
public class MembershipsController : ControllerBase
{
    private readonly IMembershipService _membershipService;
    private readonly IStripePaymentService _stripePaymentService;

    public MembershipsController(IMembershipService membershipService, IStripePaymentService stripePaymentService)
    {
        _membershipService = membershipService;
        _stripePaymentService = stripePaymentService;
    }

    [HttpPost("requests")]
    [Authorize]
    public async Task<ActionResult<MembershipRequestDto>> RequestMembership([FromBody] MembershipRequestCreate request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var role = User.GetUserRole();
        if (!string.Equals(role, "User", StringComparison.OrdinalIgnoreCase))
        {
            return BadRequest(new { error = "Only member accounts can request memberships." });
        }

        var response = await _membershipService.RequestMembershipAsync(userId, request, cancellationToken);
        return Ok(response);
    }

    [HttpGet("requests")]
    [Authorize]
    public async Task<ActionResult<IReadOnlyList<MembershipRequestDto>>> GetRequests(
        [FromQuery] Guid? gymId,
        [FromQuery] Guid? userId,
        [FromQuery] string? status,
        CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var response = await _membershipService.GetMembershipRequestsAsync(requesterId, requesterRole, gymId, userId, status, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("requests/{id:guid}/decision")]
    [Authorize(Roles = "GymAdministrator,CentralAdministrator")]
    public async Task<ActionResult<MembershipRequestDto>> Decide(Guid id, [FromBody] MembershipRequestDecision request, CancellationToken cancellationToken)
    {
        var adminId = User.GetUserId();
        var adminRole = User.GetUserRole();
        try
        {
            var response = await _membershipService.DecideRequestAsync(id, request.Approve, request.RejectionReason, adminId, adminRole, cancellationToken);
            return response is null ? NotFound() : Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("requests/{id:guid}/pay")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<StripeCheckoutResponse>> Pay(Guid id, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var requestOrigin = Request.GetExternalOrigin();
        var response = await _stripePaymentService.CreateMembershipCheckoutAsync(
            id,
            userId,
            cancellationToken,
            requestOrigin);
        return Ok(response);
    }

    [HttpGet]
    [Authorize]
    public async Task<ActionResult<IReadOnlyList<MembershipDto>>> GetMemberships([FromQuery] Guid? userId, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var response = await _membershipService.GetMembershipsAsync(requesterId, requesterRole, userId, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("active")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<ActiveMembershipResponse>> GetActiveMembership(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var response = await _membershipService.GetActiveMembershipAsync(userId, cancellationToken);
        return Ok(response);
    }

    [HttpGet("{id:guid}/validate")]
    [Authorize(Roles = "GymAdministrator,CentralAdministrator")]
    public async Task<ActionResult<object>> Validate(Guid id, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var isValid = await _membershipService.ValidateMembershipAsync(id, requesterId, requesterRole, cancellationToken);
            return Ok(new { membershipId = id, isValid });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
