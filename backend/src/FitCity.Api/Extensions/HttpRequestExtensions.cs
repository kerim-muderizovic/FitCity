using Microsoft.AspNetCore.Http;

namespace FitCity.Api.Extensions;

public static class HttpRequestExtensions
{
    public static string? GetExternalOrigin(this HttpRequest request)
    {
        var forwardedProto = request.Headers["X-Forwarded-Proto"].FirstOrDefault();
        var forwardedHost = request.Headers["X-Forwarded-Host"].FirstOrDefault();

        var scheme = string.IsNullOrWhiteSpace(forwardedProto)
            ? request.Scheme
            : forwardedProto.Split(',')[0].Trim();
        var host = string.IsNullOrWhiteSpace(forwardedHost)
            ? request.Host.Value
            : forwardedHost.Split(',')[0].Trim();

        if (string.IsNullOrWhiteSpace(scheme) || string.IsNullOrWhiteSpace(host))
        {
            return null;
        }

        return $"{scheme}://{host}";
    }
}
