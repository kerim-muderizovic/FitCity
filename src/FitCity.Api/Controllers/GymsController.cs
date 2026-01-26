using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using FitCity.Api.Extensions;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/gyms")]
public class GymsController : ControllerBase
{
    private readonly IGymService _gymService;

    public GymsController(IGymService gymService)
    {
        _gymService = gymService;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IReadOnlyList<GymDto>>> GetAll([FromQuery] string? search, CancellationToken cancellationToken)
    {
        var gyms = await _gymService.GetAllAsync(search, cancellationToken);
        return Ok(gyms);
    }

    [HttpGet("{id:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<GymDto>> GetById(Guid id, CancellationToken cancellationToken)
    {
        var gym = await _gymService.GetByIdAsync(id, cancellationToken);
        return gym is null ? NotFound() : Ok(gym);
    }

    [HttpPost]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<ActionResult<GymDto>> Create([FromBody] GymCreateRequest request, CancellationToken cancellationToken)
    {
        var gym = await _gymService.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = gym.Id }, gym);
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<GymDto>> Update(Guid id, [FromBody] GymUpdateRequest request, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var gym = await _gymService.UpdateAsync(id, request, requesterId, requesterRole, cancellationToken);
            return gym is null ? NotFound() : Ok(gym);
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
        var deleted = await _gymService.DeleteAsync(id, cancellationToken);
        return deleted ? NoContent() : NotFound();
    }
}
