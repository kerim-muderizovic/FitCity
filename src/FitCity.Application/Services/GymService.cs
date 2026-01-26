using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class GymService : IGymService
{
    private readonly FitCityDbContext _dbContext;

    public GymService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<GymDto> CreateAsync(GymCreateRequest request, CancellationToken cancellationToken)
    {
        var gym = new Gym
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Address = request.Address,
            City = request.City,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            PhoneNumber = request.PhoneNumber,
            Description = request.Description,
            PhotoUrl = request.PhotoUrl,
            WorkHours = request.WorkHours,
            IsActive = true
        };

        _dbContext.Gyms.Add(gym);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return MapGym(gym);
    }

    public async Task<GymDto?> UpdateAsync(
        Guid id,
        GymUpdateRequest request,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        var gym = await _dbContext.Gyms.FirstOrDefaultAsync(g => g.Id == id, cancellationToken);
        if (gym is null)
        {
            return null;
        }

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var adminGymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            if (adminGymId != gym.Id)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can update gyms.");
        }

        gym.Name = request.Name;
        gym.Address = request.Address;
        gym.City = request.City;
        gym.Latitude = request.Latitude;
        gym.Longitude = request.Longitude;
        gym.PhoneNumber = request.PhoneNumber;
        gym.Description = request.Description;
        gym.PhotoUrl = request.PhotoUrl;
        gym.WorkHours = request.WorkHours;
        gym.IsActive = request.IsActive;

        await _dbContext.SaveChangesAsync(cancellationToken);
        return MapGym(gym);
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var gym = await _dbContext.Gyms.FirstOrDefaultAsync(g => g.Id == id, cancellationToken);
        if (gym is null)
        {
            return false;
        }

        _dbContext.Gyms.Remove(gym);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IReadOnlyList<GymDto>> GetAllAsync(string? search, CancellationToken cancellationToken)
    {
        IQueryable<Gym> query = _dbContext.Gyms.AsNoTracking().Include(g => g.Photos);
        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(g => g.Name.Contains(search) || g.City.Contains(search));
        }

        var gyms = await query.OrderBy(g => g.Name).ToListAsync(cancellationToken);
        return gyms.Select(MapGym).ToList();
    }

    public async Task<GymDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var gym = await _dbContext.Gyms
            .AsNoTracking()
            .Include(g => g.Photos)
            .FirstOrDefaultAsync(g => g.Id == id, cancellationToken);
        return gym is null ? null : MapGym(gym);
    }

    private static GymDto MapGym(Gym gym) => new()
    {
        Id = gym.Id,
        Name = gym.Name,
        Address = gym.Address,
        City = gym.City,
        Latitude = gym.Latitude,
        Longitude = gym.Longitude,
        PhoneNumber = gym.PhoneNumber,
        Description = gym.Description,
        PhotoUrl = gym.PhotoUrl,
        WorkHours = gym.WorkHours,
        PhotoUrls = gym.Photos
            .OrderBy(p => p.SortOrder)
            .Select(p => p.Url)
            .ToList(),
        IsActive = gym.IsActive
    };

    private async Task<Guid> GetGymIdForAdminAsync(Guid adminUserId, CancellationToken cancellationToken)
    {
        var admin = await _dbContext.GymAdministrators
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.UserId == adminUserId, cancellationToken);

        if (admin is null)
        {
            throw new InvalidOperationException("Gym administrator is not assigned to a gym.");
        }

        return admin.GymId;
    }
}
