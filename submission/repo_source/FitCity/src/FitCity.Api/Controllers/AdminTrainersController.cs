using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/trainers")]
public class AdminTrainersController : ControllerBase
{
    private readonly ITrainerService _trainerService;

    public AdminTrainersController(ITrainerService trainerService)
    {
        _trainerService = trainerService;
    }

    [HttpPost("gym")]
    [Authorize(Roles = "GymAdministrator")]
    public async Task<ActionResult<TrainerDto>> CreateForGym([FromBody] GymAdminTrainerCreateRequest request, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        try
        {
            var trainer = await _trainerService.CreateForGymAdminAsync(requesterId, request, cancellationToken);
            return Ok(trainer);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("{id:guid}")]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<TrainerDetailDto>> GetDetail(Guid id, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var detail = await _trainerService.GetDetailAsync(id, requesterId, requesterRole, cancellationToken);
            return detail is null ? NotFound() : Ok(detail);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
