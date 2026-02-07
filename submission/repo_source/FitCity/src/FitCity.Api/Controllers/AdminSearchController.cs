using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/admin/search")]
public class AdminSearchController : ControllerBase
{
    private readonly IAdminSearchService _adminSearchService;

    public AdminSearchController(IAdminSearchService adminSearchService)
    {
        _adminSearchService = adminSearchService;
    }

    [HttpGet]
    [Authorize(Roles = "CentralAdministrator")]
    public async Task<ActionResult<AdminSearchResponse>> Search(
        [FromQuery] string? query,
        [FromQuery] string? type,
        [FromQuery] Guid? gymId,
        [FromQuery] string? city,
        [FromQuery] string? status,
        CancellationToken cancellationToken)
    {
        var response = await _adminSearchService.SearchAsync(query, type, gymId, city, status, cancellationToken);
        return Ok(response);
    }
}
