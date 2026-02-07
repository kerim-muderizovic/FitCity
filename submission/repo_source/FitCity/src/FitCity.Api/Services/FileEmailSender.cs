using FitCity.Application.Interfaces;
using FitCity.Application.Options;
using Microsoft.Extensions.Options;

namespace FitCity.Api.Services;

public class FileEmailSender : IEmailSender
{
    private readonly EmailOptions _options;
    private readonly IWebHostEnvironment _environment;

    public FileEmailSender(IOptions<EmailOptions> options, IWebHostEnvironment environment)
    {
        _options = options.Value;
        _environment = environment;
    }

    public async Task SendWelcomeEmailAsync(string email, string? fullName, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return;
        }

        var outputPath = ResolveOutputPath();
        Directory.CreateDirectory(outputPath);

        var fileName = $"welcome_{DateTime.UtcNow:yyyyMMdd_HHmmssfff}_{Guid.NewGuid():N}.txt";
        var filePath = Path.Combine(outputPath, fileName);

        var content = $"To: {email}{Environment.NewLine}" +
                      $"Name: {fullName}{Environment.NewLine}" +
                      "Subject: Welcome to FitCity" + Environment.NewLine +
                      "Body: You successfully registered, congratulations!" + Environment.NewLine;

        await File.WriteAllTextAsync(filePath, content, cancellationToken);
    }

    private string ResolveOutputPath()
    {
        if (string.IsNullOrWhiteSpace(_options.FileOutputPath))
        {
            return Path.Combine(_environment.ContentRootPath, "App_Data", "emails");
        }

        return Path.IsPathRooted(_options.FileOutputPath)
            ? _options.FileOutputPath
            : Path.Combine(_environment.ContentRootPath, _options.FileOutputPath);
    }
}
