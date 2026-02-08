using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    [DbContext(typeof(FitCityDbContext))]
    [Migration("20260125120000_AddTrainingSessionPaymentFields")]
    public partial class AddTrainingSessionPaymentFields : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PaymentMethod",
                table: "TrainingSessions",
                type: "int",
                nullable: false,
                defaultValue: 2);

            migrationBuilder.AddColumn<int>(
                name: "PaymentStatus",
                table: "TrainingSessions",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<decimal>(
                name: "Price",
                table: "TrainingSessions",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<DateTime>(
                name: "PaidAtUtc",
                table: "TrainingSessions",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_TrainingSession_PaymentMethod",
                table: "TrainingSessions",
                sql: "[PaymentMethod] IN (1,2,3)");

            migrationBuilder.AddCheckConstraint(
                name: "CK_TrainingSession_PaymentStatus",
                table: "TrainingSessions",
                sql: "[PaymentStatus] IN (1,2)");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_TrainingSession_PaymentMethod",
                table: "TrainingSessions");

            migrationBuilder.DropCheckConstraint(
                name: "CK_TrainingSession_PaymentStatus",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "PaymentMethod",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "PaymentStatus",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "Price",
                table: "TrainingSessions");

            migrationBuilder.DropColumn(
                name: "PaidAtUtc",
                table: "TrainingSessions");
        }
    }
}
