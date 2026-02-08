using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("payments/stripe")]
public class StripeRedirectController : ControllerBase
{
    [HttpGet("success")]
    public ContentResult Success()
    {
        return Content("""
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>Payment completed</title>
              <style>
                body { font-family: Arial, sans-serif; background: #f7f7f8; color: #1e1e1e; text-align: center; padding: 48px; }
                .card { max-width: 520px; margin: 0 auto; background: #fff; border-radius: 16px; padding: 32px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
                h1 { margin: 0 0 8px; }
                p { margin: 0; color: #444; }
              </style>
            </head>
            <body>
              <div class="card">
                <h1>Payment completed</h1>
                <p>You can return to the FitCity app.</p>
              </div>
            </body>
            </html>
            """, "text/html");
    }

    [HttpGet("cancel")]
    public ContentResult Cancel()
    {
        return Content("""
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>Payment cancelled</title>
              <style>
                body { font-family: Arial, sans-serif; background: #f7f7f8; color: #1e1e1e; text-align: center; padding: 48px; }
                .card { max-width: 520px; margin: 0 auto; background: #fff; border-radius: 16px; padding: 32px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
                h1 { margin: 0 0 8px; }
                p { margin: 0; color: #444; }
              </style>
            </head>
            <body>
              <div class="card">
                <h1>Payment cancelled</h1>
                <p>You can return to the FitCity app to try again.</p>
              </div>
            </body>
            </html>
            """, "text/html");
    }
}
