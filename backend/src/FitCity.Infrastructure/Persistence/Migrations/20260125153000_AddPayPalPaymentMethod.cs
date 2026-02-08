using Microsoft.EntityFrameworkCore.Migrations;

namespace FitCity.Infrastructure.Persistence.Migrations;

public partial class AddPayPalPaymentMethod : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropCheckConstraint(
            name: "CK_TrainingSession_PaymentMethod",
            table: "TrainingSessions");

        migrationBuilder.DropCheckConstraint(
            name: "CK_Payment_Method",
            table: "Payments");

        migrationBuilder.AddCheckConstraint(
            name: "CK_TrainingSession_PaymentMethod",
            table: "TrainingSessions",
            sql: "[PaymentMethod] IN (1,2,3,4)");

        migrationBuilder.AddCheckConstraint(
            name: "CK_Payment_Method",
            table: "Payments",
            sql: "[Method] IN (1,2,3,4)");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropCheckConstraint(
            name: "CK_TrainingSession_PaymentMethod",
            table: "TrainingSessions");

        migrationBuilder.DropCheckConstraint(
            name: "CK_Payment_Method",
            table: "Payments");

        migrationBuilder.AddCheckConstraint(
            name: "CK_TrainingSession_PaymentMethod",
            table: "TrainingSessions",
            sql: "[PaymentMethod] IN (1,2,3)");

        migrationBuilder.AddCheckConstraint(
            name: "CK_Payment_Method",
            table: "Payments",
            sql: "[Method] IN (1,2,3)");
    }
}
