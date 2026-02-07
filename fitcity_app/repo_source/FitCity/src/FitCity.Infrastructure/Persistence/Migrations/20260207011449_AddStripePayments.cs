using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddStripePayments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Provider",
                table: "Payments",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProviderEventId",
                table: "Payments",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProviderPaymentIntentId",
                table: "Payments",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProviderSessionId",
                table: "Payments",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "PaymentAudits",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    EventType = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymPlanId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Provider = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PaymentAudits", x => x.Id);
                });

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5175));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5204));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5206));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5207));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5208));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5209));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5210));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5211));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5212));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5297));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505052"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5300));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505053"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5302));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505054"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5303));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505055"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5305));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505056"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5306));

            migrationBuilder.UpdateData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: new Guid("92929292-9292-9292-9292-929292929292"),
                columns: new[] { "Provider", "ProviderEventId", "ProviderPaymentIntentId", "ProviderSessionId" },
                values: new object[] { null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5571));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(5573));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4476));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4488));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4490));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4492));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4494));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222226"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4584));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222227"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4586));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222228"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4588));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222229"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4590));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4497));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4499));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4501));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4576));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4579));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4582));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4592));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4595));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4597));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4599));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 7, 1, 14, 47, 448, DateTimeKind.Utc).AddTicks(4601));

            migrationBuilder.CreateIndex(
                name: "IX_Payments_ProviderEventId",
                table: "Payments",
                column: "ProviderEventId",
                unique: true,
                filter: "[ProviderEventId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentAudits_GymId",
                table: "PaymentAudits",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentAudits_UserId",
                table: "PaymentAudits",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PaymentAudits");

            migrationBuilder.DropIndex(
                name: "IX_Payments_ProviderEventId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "Provider",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "ProviderEventId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "ProviderPaymentIntentId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "ProviderSessionId",
                table: "Payments");

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(847));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(876));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(878));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(879));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(880));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(881));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(885));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(885));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(886));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(970));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505052"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(972));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505053"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(974));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505054"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(975));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505055"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(1008));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505056"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(1009));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(1231));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(1233));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(224));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(236));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(238));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(241));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(243));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222226"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(313));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222227"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(315));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222228"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(317));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222229"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(319));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(299));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(302));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(304));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(306));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(308));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(310));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(321));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(323));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(326));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(328));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 2, 6, 23, 35, 19, 693, DateTimeKind.Utc).AddTicks(330));
        }
    }
}
