using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddChatFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SenderRole",
                table: "Messages",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "LastMessageAtUtc",
                table: "Conversations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "MemberId",
                table: "Conversations",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "TrainerId",
                table: "Conversations",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Conversations",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "LastReadAtUtc",
                table: "ConversationParticipants",
                type: "datetime2",
                nullable: true);

            migrationBuilder.Sql(@"
UPDATE c
SET MemberId = members.UserId,
    TrainerId = trainers.UserId
FROM Conversations c
OUTER APPLY (
    SELECT TOP 1 p.UserId
    FROM ConversationParticipants p
    INNER JOIN Users u ON u.Id = p.UserId
    WHERE p.ConversationId = c.Id AND u.Role = 1
) members
OUTER APPLY (
    SELECT TOP 1 p.UserId
    FROM ConversationParticipants p
    INNER JOIN Users u ON u.Id = p.UserId
    WHERE p.ConversationId = c.Id AND u.Role = 2
) trainers
WHERE c.MemberId = '00000000-0000-0000-0000-000000000000'
  AND c.TrainerId = '00000000-0000-0000-0000-000000000000';
");

            migrationBuilder.Sql(@"
UPDATE m
SET SenderRole = CASE u.Role
    WHEN 1 THEN 'User'
    WHEN 2 THEN 'Trainer'
    WHEN 3 THEN 'GymAdministrator'
    WHEN 4 THEN 'CentralAdministrator'
    ELSE 'User'
END
FROM Messages m
INNER JOIN Users u ON u.Id = m.SenderUserId
WHERE m.SenderRole = '';
");

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4754));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("96969696-9696-9696-9696-969696969696"),
                columns: new[] { "JoinedAtUtc", "LastReadAtUtc" },
                values: new object[] { new DateTime(2024, 12, 30, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 1, 2, 0, 0, 0, DateTimeKind.Utc) });

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("97979797-9797-9797-9797-979797979797"),
                columns: new[] { "JoinedAtUtc", "LastReadAtUtc" },
                values: new object[] { new DateTime(2024, 12, 30, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 1, 3, 0, 0, 0, DateTimeKind.Utc) });

            migrationBuilder.UpdateData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("95959595-9595-9595-9595-959595959595"),
                columns: new[] { "CreatedAtUtc", "LastMessageAtUtc", "MemberId", "TrainerId", "UpdatedAtUtc" },
                values: new object[] { new DateTime(2024, 12, 30, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 1, 3, 0, 0, 0, DateTimeKind.Utc), new Guid("55555555-5555-5555-5555-555555555555"), new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2024, 12, 31, 8, 0, 0, 0, DateTimeKind.Utc) });

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4781));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4782));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4783));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4785));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4785));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4786));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4787));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4788));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4858));

            migrationBuilder.UpdateData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("98989898-9898-9898-9898-989898989898"),
                column: "SenderRole",
                value: "Trainer");

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(5063));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(5096));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4182));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4193));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4266));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4269));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4272));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222226"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4288));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222227"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4290));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222228"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4292));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222229"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4294));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4274));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4276));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4279));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4281));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4283));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4285));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4296));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4298));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4301));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4303));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4305));

            migrationBuilder.CreateIndex(
                name: "IX_Conversations_MemberId_TrainerId",
                table: "Conversations",
                columns: new[] { "MemberId", "TrainerId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Conversations_TrainerId",
                table: "Conversations",
                column: "TrainerId");

            migrationBuilder.AddForeignKey(
                name: "FK_Conversations_Users_MemberId",
                table: "Conversations",
                column: "MemberId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Conversations_Users_TrainerId",
                table: "Conversations",
                column: "TrainerId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Conversations_Users_MemberId",
                table: "Conversations");

            migrationBuilder.DropForeignKey(
                name: "FK_Conversations_Users_TrainerId",
                table: "Conversations");

            migrationBuilder.DropIndex(
                name: "IX_Conversations_MemberId_TrainerId",
                table: "Conversations");

            migrationBuilder.DropIndex(
                name: "IX_Conversations_TrainerId",
                table: "Conversations");

            migrationBuilder.DropColumn(
                name: "SenderRole",
                table: "Messages");

            migrationBuilder.DropColumn(
                name: "LastMessageAtUtc",
                table: "Conversations");

            migrationBuilder.DropColumn(
                name: "MemberId",
                table: "Conversations");

            migrationBuilder.DropColumn(
                name: "TrainerId",
                table: "Conversations");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Conversations");

            migrationBuilder.DropColumn(
                name: "LastReadAtUtc",
                table: "ConversationParticipants");

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(290));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("96969696-9696-9696-9696-969696969696"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(667));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("97979797-9797-9797-9797-979797979797"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(668));

            migrationBuilder.UpdateData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("95959595-9595-9595-9595-959595959595"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(645));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(323));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(325));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(326));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(327));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(328));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(329));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(330));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(331));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(398));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(616));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 781, DateTimeKind.Utc).AddTicks(619));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9527));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9539));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9541));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9543));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9546));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222226"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9638));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222227"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9641));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222228"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9643));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222229"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9645));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9625));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9627));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9629));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9632));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9634));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9636));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9647));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9650));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9652));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9654));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9656));
        }
    }
}
