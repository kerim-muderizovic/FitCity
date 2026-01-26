using System.ComponentModel.DataAnnotations;

namespace FitCity.Application.DTOs;

public class MemberCreateRequest
{
    [Required, EmailAddress, MaxLength(200)]
    public string Email { get; set; } = string.Empty;

    [Required, MinLength(6), MaxLength(100)]
    public string Password { get; set; } = string.Empty;

    [Required, MaxLength(200)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(40)]
    public string? PhoneNumber { get; set; }
}

public class MemberDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
