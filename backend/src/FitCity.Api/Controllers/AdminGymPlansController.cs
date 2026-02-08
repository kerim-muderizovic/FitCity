using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/gym-plans")]
public class AdminGymPlansController : ControllerBase
{
    private readonly IGymPlanService _gymPlanService;

    public AdminGymPlansController(IGymPlanService gymPlanService)
    {
        _gymPlanService = gymPlanService;
    }

    [HttpGet]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<ActionResult<IReadOnlyList<GymPlanDto>>> GetAll(
        [FromQuery] Guid? gymId,
        [FromQuery] string? query,
        CancellationToken cancellationToken)
    {
        var plans = await _gymPlanService.GetAllAsync(gymId, query, cancellationToken);
        return Ok(plans);
    }

    [HttpPost]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<ActionResult<GymPlanDto>> Create([FromBody] GymPlanCreateRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var plan = await _gymPlanService.CreateAsync(request, cancellationToken);
            return Ok(plan);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<ActionResult<GymPlanDto>> Update(Guid id, [FromBody] GymPlanUpdateRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var plan = await _gymPlanService.UpdateAsync(id, request, cancellationToken);
            return plan is null ? NotFound() : Ok(plan);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var removed = await _gymPlanService.DeleteAsync(id, cancellationToken);
        return removed ? NoContent() : NotFound();
    }
}
