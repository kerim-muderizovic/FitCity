using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class QrIssueResponse
{
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
}

public class QrScanRequest
{
    [Required, MinLength(1), MaxLength(2048)]
    public string Token { get; set; } = string.Empty;

    public Guid? GymId { get; set; }
}

public class QrScanResultResponse
{
    public string Status { get; set; } = "Denied";
    public string Reason { get; set; } = string.Empty;
    public bool Entered { get; set; }
    public Guid? MembershipId { get; set; }
    public Guid? MemberId { get; set; }
    public string? MemberName { get; set; }
    public Guid? GymId { get; set; }
    public string? GymName { get; set; }
    public DateTime ScannedAtUtc { get; set; }
}
