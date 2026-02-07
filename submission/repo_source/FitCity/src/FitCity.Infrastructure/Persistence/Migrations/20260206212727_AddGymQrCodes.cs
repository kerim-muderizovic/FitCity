using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    public partial class AddGymQrCodes : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF OBJECT_ID(N'GymQrCodes', N'U') IS NULL
BEGIN
    CREATE TABLE [GymQrCodes] (
        [Id] uniqueidentifier NOT NULL,
        [GymId] uniqueidentifier NOT NULL,
        [Token] nvarchar(128) NOT NULL,
        [CreatedAtUtc] datetime2 NOT NULL,
        [IsActive] bit NOT NULL CONSTRAINT [DF_GymQrCodes_IsActive] DEFAULT 1,
        CONSTRAINT [PK_GymQrCodes] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_GymQrCodes_Gyms_GymId] FOREIGN KEY ([GymId]) REFERENCES [Gyms] ([Id]) ON DELETE CASCADE
    );

    CREATE UNIQUE INDEX [IX_GymQrCodes_GymId] ON [GymQrCodes] ([GymId]);
    CREATE UNIQUE INDEX [IX_GymQrCodes_Token] ON [GymQrCodes] ([Token]);
END

INSERT INTO [GymQrCodes] ([Id], [GymId], [Token], [CreatedAtUtc], [IsActive])
SELECT NEWID(),
       g.[Id],
       REPLACE(CONVERT(varchar(36), NEWID()), '-', ''),
       SYSUTCDATETIME(),
       1
FROM [Gyms] g
WHERE NOT EXISTS (SELECT 1 FROM [GymQrCodes] q WHERE q.[GymId] = g.[Id]);
");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF OBJECT_ID(N'GymQrCodes', N'U') IS NOT NULL
BEGIN
    DROP TABLE [GymQrCodes];
END
");
        }
    }
}
