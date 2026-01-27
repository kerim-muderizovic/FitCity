using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IReportsService
{
    Task<IReadOnlyList<MonthlyCountDto>> MembershipsPerMonthAsync(Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<IReadOnlyList<TopTrainerDto>> TopTrainersByBookingsAsync(Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<IReadOnlyList<MonthlyRevenueDto>> RevenueByMonthAsync(Guid requesterId, string requesterRole, CancellationToken cancellationToken);
}
