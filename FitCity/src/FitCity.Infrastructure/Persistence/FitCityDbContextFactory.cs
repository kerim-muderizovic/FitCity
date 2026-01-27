using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace FitCity.Infrastructure.Persistence;

public class FitCityDbContextFactory : IDesignTimeDbContextFactory<FitCityDbContext>
{
    public FitCityDbContext CreateDbContext(string[] args)
    {
        var connectionString =
            Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
            ?? "Server=localhost,1433;Database=FitCityDb;User Id=sa;Password=Your_password123;TrustServerCertificate=True;";

        var optionsBuilder = new DbContextOptionsBuilder<FitCityDbContext>();
        optionsBuilder.UseSqlServer(connectionString);
        return new FitCityDbContext(optionsBuilder.Options);
    }
}
