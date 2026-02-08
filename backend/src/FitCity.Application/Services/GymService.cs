using FitCity.Application.Constants;
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
        var latitude = request.Latitude ?? GymLocationDefaults.SarajevoLatitude;
        var longitude = request.Longitude ?? GymLocationDefaults.SarajevoLongitude;

        var gym = new Gym
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Address = NormalizeAddress(request.Address),
            City = NormalizeCity(request.City),
            Latitude = latitude,
            Longitude = longitude,
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
        gym.Address = NormalizeAddress(request.Address);
        gym.City = NormalizeCity(request.City);
        gym.Latitude = request.Latitude ?? GymLocationDefaults.SarajevoLatitude;
        gym.Longitude = request.Longitude ?? GymLocationDefaults.SarajevoLongitude;
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

    public async Task<GymDto?> GetForAdminAsync(Guid adminUserId, CancellationToken cancellationToken)
    {
        var gymId = await GetGymIdForAdminAsync(adminUserId, cancellationToken);
        return await GetByIdAsync(gymId, cancellationToken);
    }

    private static GymDto MapGym(Gym gym) => new()
    {
        Id = gym.Id,
        Name = gym.Name,
        Address = NormalizeAddress(gym.Address),
        City = NormalizeCity(gym.City),
        Latitude = gym.Latitude ?? GymLocationDefaults.SarajevoLatitude,
        Longitude = gym.Longitude ?? GymLocationDefaults.SarajevoLongitude,
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

    private static string NormalizeAddress(string? value)
    {
        return string.IsNullOrWhiteSpace(value) ? GymLocationDefaults.SarajevoAddress : value.Trim();
    }

    private static string NormalizeCity(string? value)
    {
        return string.IsNullOrWhiteSpace(value) ? GymLocationDefaults.SarajevoCity : value.Trim();
    }

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
