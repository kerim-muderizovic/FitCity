using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class FixCascadePaths : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MembershipRequests_Gyms_GymId",
                table: "MembershipRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MembershipRequests_Users_UserId",
                table: "MembershipRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_Memberships_Gyms_GymId",
                table: "Memberships");

            migrationBuilder.DropForeignKey(
                name: "FK_Memberships_Users_UserId",
                table: "Memberships");

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(618));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(939));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("e0e0e0e0-e0e0-e0e0-e0e0-e0e0e0e0e0e0"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(973));

            migrationBuilder.UpdateData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(918));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(646));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("30303030-3030-3030-3030-303030303030"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(700));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a0a0"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(893));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(895));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(74));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(89));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(92));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(95));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(98));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(100));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(103));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(106));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 14, 16, 55, 11, 56, DateTimeKind.Utc).AddTicks(109));

            migrationBuilder.AddForeignKey(
                name: "FK_MembershipRequests_Gyms_GymId",
                table: "MembershipRequests",
                column: "GymId",
                principalTable: "Gyms",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_MembershipRequests_Users_UserId",
                table: "MembershipRequests",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Memberships_Gyms_GymId",
                table: "Memberships",
                column: "GymId",
                principalTable: "Gyms",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Memberships_Users_UserId",
                table: "Memberships",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MembershipRequests_Gyms_GymId",
                table: "MembershipRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_MembershipRequests_Users_UserId",
                table: "MembershipRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_Memberships_Gyms_GymId",
                table: "Memberships");

            migrationBuilder.DropForeignKey(
                name: "FK_Memberships_Users_UserId",
                table: "Memberships");

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8664));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8972));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("e0e0e0e0-e0e0-e0e0-e0e0-e0e0e0e0e0e0"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8973));

            migrationBuilder.UpdateData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8949));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8686));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("30303030-3030-3030-3030-303030303030"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8745));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a0a0"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8923));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8926));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8308));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8318));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8320));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8323));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8325));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8327));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8329));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8331));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8333));

            migrationBuilder.AddForeignKey(
                name: "FK_MembershipRequests_Gyms_GymId",
                table: "MembershipRequests",
                column: "GymId",
                principalTable: "Gyms",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MembershipRequests_Users_UserId",
                table: "MembershipRequests",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Memberships_Gyms_GymId",
                table: "Memberships",
                column: "GymId",
                principalTable: "Gyms",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Memberships_Users_UserId",
                table: "Memberships",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
