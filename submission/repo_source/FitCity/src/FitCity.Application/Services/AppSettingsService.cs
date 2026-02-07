using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class AppSettingsService : IAppSettingsService
{
    private readonly FitCityDbContext _dbContext;

    public AppSettingsService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<AppSettingsDto> GetAsync(CancellationToken cancellationToken)
    {
        var settings = await GetOrCreateAsync(cancellationToken);
        return Map(settings);
    }

    public async Task<AppSettingsDto> UpdateAsync(UpdateAppSettingsRequest request, CancellationToken cancellationToken)
    {
        var settings = await GetOrCreateAsync(cancellationToken);
        if (request.AllowGymRegistrations.HasValue)
        {
            settings.AllowGymRegistrations = request.AllowGymRegistrations.Value;
        }
        if (request.AllowUserRegistration.HasValue)
        {
            settings.AllowUserRegistration = request.AllowUserRegistration.Value;
        }
        if (request.AllowTrainerCreation.HasValue)
        {
            settings.AllowTrainerCreation = request.AllowTrainerCreation.Value;
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        return Map(settings);
    }

    private async Task<AppSettings> GetOrCreateAsync(CancellationToken cancellationToken)
    {
        var settings = await _dbContext.AppSettings.FirstOrDefaultAsync(cancellationToken);
        if (settings != null)
        {
            return settings;
        }

        settings = new AppSettings
        {
            Id = AppSettings.DefaultId,
            AllowGymRegistrations = true,
            AllowUserRegistration = true,
            AllowTrainerCreation = true
        };
        _dbContext.AppSettings.Add(settings);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return settings;
    }

    private static AppSettingsDto Map(AppSettings settings)
        => new()
        {
            AllowGymRegistrations = settings.AllowGymRegistrations,
            AllowUserRegistration = settings.AllowUserRegistration,
            AllowTrainerCreation = settings.AllowTrainerCreation
        };
}
