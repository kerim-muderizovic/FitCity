using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/webhooks/stripe")]
public class StripeWebhooksController : ControllerBase
{
    private readonly IStripePaymentService _stripePaymentService;

    public StripeWebhooksController(IStripePaymentService stripePaymentService)
    {
        _stripePaymentService = stripePaymentService;
    }

    [HttpPost]
    [AllowAnonymous]
    public async Task<IActionResult> Handle(CancellationToken cancellationToken)
    {
        using var reader = new StreamReader(Request.Body);
        var payload = await reader.ReadToEndAsync(cancellationToken);
        var signature = Request.Headers["Stripe-Signature"].FirstOrDefault() ?? string.Empty;

        await _stripePaymentService.HandleWebhookAsync(payload, signature, cancellationToken);
        return Ok();
    }
}
