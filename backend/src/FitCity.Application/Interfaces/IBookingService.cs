using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IBookingService
{
    Task<BookingDto> CreateAsync(Guid userId, BookingCreateRequest request, CancellationToken cancellationToken);
    Task<BookingDto?> UpdateStatusAsync(Guid bookingId, bool confirm, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<IReadOnlyList<BookingDto>> GetHistoryAsync(Guid userId, CancellationToken cancellationToken);
    Task<IReadOnlyList<BookingDto>> GetByStatusAsync(Guid userId, string? status, CancellationToken cancellationToken);
    Task<BookingDto> PayBookingAsync(Guid bookingId, Guid userId, CancellationToken cancellationToken);
}
