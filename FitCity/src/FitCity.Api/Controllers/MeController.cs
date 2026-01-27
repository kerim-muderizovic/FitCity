using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/me")]
public class MeController : ControllerBase
{
    private readonly IAccessLogService _accessLogService;
    private readonly IRecommendationService _recommendationService;
    private readonly IProfileService _profileService;

    public MeController(
        IAccessLogService accessLogService,
        IRecommendationService recommendationService,
        IProfileService profileService)
    {
        _accessLogService = accessLogService;
        _recommendationService = recommendationService;
        _profileService = profileService;
    }

    [HttpGet("entry-history")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<AccessLogDto>>> EntryHistory(
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var entries = await _accessLogService.GetMemberEntriesAsync(userId, from, to, cancellationToken);
        return Ok(entries);
    }

    [HttpGet("recommendations/trainers")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<RecommendedTrainerDto>>> RecommendedTrainers(
        [FromQuery] int? limit,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var recommendations = await _recommendationService.RecommendTrainersForUserAsync(
            userId,
            limit ?? 10,
            cancellationToken);
        return Ok(recommendations);
    }

    [HttpGet("recommendations/gyms")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<RecommendedGymDto>>> RecommendedGyms(
        [FromQuery] int? limit,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var recommendations = await _recommendationService.RecommendGymsForUserAsync(
            userId,
            limit ?? 10,
            cancellationToken);
        return Ok(recommendations);
    }

    [HttpPut("profile")]
    [Authorize]
    public async Task<ActionResult<CurrentUserResponse>> UpdateProfile(
        [FromBody] ProfileUpdateRequest request,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var response = await _profileService.UpdateProfileAsync(userId, request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}
