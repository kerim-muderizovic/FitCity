using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using FitCity.Api.Extensions;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/members")]
public class MembersController : ControllerBase
{
    private readonly IMemberService _memberService;

    public MembersController(IMemberService memberService)
    {
        _memberService = memberService;
    }

    [HttpGet]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<IReadOnlyList<MemberDto>>> GetMembers(CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var members = await _memberService.GetMembersAsync(requesterId, requesterRole, cancellationToken);
            return Ok(members);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<MemberDto>> Create([FromBody] MemberCreateRequest request, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var member = await _memberService.CreateMemberAsync(request, requesterId, requesterRole, cancellationToken);
            return Ok(member);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        if (requesterId == id)
        {
            return BadRequest(new { error = "You cannot delete your own account." });
        }

        try
        {
            var deleted = await _memberService.DeleteMemberAsync(id, requesterId, requesterRole, cancellationToken);
            return deleted ? NoContent() : NotFound();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
