using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace FitCity.Infrastructure.Persistence;

public class FitCityDbContextFactory : IDesignTimeDbContextFactory<FitCityDbContext>
{
    public FitCityDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
            ?? Environment.GetEnvironmentVariable("CONNECTION_STRING");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException("Connection string is not configured.");
        }

        var optionsBuilder = new DbContextOptionsBuilder<FitCityDbContext>();
        optionsBuilder.UseSqlServer(connectionString);
        return new FitCityDbContext(optionsBuilder.Options);
    }
}
