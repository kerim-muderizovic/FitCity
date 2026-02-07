using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/reviews")]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewsController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<ReviewDto>> Create([FromBody] ReviewCreateRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var review = await _reviewService.CreateAsync(userId, request, cancellationToken);
        return Ok(review);
    }

    [HttpGet("trainer/{trainerId:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<IReadOnlyList<ReviewDto>>> ForTrainer(Guid trainerId, CancellationToken cancellationToken)
    {
        var reviews = await _reviewService.GetForTrainerAsync(trainerId, cancellationToken);
        return Ok(reviews);
    }
}
