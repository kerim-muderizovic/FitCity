using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/settings")]
public class AdminSettingsController : ControllerBase
{
    private readonly IAppSettingsService _appSettingsService;

    public AdminSettingsController(IAppSettingsService appSettingsService)
    {
        _appSettingsService = appSettingsService;
    }

    [HttpGet]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<ActionResult<AppSettingsDto>> Get(CancellationToken cancellationToken)
    {
        var settings = await _appSettingsService.GetAsync(cancellationToken);
        return Ok(settings);
    }

    [HttpPut]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<ActionResult<AppSettingsDto>> Update(
        [FromBody] UpdateAppSettingsRequest request,
        CancellationToken cancellationToken)
    {
        var settings = await _appSettingsService.UpdateAsync(request, cancellationToken);
        return Ok(settings);
    }
}
