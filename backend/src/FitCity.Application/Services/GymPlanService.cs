using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class GymPlanService : IGymPlanService
{
    private readonly FitCityDbContext _dbContext;

    public GymPlanService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<GymPlanDto>> GetAllAsync(Guid? gymId, string? query, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.GymPlan> plansQuery = _dbContext.GymPlans
            .AsNoTracking()
            .Include(p => p.Gym);

        if (gymId.HasValue)
        {
            plansQuery = plansQuery.Where(p => p.GymId == gymId.Value);
        }

        if (!string.IsNullOrWhiteSpace(query))
        {
            var term = query.Trim().ToLowerInvariant();
            plansQuery = plansQuery.Where(p =>
                p.Name.ToLower().Contains(term) ||
                (p.Description ?? string.Empty).ToLower().Contains(term) ||
                p.Gym.Name.ToLower().Contains(term));
        }

        var plans = await plansQuery
            .OrderBy(p => p.Gym.Name)
            .ThenBy(p => p.Name)
            .ToListAsync(cancellationToken);

        return plans.Select(MapPlan).ToList();
    }

    public async Task<GymPlanDto> CreateAsync(GymPlanCreateRequest request, CancellationToken cancellationToken)
    {
        var gym = await _dbContext.Gyms.AsNoTracking().FirstOrDefaultAsync(g => g.Id == request.GymId, cancellationToken);
        if (gym is null)
        {
            throw new InvalidOperationException("Gym not found.");
        }

        var plan = new Domain.Entities.GymPlan
        {
            Id = Guid.NewGuid(),
            GymId = request.GymId,
            Name = request.Name.Trim(),
            Price = request.Price,
            DurationMonths = request.DurationMonths,
            Description = request.Description,
            IsActive = request.IsActive
        };

        _dbContext.GymPlans.Add(plan);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new GymPlanDto
        {
            Id = plan.Id,
            GymId = plan.GymId,
            GymName = gym.Name,
            Name = plan.Name,
            Price = plan.Price,
            DurationMonths = plan.DurationMonths,
            Description = plan.Description,
            IsActive = plan.IsActive
        };
    }

    public async Task<GymPlanDto?> UpdateAsync(Guid id, GymPlanUpdateRequest request, CancellationToken cancellationToken)
    {
        var plan = await _dbContext.GymPlans.Include(p => p.Gym).FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
        if (plan is null)
        {
            return null;
        }

        var gym = await _dbContext.Gyms.AsNoTracking().FirstOrDefaultAsync(g => g.Id == request.GymId, cancellationToken);
        if (gym is null)
        {
            throw new InvalidOperationException("Gym not found.");
        }

        plan.GymId = request.GymId;
        plan.Name = request.Name.Trim();
        plan.Price = request.Price;
        plan.DurationMonths = request.DurationMonths;
        plan.Description = request.Description;
        plan.IsActive = request.IsActive;

        await _dbContext.SaveChangesAsync(cancellationToken);

        return new GymPlanDto
        {
            Id = plan.Id,
            GymId = plan.GymId,
            GymName = gym.Name,
            Name = plan.Name,
            Price = plan.Price,
            DurationMonths = plan.DurationMonths,
            Description = plan.Description,
            IsActive = plan.IsActive
        };
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var plan = await _dbContext.GymPlans.FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
        if (plan is null)
        {
            return false;
        }

        _dbContext.GymPlans.Remove(plan);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    private static GymPlanDto MapPlan(Domain.Entities.GymPlan plan) => new()
    {
        Id = plan.Id,
        GymId = plan.GymId,
        GymName = plan.Gym.Name,
        Name = plan.Name,
        Price = plan.Price,
        DurationMonths = plan.DurationMonths,
        Description = plan.Description,
        IsActive = plan.IsActive
    };
}
