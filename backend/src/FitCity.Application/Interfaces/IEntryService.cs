using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IEntryService
{
    Task<QrScanResultResponse> ValidateAsync(
        Guid requesterId,
        string requesterRole,
        EntryValidateRequest request,
        CancellationToken cancellationToken);
}
