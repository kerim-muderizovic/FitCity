namespace FitCity.Application.Options;

public class EmailOptions
{
    public const string SectionName = "Email";

    public string Provider { get; set; } = string.Empty;
    public string Host { get; set; } = string.Empty;
    public int Port { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string From { get; set; } = string.Empty;
    public string? FileOutputPath { get; set; }
}
