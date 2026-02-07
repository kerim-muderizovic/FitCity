using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/gyms")]
[Authorize(Roles = "CentralAdministrator")]
public class AdminGymsController : ControllerBase
{
    private readonly IGymService _gymService;

    public AdminGymsController(IGymService gymService)
    {
        _gymService = gymService;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<GymDto>>> GetAll([FromQuery] string? search, CancellationToken cancellationToken)
    {
        var gyms = await _gymService.GetAllAsync(search, cancellationToken);
        return Ok(gyms);
    }

    [HttpPost]
    public async Task<ActionResult<GymDto>> Create([FromBody] GymCreateRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var gym = await _gymService.CreateAsync(request, cancellationToken);
            return CreatedAtAction(nameof(GetAll), new { id = gym.Id }, gym);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
