using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    public partial class AddAppSettings : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AppSettings",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AllowGymRegistrations = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    AllowUserRegistration = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    AllowTrainerCreation = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppSettings", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "AppSettings",
                columns: new[] { "Id", "AllowGymRegistrations", "AllowUserRegistration", "AllowTrainerCreation" },
                values: new object[] { new Guid("f0f0f0f0-0000-0000-0000-000000000001"), true, true, true });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AppSettings");
        }
    }
}
