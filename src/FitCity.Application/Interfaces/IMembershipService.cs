using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IMembershipService
{
    Task<MembershipRequestDto> RequestMembershipAsync(Guid userId, MembershipRequestCreate request, CancellationToken cancellationToken);
    Task<MembershipRequestDto?> DecideRequestAsync(Guid requestId, bool approve, Guid adminUserId, string adminRole, CancellationToken cancellationToken);
    Task<IReadOnlyList<MembershipRequestDto>> GetMembershipRequestsAsync(Guid requesterId, string requesterRole, Guid? gymId, Guid? userId, string? status, CancellationToken cancellationToken);
    Task<MembershipPaymentResponse> PayMembershipRequestAsync(Guid requestId, Guid userId, MembershipPaymentRequest request, CancellationToken cancellationToken);
    Task<IReadOnlyList<MembershipDto>> GetMembershipsAsync(Guid requesterId, string requesterRole, Guid? userId, CancellationToken cancellationToken);
    Task<ActiveMembershipResponse> GetActiveMembershipAsync(Guid userId, CancellationToken cancellationToken);
    Task<bool> ValidateMembershipAsync(Guid membershipId, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
}
