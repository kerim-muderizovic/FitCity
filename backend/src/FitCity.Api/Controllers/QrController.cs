using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/qr")]
public class QrController : ControllerBase
{
    private readonly IQrService _qrService;

    public QrController(IQrService qrService)
    {
        _qrService = qrService;
    }

    [HttpPost("issue/{membershipId:guid}")]
    [Authorize(Roles = "User,GymAdministrator,CentralAdministrator")]
    public async Task<ActionResult<QrIssueResponse>> Issue(Guid membershipId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var role = User.GetUserRole();
        try
        {
            var response = await _qrService.IssueAsync(membershipId, userId, role, cancellationToken);
            return response is null ? NotFound() : Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("scan")]
    [Authorize(Roles = "GymAdministrator,CentralAdministrator")]
    public async Task<ActionResult<QrScanResultResponse>> Scan([FromBody] QrScanRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var role = User.GetUserRole();
        try
        {
            var result = await _qrService.ScanAsync(userId, role, request, cancellationToken);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("validate")]
    [Authorize(Roles = "User,GymAdministrator,CentralAdministrator")]
    public async Task<ActionResult<QrScanResultResponse>> Validate([FromBody] QrScanRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var role = User.GetUserRole();
        try
        {
            var response = await _qrService.ValidateAsync(userId, role, request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
