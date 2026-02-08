using FitCity.Application.DTOs;

namespace FitCity.Application.Interfaces;

public interface IMemberService
{
    Task<IReadOnlyList<MemberDto>> GetMembersAsync(Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<MemberDto> CreateMemberAsync(MemberCreateRequest request, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<bool> DeleteMemberAsync(Guid memberId, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
    Task<MemberDetailDto?> GetMemberDetailAsync(Guid memberId, Guid requesterId, string requesterRole, CancellationToken cancellationToken);
}
