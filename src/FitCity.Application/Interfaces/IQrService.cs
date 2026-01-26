using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IQrService
{
    Task<QrIssueResponse?> IssueAsync(Guid membershipId, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<bool> ScanAsync(Guid userId, string requesterRole, QrScanRequest request, CancellationToken cancellationToken);
    Task<QrScanResultResponse> ValidateAsync(Guid userId, string userRole, QrScanRequest request, CancellationToken cancellationToken);
}
