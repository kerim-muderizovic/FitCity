using System.Net;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("payments/stripe")]
public class StripeRedirectController : ControllerBase
{
    private readonly IStripePaymentService _stripePaymentService;
    private readonly ILogger<StripeRedirectController> _logger;

    public StripeRedirectController(
        IStripePaymentService stripePaymentService,
        ILogger<StripeRedirectController> logger)
    {
        _stripePaymentService = stripePaymentService;
        _logger = logger;
    }

    [HttpGet("success")]
    public async Task<ContentResult> Success(
        [FromQuery(Name = "session_id")] string? sessionId,
        CancellationToken cancellationToken)
    {
        try
        {
            await _stripePaymentService.FinalizeCheckoutSessionAsync(sessionId, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Stripe success redirect finalization failed for session {SessionId}.", sessionId);
        }

        return Content(
            BuildRedirectPage("Payment completed", "You can return to the FitCity app."),
            "text/html");
    }

    [HttpGet("cancel")]
    public ContentResult Cancel()
    {
        return Content(
            BuildRedirectPage("Payment cancelled", "You can return to the FitCity app to try again."),
            "text/html");
    }

    private static string BuildRedirectPage(string title, string message)
    {
        var safeTitle = WebUtility.HtmlEncode(title);
        var safeMessage = WebUtility.HtmlEncode(message);
        return $$"""
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>{{safeTitle}}</title>
              <style>
                body { font-family: Arial, sans-serif; background: #f7f7f8; color: #1e1e1e; text-align: center; padding: 32px 16px; }
                .card { max-width: 560px; margin: 0 auto; background: #fff; border-radius: 16px; padding: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
                h1 { margin: 0 0 8px; }
                p { margin: 0; color: #444; }
                .hint { margin-top: 12px; font-size: 13px; color: #666; }
                .btn {
                  margin-top: 16px;
                  display: inline-block;
                  background: #1565c0;
                  color: #fff;
                  text-decoration: none;
                  padding: 10px 16px;
                  border-radius: 10px;
                }
              </style>
            </head>
            <body>
              <div class="card">
                <h1>{{safeTitle}}</h1>
                <p>{{safeMessage}}</p>
                <a class="btn" href="fitcity://payment/result">Open FitCity App</a>
                <p class="hint">If the app does not open automatically, tap "Open FitCity App".</p>
              </div>
              <script>
                setTimeout(function () {
                  window.location.href = "fitcity://payment/result";
                }, 700);
              </script>
            </body>
            </html>
            """;
    }
}
