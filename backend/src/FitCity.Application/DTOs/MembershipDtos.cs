using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class MembershipRequestCreate
{
    [Required]
    public Guid GymId { get; set; }

    public Guid? GymPlanId { get; set; }
}

public class MembershipRequestDecision
{
    [Required]
    public bool Approve { get; set; }

    [MaxLength(400)]
    public string? RejectionReason { get; set; }
}

public class MembershipRequestDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid GymId { get; set; }
    public Guid? GymPlanId { get; set; }
    public string Status { get; set; } = string.Empty;
    public string PaymentStatus { get; set; } = string.Empty;
    public DateTime? ApprovedAtUtc { get; set; }
    public Guid? ApprovedByUserId { get; set; }
    public DateTime? RejectedAtUtc { get; set; }
    public Guid? RejectedByUserId { get; set; }
    public string? RejectionReason { get; set; }
    public DateTime? PaidAtUtc { get; set; }
    public Guid? PaymentId { get; set; }
    public DateTime RequestedAtUtc { get; set; }
}

public class MembershipRequestAdminDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;
    public Guid GymId { get; set; }
    public string GymName { get; set; } = string.Empty;
    public Guid? GymPlanId { get; set; }
    public string Status { get; set; } = string.Empty;
    public string PaymentStatus { get; set; } = string.Empty;
    public DateTime RequestedAtUtc { get; set; }
    public DateTime? ApprovedAtUtc { get; set; }
    public DateTime? RejectedAtUtc { get; set; }
    public string? RejectionReason { get; set; }
    public DateTime? PaidAtUtc { get; set; }
}

public class MembershipDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid GymId { get; set; }
    public Guid? GymPlanId { get; set; }
    public DateTime StartDateUtc { get; set; }
    public DateTime EndDateUtc { get; set; }
    public string Status { get; set; } = string.Empty;
}

public class ActiveMembershipResponse
{
    public string State { get; set; } = "None";
    public string? MembershipStatus { get; set; }
    public Guid? MembershipId { get; set; }
    public Guid? GymId { get; set; }
    public string? GymName { get; set; }
    public Guid? GymPlanId { get; set; }
    public string? PlanName { get; set; }
    public DateTime? StartDateUtc { get; set; }
    public DateTime? EndDateUtc { get; set; }
    public int? RemainingDays { get; set; }
    public Guid? RequestId { get; set; }
    public string? RequestStatus { get; set; }
    public string? PaymentStatus { get; set; }
    public bool CanPay { get; set; }
    public DateTime? RequestedAtUtc { get; set; }
    public DateTime? RejectedAtUtc { get; set; }
    public string? RejectionReason { get; set; }
}

public class MembershipPaymentRequest
{
    public string? PaymentMethod { get; set; }
}

public class StripeCheckoutResponse
{
    public string Url { get; set; } = string.Empty;
}

public class MembershipPaymentResponse
{
    public MembershipDto Membership { get; set; } = null!;
    public QrIssueResponse? Qr { get; set; }
}
