using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using FitCity.Api.Extensions;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/reports")]
public class ReportsController : ControllerBase
{
    private readonly IReportsService _reportsService;

    public ReportsController(IReportsService reportsService)
    {
        _reportsService = reportsService;
    }

    [HttpGet("memberships-per-month")]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<IReadOnlyList<MonthlyCountDto>>> MembershipsPerMonth(CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var results = await _reportsService.MembershipsPerMonthAsync(requesterId, requesterRole, cancellationToken);
            return Ok(results);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("top-trainers")]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<IReadOnlyList<TopTrainerDto>>> TopTrainers(CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var results = await _reportsService.TopTrainersByBookingsAsync(requesterId, requesterRole, cancellationToken);
            return Ok(results);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("revenue-per-month")]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<IReadOnlyList<MonthlyRevenueDto>>> RevenuePerMonth(CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var results = await _reportsService.RevenueByMonthAsync(requesterId, requesterRole, cancellationToken);
            return Ok(results);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
