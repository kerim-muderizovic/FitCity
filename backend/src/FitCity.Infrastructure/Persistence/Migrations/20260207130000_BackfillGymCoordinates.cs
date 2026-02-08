using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations;

[Migration("20260207130000_BackfillGymCoordinates")]
public partial class BackfillGymCoordinates : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            UPDATE [Gyms]
            SET [Latitude] = 43.8563
            WHERE [Latitude] IS NULL;
            """);

        migrationBuilder.Sql(
            """
            UPDATE [Gyms]
            SET [Longitude] = 18.4131
            WHERE [Longitude] IS NULL;
            """);

        migrationBuilder.Sql(
            """
            UPDATE [Gyms]
            SET [City] = 'Sarajevo'
            WHERE [City] IS NULL OR LTRIM(RTRIM([City])) = '';
            """);

        migrationBuilder.Sql(
            """
            UPDATE [Gyms]
            SET [Address] = 'City Center, Sarajevo'
            WHERE [Address] IS NULL OR LTRIM(RTRIM([Address])) = '';
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
    }
}
