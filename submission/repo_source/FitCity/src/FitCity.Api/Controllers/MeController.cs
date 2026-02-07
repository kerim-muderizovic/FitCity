using FitCity.Api.Extensions;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Primitives;
using Microsoft.Net.Http.Headers;

namespace FitCity.Api.Controllers;

[ApiController]
[Route("api/me")]
public class MeController : ControllerBase
{
    private readonly IAccessLogService _accessLogService;
    private readonly IRecommendationService _recommendationService;
    private readonly IProfileService _profileService;
    private readonly IWebHostEnvironment _environment;
    private readonly ILogger<MeController> _logger;
    private static readonly HashSet<string> AllowedPhotoExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
    };
    private const long MaxPhotoBytes = 10 * 1024 * 1024;

    public MeController(
        IAccessLogService accessLogService,
        IRecommendationService recommendationService,
        IProfileService profileService,
        IWebHostEnvironment environment,
        ILogger<MeController> logger)
    {
        _accessLogService = accessLogService;
        _recommendationService = recommendationService;
        _profileService = profileService;
        _environment = environment;
        _logger = logger;
    }

    [HttpGet("entry-history")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<AccessLogDto>>> EntryHistory(
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var entries = await _accessLogService.GetMemberEntriesAsync(userId, from, to, cancellationToken);
        return Ok(entries);
    }

    [HttpGet("recommendations/trainers")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<RecommendedTrainerDto>>> RecommendedTrainers(
        [FromQuery] int? limit,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var recommendations = await _recommendationService.RecommendTrainersForUserAsync(
            userId,
            limit ?? 10,
            cancellationToken);
        return Ok(recommendations);
    }

    [HttpGet("recommendations/gyms")]
    [Authorize(Roles = "User")]
    public async Task<ActionResult<IReadOnlyList<RecommendedGymDto>>> RecommendedGyms(
        [FromQuery] int? limit,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        var recommendations = await _recommendationService.RecommendGymsForUserAsync(
            userId,
            limit ?? 10,
            cancellationToken);
        return Ok(recommendations);
    }

    [HttpPut("profile")]
    [Authorize]
    public async Task<ActionResult<CurrentUserResponse>> UpdateProfile(
        [FromBody] ProfileUpdateRequest request,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        try
        {
            var response = await _profileService.UpdateProfileAsync(userId, request, cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("photo")]
    [Authorize]
    [RequestSizeLimit(MaxPhotoBytes)]
    [RequestFormLimits(MultipartBodyLengthLimit = MaxPhotoBytes)]
    public async Task<ActionResult<CurrentUserResponse>> UploadProfilePhoto(
        [FromForm] IFormFile file,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation(
            "Profile photo upload request. Path={Path}, ContentType={ContentType}, ContentLength={ContentLength}, Boundary={Boundary}",
            Request.Path,
            Request.ContentType,
            Request.ContentLength,
            ExtractBoundary(Request.ContentType));

        if (file == null || file.Length == 0)
        {
            _logger.LogWarning("Profile photo upload rejected: empty file.");
            return BadRequest(new { error = "Please select a photo to upload." });
        }

        if (file.Length > MaxPhotoBytes)
        {
            _logger.LogWarning("Profile photo upload rejected: file too large. Size={Size}", file.Length);
            return BadRequest(new { error = "Photo must be 10MB or smaller." });
        }

        var extension = Path.GetExtension(file.FileName);
        if (string.IsNullOrWhiteSpace(extension) || !AllowedPhotoExtensions.Contains(extension))
        {
            _logger.LogWarning("Profile photo upload rejected: extension {Extension} is not allowed.", extension);
            return BadRequest(new { error = "Only JPG, PNG, or WebP files are allowed." });
        }

        var contentType = file.ContentType ?? string.Empty;
        if (!string.IsNullOrWhiteSpace(contentType)
            && !contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(contentType, "application/octet-stream", StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogWarning("Profile photo upload rejected: content type {ContentType} is not allowed.", contentType);
            return BadRequest(new { error = "Only image files are allowed." });
        }

        var userId = User.GetUserId();
        _logger.LogInformation(
            "Profile photo file accepted. UserId={UserId}, Name={FileName}, Size={Size}, ContentType={FileContentType}",
            userId,
            file.FileName,
            file.Length,
            file.ContentType);

        try
        {
            var root = string.IsNullOrWhiteSpace(_environment.WebRootPath)
                ? Path.Combine(_environment.ContentRootPath, "wwwroot")
                : _environment.WebRootPath;
            var uploadRoot = Path.Combine(root, "uploads", "avatars");
            Directory.CreateDirectory(uploadRoot);

            var fileName = $"{userId}-{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}{extension.ToLowerInvariant()}";
            var filePath = Path.Combine(uploadRoot, fileName);

            var oldFiles = Directory.GetFiles(uploadRoot, $"{userId}-*.*");
            foreach (var oldFile in oldFiles)
            {
                if (!string.Equals(oldFile, filePath, StringComparison.OrdinalIgnoreCase) && System.IO.File.Exists(oldFile))
                {
                    System.IO.File.Delete(oldFile);
                }
            }
            foreach (var ext in AllowedPhotoExtensions)
            {
                var legacyPath = Path.Combine(uploadRoot, $"{userId}{ext}");
                if (System.IO.File.Exists(legacyPath))
                {
                    System.IO.File.Delete(legacyPath);
                }
            }

            await using (var stream = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.None))
            {
                await file.CopyToAsync(stream, cancellationToken);
            }

            var publicUrl = $"{Request.Scheme}://{Request.Host}/uploads/avatars/{fileName}";
            var response = await _profileService.UpdateProfilePhotoAsync(userId, publicUrl, cancellationToken);
            _logger.LogInformation(
                "Profile photo upload succeeded. UserId={UserId}, SavedPath={SavedPath}, PublicUrl={PublicUrl}",
                userId,
                filePath,
                publicUrl);
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to upload profile photo for user {UserId}", userId);
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { error = "Unable to upload photo right now. Please try again." });
        }
    }

    private static string ExtractBoundary(string? contentType)
    {
        if (string.IsNullOrWhiteSpace(contentType)
            || !MediaTypeHeaderValue.TryParse(contentType, out var mediaType)
            || StringSegment.IsNullOrEmpty(mediaType.Boundary))
        {
            return string.Empty;
        }

        return HeaderUtilities.RemoveQuotes(mediaType.Boundary).ToString();
    }
}
