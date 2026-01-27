using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SeedChatConversations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8000));

            migrationBuilder.InsertData(
                table: "Conversations",
                columns: new[] { "Id", "CreatedAtUtc", "LastMessageAtUtc", "MemberId", "Title", "TrainerId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { new Guid("a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4"), new DateTime(2024, 12, 29, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 12, 30, 10, 0, 0, 0, DateTimeKind.Utc), new Guid("66666666-6666-6666-6666-666666666666"), "Session follow-up", new Guid("33333333-3333-3333-3333-333333333334"), new DateTime(2024, 12, 30, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5"), new DateTime(2024, 12, 31, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 1, 2, 0, 0, 0, DateTimeKind.Utc), new Guid("77777777-7777-7777-7777-777777777777"), "Nutrition tips", new Guid("33333333-3333-3333-3333-333333333335"), new DateTime(2025, 1, 1, 2, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8026));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8027));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8028));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8029));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8030));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8031));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8032));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8033));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8127));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8330));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(8332));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7492));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7503));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7506));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7508));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7510));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222226"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7525));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222227"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7600));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222228"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7602));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222229"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7605));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7512));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7514));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7516));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7519));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7521));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7523));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7607));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7609));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7611));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7614));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 27, 50, 600, DateTimeKind.Utc).AddTicks(7616));

            migrationBuilder.InsertData(
                table: "ConversationParticipants",
                columns: new[] { "Id", "ConversationId", "JoinedAtUtc", "LastReadAtUtc", "UserId" },
                values: new object[,]
                {
                    { new Guid("a6a6a6a6-a6a6-a6a6-a6a6-a6a6a6a6a6a6"), new Guid("a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4"), new DateTime(2024, 12, 29, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 12, 30, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("66666666-6666-6666-6666-666666666666") },
                    { new Guid("a7a7a7a7-a7a7-a7a7-a7a7-a7a7a7a7a7a7"), new Guid("a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4"), new DateTime(2024, 12, 29, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 12, 30, 9, 0, 0, 0, DateTimeKind.Utc), new Guid("33333333-3333-3333-3333-333333333334") },
                    { new Guid("a8a8a8a8-a8a8-a8a8-a8a8-a8a8a8a8a8a8"), new Guid("a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5"), new DateTime(2024, 12, 31, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 1, 1, 0, 0, 0, DateTimeKind.Utc), new Guid("77777777-7777-7777-7777-777777777777") },
                    { new Guid("a9a9a9a9-a9a9-a9a9-a9a9-a9a9a9a9a9a9"), new Guid("a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5"), new DateTime(2024, 12, 31, 8, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 1, 2, 0, 0, 0, DateTimeKind.Utc), new Guid("33333333-3333-3333-3333-333333333335") }
                });

            migrationBuilder.InsertData(
                table: "Messages",
                columns: new[] { "Id", "Content", "ConversationId", "SenderRole", "SenderUserId", "SentAtUtc" },
                values: new object[,]
                {
                    { new Guid("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0"), "Thanks for the session today!", new Guid("a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4"), "User", new Guid("66666666-6666-6666-6666-666666666666"), new DateTime(2024, 12, 30, 10, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1"), "Keep protein high and stay hydrated.", new Guid("a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5"), "Trainer", new Guid("33333333-3333-3333-3333-333333333335"), new DateTime(2025, 1, 1, 2, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2"), "Got it, thank you!", new Guid("a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5"), "User", new Guid("77777777-7777-7777-7777-777777777777"), new DateTime(2025, 1, 1, 3, 0, 0, 0, DateTimeKind.Utc) }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("a6a6a6a6-a6a6-a6a6-a6a6-a6a6a6a6a6a6"));

            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("a7a7a7a7-a7a7-a7a7-a7a7-a7a7a7a7a7a7"));

            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("a8a8a8a8-a8a8-a8a8-a8a8-a8a8a8a8a8a8"));

            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("a9a9a9a9-a9a9-a9a9-a9a9-a9a9a9a9a9a9"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2"));

            migrationBuilder.DeleteData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4"));

            migrationBuilder.DeleteData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5"));

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 13, 25, 12, 844, DateTimeKind.Utc).AddTicks(4754));

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
        }
    }
}
