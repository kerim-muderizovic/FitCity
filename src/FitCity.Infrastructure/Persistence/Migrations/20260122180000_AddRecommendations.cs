using System;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations;

[DbContext(typeof(FitCityDbContext))]
[Migration("20260122180000_AddRecommendations")]
public partial class AddRecommendations : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "Specialties",
            table: "Trainers",
            type: "nvarchar(500)",
            maxLength: 500,
            nullable: false,
            defaultValue: "");

        migrationBuilder.AddColumn<string>(
            name: "Styles",
            table: "Trainers",
            type: "nvarchar(300)",
            maxLength: 300,
            nullable: false,
            defaultValue: "");

        migrationBuilder.AddColumn<string>(
            name: "SupportedFitnessLevels",
            table: "Trainers",
            type: "nvarchar(120)",
            maxLength: 120,
            nullable: false,
            defaultValue: "");

        migrationBuilder.AddColumn<string>(
            name: "TrainingGoals",
            table: "Preferences",
            type: "nvarchar(500)",
            maxLength: 500,
            nullable: false,
            defaultValue: "");

        migrationBuilder.AddColumn<string>(
            name: "WorkoutTypes",
            table: "Preferences",
            type: "nvarchar(500)",
            maxLength: 500,
            nullable: false,
            defaultValue: "");

        migrationBuilder.AddColumn<int>(
            name: "FitnessLevel",
            table: "Preferences",
            type: "int",
            nullable: true);

        migrationBuilder.AddColumn<string>(
            name: "PreferredGymLocations",
            table: "Preferences",
            type: "nvarchar(300)",
            maxLength: 300,
            nullable: true);

        migrationBuilder.AddColumn<double>(
            name: "PreferredLatitude",
            table: "Preferences",
            type: "float",
            nullable: true);

        migrationBuilder.AddColumn<double>(
            name: "PreferredLongitude",
            table: "Preferences",
            type: "float",
            nullable: true);

        migrationBuilder.CreateTable(
            name: "UserTrainerInteractions",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                TrainerId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Type = table.Column<int>(type: "int", nullable: false),
                Weight = table.Column<int>(type: "int", nullable: false),
                CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_UserTrainerInteractions", x => x.Id);
                table.ForeignKey(
                    name: "FK_UserTrainerInteractions_Trainers_TrainerId",
                    column: x => x.TrainerId,
                    principalTable: "Trainers",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Restrict);
                table.ForeignKey(
                    name: "FK_UserTrainerInteractions_Users_UserId",
                    column: x => x.UserId,
                    principalTable: "Users",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Restrict);
            });

        migrationBuilder.CreateIndex(
            name: "IX_UserTrainerInteractions_UserId_TrainerId_Type",
            table: "UserTrainerInteractions",
            columns: new[] { "UserId", "TrainerId", "Type" });
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "UserTrainerInteractions");

        migrationBuilder.DropColumn(
            name: "Specialties",
            table: "Trainers");

        migrationBuilder.DropColumn(
            name: "Styles",
            table: "Trainers");

        migrationBuilder.DropColumn(
            name: "SupportedFitnessLevels",
            table: "Trainers");

        migrationBuilder.DropColumn(
            name: "TrainingGoals",
            table: "Preferences");

        migrationBuilder.DropColumn(
            name: "WorkoutTypes",
            table: "Preferences");

        migrationBuilder.DropColumn(
            name: "FitnessLevel",
            table: "Preferences");

        migrationBuilder.DropColumn(
            name: "PreferredGymLocations",
            table: "Preferences");

        migrationBuilder.DropColumn(
            name: "PreferredLatitude",
            table: "Preferences");

        migrationBuilder.DropColumn(
            name: "PreferredLongitude",
            table: "Preferences");
    }
}
