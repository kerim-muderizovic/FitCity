using FitCity.Api.Extensions;
using FitCity.Application.Interfaces;
using FitCity.Application.Messaging;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/diagnostics")]
public class AdminDiagnosticsController : ControllerBase
{
    private readonly IEmailQueueService _emailQueueService;

    public AdminDiagnosticsController(IEmailQueueService emailQueueService)
    {
        _emailQueueService = emailQueueService;
    }

    [HttpPost("notifications/test-email")]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<IActionResult> EnqueueTestEmail([FromBody] TestEmailRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return BadRequest(new { error = "Email is required." });
        }

        var senderId = User.GetUserId();
        var receiverName = string.IsNullOrWhiteSpace(request.Name) ? "Admin" : request.Name.Trim();

        await _emailQueueService.SendEmailAsync(new EmailMessage
        {
            EmailTo = request.Email.Trim(),
            ReceiverName = receiverName,
            Subject = "FitCity worker test",
            Message = $"Worker test message queued by {senderId} at {DateTime.UtcNow:O}."
        }, cancellationToken);

        return Ok(new { status = "queued" });
    }

    public sealed class TestEmailRequest
    {
        public string Email { get; set; } = string.Empty;
        public string? Name { get; set; }
    }
}
