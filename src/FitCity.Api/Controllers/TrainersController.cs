using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using FitCity.Api.Extensions;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/trainers")]
public class TrainersController : ControllerBase
{
    private readonly ITrainerService _trainerService;
    private readonly ILogger<TrainersController> _logger;

    public TrainersController(ITrainerService trainerService, ILogger<TrainersController> logger)
    {
        _trainerService = trainerService;
        _logger = logger;
    }

    [HttpGet]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<IReadOnlyList<TrainerDto>>> GetAll([FromQuery] string? search, CancellationToken cancellationToken)
    {
        var requesterId = User.GetUserId();
        var requesterRole = User.GetUserRole();
        try
        {
            var trainers = await _trainerService.GetAllAsync(search, requesterId, requesterRole, cancellationToken);
            return Ok(trainers);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost]
    [Authorize(Roles = "CentralAdministrator,GymAdministrator")]
    public async Task<ActionResult<TrainerDto>> Create([FromBody] TrainerCreateRequest request, CancellationToken cancellationToken)
    {
        var trainer = await _trainerService.CreateAsync(request, cancellationToken);
        return Ok(trainer);
    }

    [HttpGet("{id:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<TrainerDto>> GetById(Guid id, CancellationToken cancellationToken)
    {
        var trainer = await _trainerService.GetByIdAsync(id, cancellationToken);
        return trainer is null ? NotFound() : Ok(trainer);
    }

    [HttpGet("{id:guid}/detail")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<TrainerDetailDto>> GetDetail(Guid id, CancellationToken cancellationToken)
    {
        var detail = await _trainerService.GetPublicDetailAsync(id, cancellationToken);
        return detail is null ? NotFound() : Ok(detail);
    }

    [HttpGet("by-gym/{gymId:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<IReadOnlyList<TrainerDto>>> GetByGym(Guid gymId, CancellationToken cancellationToken)
    {
        var trainers = await _trainerService.GetByGymAsync(gymId, cancellationToken);
        return Ok(trainers);
    }

    [HttpGet("{id:guid}/availability")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<TrainerScheduleResponseDto>> Availability(
        Guid id,
        [FromQuery] DateTime fromUtc,
        [FromQuery] DateTime toUtc,
        CancellationToken cancellationToken)
    {
        if (fromUtc == default || toUtc == default || toUtc <= fromUtc)
        {
            return BadRequest(new { error = "Invalid date range." });
        }

        var trainer = await _trainerService.GetByIdAsync(id, cancellationToken);
        if (trainer is null)
        {
            return NotFound(new { error = "Trainer not found." });
        }

        var availability = await _trainerService.GetAvailabilityAsync(id, fromUtc, toUtc, cancellationToken);
        if (availability.Schedules.Count == 0)
        {
            _logger.LogWarning("Trainer {TrainerId} has no availability between {FromUtc} and {ToUtc}.", id, fromUtc, toUtc);
        }
        return Ok(availability);
    }

    [HttpGet("me/schedule")]
    [Authorize(Roles = "Trainer")]
    public async Task<ActionResult<TrainerScheduleResponseDto>> MySchedule(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var schedule = await _trainerService.GetMyScheduleAsync(userId, cancellationToken);
            return Ok(schedule);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
