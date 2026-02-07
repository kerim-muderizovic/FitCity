using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SeedSarajevoTrainers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("12121212-1212-1212-1212-121212121212"), new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("13131313-1313-1313-1313-131313131313"), new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("01010101-0101-0101-0101-010101010101") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("02020202-0202-0202-0202-020202020202") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd") });

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

            migrationBuilder.InsertData(
                table: "GymTrainers",
                columns: new[] { "GymId", "TrainerId", "AssignedAtUtc" },
                values: new object[,]
                {
                    { new Guid("14141414-1414-1414-1414-141414141414"), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("14141414-1414-1414-1414-141414141414"), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("15151515-1515-1515-1515-151515151515"), new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("16161616-1616-1616-1616-161616161616"), new Guid("01010101-0101-0101-0101-010101010101"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("16161616-1616-1616-1616-161616161616"), new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("17171717-1717-1717-1717-171717171717"), new Guid("02020202-0202-0202-0202-020202020202"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) }
                });

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
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("01010101-0101-0101-0101-010101010101"),
                columns: new[] { "Bio", "Certifications", "HourlyRate", "PhotoUrl" },
                values: new object[] { "Functional training and mobility-based sessions.", "Functional Trainer", 38m, "https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("02020202-0202-0202-0202-020202020202"),
                column: "HourlyRate",
                value: 50m);

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"),
                columns: new[] { "Bio", "HourlyRate", "PhotoUrl" },
                values: new object[] { "Strength and conditioning focus for busy professionals.", 45m, "https://images.unsplash.com/photo-1549576490-b0b4831ef60a?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"),
                columns: new[] { "Bio", "PhotoUrl" },
                values: new object[] { "Mobility and posture coaching with recovery work.", "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"),
                columns: new[] { "Bio", "HourlyRate", "PhotoUrl" },
                values: new object[] { "HIIT and bodyweight circuits, fast results.", 40m, "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"),
                columns: new[] { "Bio", "HourlyRate", "PhotoUrl" },
                values: new object[] { "Strength cycles and barbell technique.", 55m, "https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?auto=format&fit=crop&w=600&q=80" });

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
                columns: new[] { "CreatedAtUtc", "FullName", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9625), "Trainer Mustafa", "HASHED:trainer1pass" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                columns: new[] { "CreatedAtUtc", "FullName", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9627), "Trainer Halid", "HASHED:trainer2pass" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9629), "Trainer Velid" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9632), "Trainer Edis" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9634), "Trainer Mahmut" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 45, 55, 780, DateTimeKind.Utc).AddTicks(9636), "Trainer Elvis" });

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("14141414-1414-1414-1414-141414141414"), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("14141414-1414-1414-1414-141414141414"), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("15151515-1515-1515-1515-151515151515"), new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("16161616-1616-1616-1616-161616161616"), new Guid("01010101-0101-0101-0101-010101010101") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("16161616-1616-1616-1616-161616161616"), new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff") });

            migrationBuilder.DeleteData(
                table: "GymTrainers",
                keyColumns: new[] { "GymId", "TrainerId" },
                keyValues: new object[] { new Guid("17171717-1717-1717-1717-171717171717"), new Guid("02020202-0202-0202-0202-020202020202") });

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2698));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("96969696-9696-9696-9696-969696969696"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(3116));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("97979797-9797-9797-9797-979797979797"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(3119));

            migrationBuilder.UpdateData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("95959595-9595-9595-9595-959595959595"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(3094));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2726));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2728));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2729));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2730));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2731));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2732));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2733));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2734));

            migrationBuilder.InsertData(
                table: "GymTrainers",
                columns: new[] { "GymId", "TrainerId", "AssignedAtUtc" },
                values: new object[,]
                {
                    { new Guid("12121212-1212-1212-1212-121212121212"), new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("13131313-1313-1313-1313-131313131313"), new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("01010101-0101-0101-0101-010101010101"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("02020202-0202-0202-0202-020202020202"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(2804));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(3010));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(3012));

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("01010101-0101-0101-0101-010101010101"),
                columns: new[] { "Bio", "Certifications", "HourlyRate", "PhotoUrl" },
                values: new object[] { "Pilates and core stability sessions.", "Pilates Mat", 32m, "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("02020202-0202-0202-0202-020202020202"),
                column: "HourlyRate",
                value: 42m);

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"),
                columns: new[] { "Bio", "HourlyRate", "PhotoUrl" },
                values: new object[] { "Strength coach focused on compound lifts.", 40m, "https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"),
                columns: new[] { "Bio", "PhotoUrl" },
                values: new object[] { "Yoga and mobility specialist.", "https://images.unsplash.com/photo-1549576490-b0b4831ef60a?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"),
                columns: new[] { "Bio", "HourlyRate", "PhotoUrl" },
                values: new object[] { "HIIT and conditioning coach.", 38m, "https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"),
                columns: new[] { "Bio", "HourlyRate", "PhotoUrl" },
                values: new object[] { "Powerlifting and strength cycles.", 45m, "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1817));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1834));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1837));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1898));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1901));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222226"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1917));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222227"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1919));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222228"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1922));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222229"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1924));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "CreatedAtUtc", "FullName", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1904), "Amina Hadzic", "HASHED:trainer1" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                columns: new[] { "CreatedAtUtc", "FullName", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1906), "Marko Kovac", "HASHED:trainer2" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1908), "Elma Smajic" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1910), "Ivan Juric" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1913), "Sara Kostic" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1915), "Nedim Hasic" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1926));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1928));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1931));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1933));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1935));
        }
    }
}
