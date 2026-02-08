using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IAccessLogService
{
    Task<IReadOnlyList<AccessLogDto>> GetAccessLogsAsync(
        Guid requesterId,
        string requesterRole,
        Guid? gymId,
        DateTime? fromUtc,
        DateTime? toUtc,
        string? status,
        string? query,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<AccessLogDto>> GetMemberEntriesAsync(
        Guid memberId,
        DateTime? fromUtc,
        DateTime? toUtc,
        CancellationToken cancellationToken);
}
