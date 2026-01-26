using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class ReviewService : IReviewService
{
    private readonly FitCityDbContext _dbContext;

    public ReviewService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<ReviewDto> CreateAsync(Guid userId, ReviewCreateRequest request, CancellationToken cancellationToken)
    {
        var exists = await _dbContext.Reviews.AnyAsync(r =>
            r.UserId == userId && r.TrainerId == request.TrainerId && r.GymId == request.GymId, cancellationToken);

        if (exists)
        {
            throw new InvalidOperationException("Review already exists.");
        }

        var review = new Review
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TrainerId = request.TrainerId,
            GymId = request.GymId,
            Rating = request.Rating,
            Comment = request.Comment,
            CreatedAtUtc = DateTime.UtcNow
        };

        _dbContext.Reviews.Add(review);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return Map(review);
    }

    public async Task<IReadOnlyList<ReviewDto>> GetForTrainerAsync(Guid trainerId, CancellationToken cancellationToken)
    {
        var reviews = await _dbContext.Reviews
            .AsNoTracking()
            .Where(r => r.TrainerId == trainerId)
            .OrderByDescending(r => r.CreatedAtUtc)
            .ToListAsync(cancellationToken);

        return reviews.Select(Map).ToList();
    }

    private static ReviewDto Map(Review review) => new()
    {
        Id = review.Id,
        UserId = review.UserId,
        TrainerId = review.TrainerId,
        GymId = review.GymId,
        Rating = review.Rating,
        Comment = review.Comment,
        CreatedAtUtc = review.CreatedAtUtc
    };
}
