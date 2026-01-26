namespace FitCity.Application.Options;

public class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Issuer { get; set; } = "FitCity";
    public string Audience { get; set; } = "FitCityClients";
    public string SecretKey { get; set; } = "super-secret-dev-key-change";
    public int ExpirationMinutes { get; set; } = 120;
}
