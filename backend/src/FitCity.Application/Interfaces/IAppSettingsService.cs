using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IAppSettingsService
{
    Task<AppSettingsDto> GetAsync(CancellationToken cancellationToken);
    Task<AppSettingsDto> UpdateAsync(UpdateAppSettingsRequest request, CancellationToken cancellationToken);
}
