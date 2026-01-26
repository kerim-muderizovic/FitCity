using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/access-logs")]
public class AccessLogsController : ControllerBase
{
    private readonly IAccessLogService _accessLogService;

    public AccessLogsController(IAccessLogService accessLogService)
    {
        _accessLogService = accessLogService;
    }

    [HttpGet]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<IReadOnlyList<AccessLogDto>>> Get(
        [FromQuery] Guid? gymId,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] string? status,
        [FromQuery] string? q,
        CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var results = await _accessLogService.GetAccessLogsAsync(
                requesterId,
                requesterRole,
                gymId,
                from,
                to,
                status,
                q,
                cancellationToken);
            return Ok(results);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
