using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/members")]
public class AdminMembersController : ControllerBase
{
    private readonly IMemberService _memberService;

    public AdminMembersController(IMemberService memberService)
    {
        _memberService = memberService;
    }

    [HttpGet("{id:guid}")]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<MemberDetailDto>> GetDetail(Guid id, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var detail = await _memberService.GetMemberDetailAsync(id, requesterId, requesterRole, cancellationToken);
            return detail is null ? NotFound() : Ok(detail);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
