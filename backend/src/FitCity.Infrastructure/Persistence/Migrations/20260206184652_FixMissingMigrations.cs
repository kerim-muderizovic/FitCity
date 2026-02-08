using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    public partial class FixMissingMigrations : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF COL_LENGTH('CheckInLogs','IsSuccessful') IS NULL
BEGIN
    ALTER TABLE CheckInLogs ADD IsSuccessful bit NOT NULL CONSTRAINT DF_CheckInLogs_IsSuccessful DEFAULT 1;
END

IF COL_LENGTH('CheckInLogs','QrPayload') IS NULL
BEGIN
    ALTER TABLE CheckInLogs ADD QrPayload nvarchar(2048) NULL;
END
");

            migrationBuilder.Sql(@"
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_TrainingSession_PaymentMethod' AND parent_object_id = OBJECT_ID('TrainingSessions'))
    ALTER TABLE TrainingSessions DROP CONSTRAINT CK_TrainingSession_PaymentMethod;

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Payment_Method' AND parent_object_id = OBJECT_ID('Payments'))
    ALTER TABLE Payments DROP CONSTRAINT CK_Payment_Method;

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_TrainingSession_PaymentMethod' AND parent_object_id = OBJECT_ID('TrainingSessions'))
    ALTER TABLE TrainingSessions ADD CONSTRAINT CK_TrainingSession_PaymentMethod CHECK ([PaymentMethod] IN (1,2,3,4));

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Payment_Method' AND parent_object_id = OBJECT_ID('Payments'))
    ALTER TABLE Payments ADD CONSTRAINT CK_Payment_Method CHECK ([Method] IN (1,2,3,4));
");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_TrainingSession_PaymentMethod' AND parent_object_id = OBJECT_ID('TrainingSessions'))
    ALTER TABLE TrainingSessions DROP CONSTRAINT CK_TrainingSession_PaymentMethod;

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Payment_Method' AND parent_object_id = OBJECT_ID('Payments'))
    ALTER TABLE Payments DROP CONSTRAINT CK_Payment_Method;

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_TrainingSession_PaymentMethod' AND parent_object_id = OBJECT_ID('TrainingSessions'))
    ALTER TABLE TrainingSessions ADD CONSTRAINT CK_TrainingSession_PaymentMethod CHECK ([PaymentMethod] IN (1,2,3));

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Payment_Method' AND parent_object_id = OBJECT_ID('Payments'))
    ALTER TABLE Payments ADD CONSTRAINT CK_Payment_Method CHECK ([Method] IN (1,2,3));
");

            migrationBuilder.Sql(@"
IF COL_LENGTH('CheckInLogs','QrPayload') IS NOT NULL
BEGIN
    ALTER TABLE CheckInLogs DROP COLUMN QrPayload;
END

IF COL_LENGTH('CheckInLogs','IsSuccessful') IS NOT NULL
BEGIN
    DECLARE @dfName nvarchar(128);
    SELECT @dfName = dc.name
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c ON c.default_object_id = dc.object_id
    WHERE dc.parent_object_id = OBJECT_ID('CheckInLogs')
      AND c.name = 'IsSuccessful';

    IF @dfName IS NOT NULL
        EXEC('ALTER TABLE CheckInLogs DROP CONSTRAINT ' + @dfName);

    ALTER TABLE CheckInLogs DROP COLUMN IsSuccessful;
END
");
        }
    }
}
