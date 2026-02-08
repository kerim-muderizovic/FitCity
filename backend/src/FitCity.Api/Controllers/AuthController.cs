using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.RegisterAsync(request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.LoginMobileAsync(request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BuildAuthError(ex);
        }
    }

    [HttpPost("admin/login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> AdminLogin([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.LoginAdminAsync(request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BuildAuthError(ex);
        }
    }

    [HttpPost("admin/central/login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> CentralAdminLogin([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.LoginCentralAdminAsync(request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BuildAuthError(ex);
        }
    }

    [HttpPost("admin/gym/login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> GymAdminLogin([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var response = await _authService.LoginGymAdminAsync(request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BuildAuthError(ex);
        }
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<CurrentUserResponse>> Me(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var response = await _authService.GetCurrentUserAsync(userId, cancellationToken);
        return Ok(response);
    }

    [HttpPut("change-password")]
    [Authorize]
    public async Task<ActionResult> ChangePassword([FromBody] ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        try
        {
            var userId = User.GetUserId();
            await _authService.ChangePasswordAsync(userId, request, cancellationToken);
            return Ok(new { message = "Password changed successfully." });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    private ActionResult BuildAuthError(InvalidOperationException ex)
    {
        if (string.Equals(ex.Message, "Invalid credentials.", StringComparison.Ordinal))
        {
            return Unauthorized(new { error = ex.Message });
        }

        return BadRequest(new { error = ex.Message });
    }
}
