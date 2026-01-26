using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddGymTrainerMediaFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"));

            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"));

            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("e0e0e0e0-e0e0-e0e0-e0e0-e0e0e0e0e0e0"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"));

            migrationBuilder.DeleteData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("30303030-3030-3030-3030-303030303030"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("f0f0f0f0-f0f0-f0f0-f0f0-f0f0f0f0f0f0"));

            migrationBuilder.DeleteData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: new Guid("90909090-9090-9090-9090-909090909090"));

            migrationBuilder.DeleteData(
                table: "QRCodes",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a0a0"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("60606060-6060-6060-6060-606060606060"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("70707070-7070-7070-7070-707070707070"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"));

            migrationBuilder.DeleteData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"));

            migrationBuilder.DeleteData(
                table: "Memberships",
                keyColumn: "Id",
                keyValue: new Guid("40404040-4040-4040-4040-404040404040"));

            migrationBuilder.DeleteData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: new Guid("80808080-8080-8080-8080-808080808080"));

            migrationBuilder.AddColumn<decimal>(
                name: "HourlyRate",
                table: "Trainers",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PhotoUrl",
                table: "Trainers",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PhotoUrl",
                table: "Gyms",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "WorkHours",
                table: "Gyms",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.InsertData(
                table: "CentralAdministrators",
                columns: new[] { "Id", "AssignedAtUtc", "UserId" },
                values: new object[] { new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2535), new Guid("11111111-1111-1111-1111-111111111111") });

            migrationBuilder.InsertData(
                table: "Conversations",
                columns: new[] { "Id", "CreatedAtUtc", "Title" },
                values: new object[] { new Guid("95959595-9595-9595-9595-959595959595"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3196), "Training chat" });

            migrationBuilder.InsertData(
                table: "GymAdministrators",
                columns: new[] { "Id", "AssignedAtUtc", "GymId", "UserId" },
                values: new object[] { new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2657), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("22222222-2222-2222-2222-222222222222") });

            migrationBuilder.UpdateData(
                table: "GymPlans",
                keyColumn: "Id",
                keyValue: new Guid("20202020-2020-2020-2020-202020202020"),
                column: "GymId",
                value: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"));

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
                columns: new[] { "Address", "Description", "PhoneNumber", "PhotoUrl", "WorkHours" },
                values: new object[] { "Zmaja od Bosne 12", "Central location near Marijin Dvor.", "033-100-100", "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80", "06:00-22:00" });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
                columns: new[] { "Address", "Description", "Name", "PhoneNumber", "PhotoUrl", "WorkHours" },
                values: new object[] { "Hrasnicka Cesta 10", "Spacious gym with wellness zone.", "FitCity Ilidza", "033-200-200", "https://images.unsplash.com/photo-1554344728-77cf90d9ed26?auto=format&fit=crop&w=800&q=80", "06:00-23:00" });

            migrationBuilder.InsertData(
                table: "Gyms",
                columns: new[] { "Id", "Address", "City", "Description", "IsActive", "Name", "PhoneNumber", "PhotoUrl", "WorkHours" },
                values: new object[,]
                {
                    { new Guid("12121212-1212-1212-1212-121212121212"), "Saraci 45", "Sarajevo", "Boutique studio in the old town.", true, "FitCity Bascarsija", "033-300-300", "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80", "07:00-21:00" },
                    { new Guid("13131313-1313-1313-1313-131313131313"), "Zvornička 1", "Sarajevo", "Neighborhood gym with boxing zone.", true, "FitCity Grbavica", "033-400-400", "https://images.unsplash.com/photo-1571019613914-85f342c55f42?auto=format&fit=crop&w=800&q=80", "06:30-22:30" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAtUtc", "Email", "FullName", "PasswordHash", "PhoneNumber", "Role" },
                values: new object[,]
                {
                    { new Guid("22222222-2222-2222-2222-222222222223"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1455), "admin.ilidza@fitcity.local", "Ilidza Admin", "HASHED:gymadmin2", null, 3 },
                    { new Guid("22222222-2222-2222-2222-222222222224"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1459), "admin.bascarsija@fitcity.local", "Bascarsija Admin", "HASHED:gymadmin3", null, 3 },
                    { new Guid("22222222-2222-2222-2222-222222222225"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1461), "admin.grbavica@fitcity.local", "Grbavica Admin", "HASHED:gymadmin4", null, 3 },
                    { new Guid("33333333-3333-3333-3333-333333333334"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1467), "trainer2@gym.local", "Marko Kovac", "HASHED:trainer2", null, 2 },
                    { new Guid("33333333-3333-3333-3333-333333333335"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1470), "trainer3@gym.local", "Elma Smajic", "HASHED:trainer3pass", null, 2 },
                    { new Guid("33333333-3333-3333-3333-333333333336"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1473), "trainer4@gym.local", "Ivan Juric", "HASHED:trainer4pass", null, 2 },
                    { new Guid("33333333-3333-3333-3333-333333333337"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1549), "trainer5@gym.local", "Sara Kostic", "HASHED:trainer5pass", null, 2 },
                    { new Guid("33333333-3333-3333-3333-333333333338"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1553), "trainer6@gym.local", "Nedim Hasic", "HASHED:trainer6pass", null, 2 }
                });

            migrationBuilder.InsertData(
                table: "Trainers",
                columns: new[] { "Id", "Bio", "Certifications", "HourlyRate", "IsActive", "PhotoUrl", "UserId" },
                values: new object[] { new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), "Yoga and mobility specialist.", "RYT-200", 35m, true, "https://images.unsplash.com/photo-1549576490-b0b4831ef60a?auto=format&fit=crop&w=600&q=80", new Guid("33333333-3333-3333-3333-333333333334") });

            migrationBuilder.InsertData(
                table: "MembershipRequests",
                columns: new[] { "Id", "GymId", "GymPlanId", "RequestedAtUtc", "Status", "UserId" },
                values: new object[] { new Guid("50505050-5050-5050-5050-505050505050"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("10101010-1010-1010-1010-101010101010"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2780), 1, new Guid("55555555-5555-5555-5555-555555555555") });

            migrationBuilder.InsertData(
                table: "Memberships",
                columns: new[] { "Id", "EndDateUtc", "GymId", "GymPlanId", "StartDateUtc", "Status", "UserId" },
                values: new object[] { new Guid("60606060-6060-6060-6060-606060606060"), new DateTime(2025, 4, 1, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("10101010-1010-1010-1010-101010101010"), new DateTime(2024, 12, 22, 8, 0, 0, 0, DateTimeKind.Utc), 1, new Guid("66666666-6666-6666-6666-666666666666") });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "Comment", "CreatedAtUtc", "GymId", "Rating", "TrainerId", "UserId" },
                values: new object[] { new Guid("93939393-9393-9393-9393-939393939393"), "Great session.", new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3147), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), 5, new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new Guid("77777777-7777-7777-7777-777777777777") });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"),
                columns: new[] { "Bio", "Certifications", "HourlyRate", "PhotoUrl" },
                values: new object[] { "Strength coach focused on compound lifts.", "NSCA CPT", 40m, "https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?auto=format&fit=crop&w=600&q=80" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"),
                columns: new[] { "Bio", "HourlyRate", "PhotoUrl", "UserId" },
                values: new object[] { "Yoga and mobility specialist.", 35m, "https://images.unsplash.com/photo-1549576490-b0b4831ef60a?auto=format&fit=crop&w=600&q=80", new Guid("33333333-3333-3333-3333-333333333334") });

            migrationBuilder.InsertData(
                table: "TrainerSchedules",
                columns: new[] { "Id", "EndUtc", "GymId", "IsAvailable", "StartUtc", "TrainerId" },
                values: new object[,]
                {
                    { new Guid("80808080-8080-8080-8080-808080808080"), new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), true, new DateTime(2025, 1, 2, 9, 0, 0, 0, DateTimeKind.Utc), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc") },
                    { new Guid("81818181-8181-8181-8181-818181818181"), new DateTime(2025, 1, 2, 13, 0, 0, 0, DateTimeKind.Utc), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), true, new DateTime(2025, 1, 2, 12, 0, 0, 0, DateTimeKind.Utc), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd") }
                });

            migrationBuilder.InsertData(
                table: "TrainingSessions",
                columns: new[] { "Id", "EndUtc", "GymId", "StartUtc", "Status", "TrainerId", "UserId" },
                values: new object[] { new Guid("90909090-9090-9090-9090-909090909090"), new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new DateTime(2025, 1, 2, 9, 0, 0, 0, DateTimeKind.Utc), 2, new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new Guid("77777777-7777-7777-7777-777777777777") });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1433));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "CreatedAtUtc", "Email", "FullName", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1453), "admin.downtown@fitcity.local", "Downtown Admin", "HASHED:gymadmin1" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1464), "Amina Hadzic" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1556), "HASHED:user1pass" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1558), "HASHED:user2pass" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1561), "HASHED:user3pass" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1564), "HASHED:user4pass" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1566), "HASHED:user5pass" });

            migrationBuilder.InsertData(
                table: "ConversationParticipants",
                columns: new[] { "Id", "ConversationId", "JoinedAtUtc", "UserId" },
                values: new object[,]
                {
                    { new Guid("96969696-9696-9696-9696-969696969696"), new Guid("95959595-9595-9595-9595-959595959595"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3236), new Guid("55555555-5555-5555-5555-555555555555") },
                    { new Guid("97979797-9797-9797-9797-979797979797"), new Guid("95959595-9595-9595-9595-959595959595"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3239), new Guid("33333333-3333-3333-3333-333333333333") }
                });

            migrationBuilder.InsertData(
                table: "GymAdministrators",
                columns: new[] { "Id", "AssignedAtUtc", "GymId", "UserId" },
                values: new object[,]
                {
                    { new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2660), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("22222222-2222-2222-2222-222222222223") },
                    { new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2661), new Guid("12121212-1212-1212-1212-121212121212"), new Guid("22222222-2222-2222-2222-222222222224") },
                    { new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"), new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2662), new Guid("13131313-1313-1313-1313-131313131313"), new Guid("22222222-2222-2222-2222-222222222225") }
                });

            migrationBuilder.InsertData(
                table: "GymPlans",
                columns: new[] { "Id", "Description", "DurationMonths", "GymId", "IsActive", "Name", "Price" },
                values: new object[,]
                {
                    { new Guid("30303030-3030-3030-3030-303030303030"), "Annual membership.", 12, new Guid("12121212-1212-1212-1212-121212121212"), true, "Annual", 399.99m },
                    { new Guid("40404040-4040-4040-4040-404040404040"), "10 session pack.", 3, new Guid("13131313-1313-1313-1313-131313131313"), true, "Drop-in 10", 89.99m }
                });

            migrationBuilder.InsertData(
                table: "Messages",
                columns: new[] { "Id", "Content", "ConversationId", "SenderUserId", "SentAtUtc" },
                values: new object[] { new Guid("98989898-9898-9898-9898-989898989898"), "Welcome to FitCity!", new Guid("95959595-9595-9595-9595-959595959595"), new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2025, 1, 1, 3, 0, 0, 0, DateTimeKind.Utc) });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Amount", "MembershipId", "Method", "PaidAtUtc", "TrainingSessionId" },
                values: new object[] { new Guid("92929292-9292-9292-9292-929292929292"), 30m, null, 1, new DateTime(2024, 12, 31, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("90909090-9090-9090-9090-909090909090") });

            migrationBuilder.InsertData(
                table: "QRCodes",
                columns: new[] { "Id", "ExpiresAtUtc", "MembershipId", "TokenHash" },
                values: new object[] { new Guid("70707070-7070-7070-7070-707070707070"), new DateTime(2025, 1, 31, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("60606060-6060-6060-6060-606060606060"), "token-hash-1" });

            migrationBuilder.InsertData(
                table: "Trainers",
                columns: new[] { "Id", "Bio", "Certifications", "HourlyRate", "IsActive", "PhotoUrl", "UserId" },
                values: new object[,]
                {
                    { new Guid("01010101-0101-0101-0101-010101010101"), "Pilates and core stability sessions.", "Pilates Mat", 32m, true, "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80", new Guid("33333333-3333-3333-3333-333333333337") },
                    { new Guid("02020202-0202-0202-0202-020202020202"), "Boxing fundamentals and conditioning.", "Boxing Level 2", 42m, true, "https://images.unsplash.com/photo-1508341591423-4347099e1f19?auto=format&fit=crop&w=600&q=80", new Guid("33333333-3333-3333-3333-333333333338") },
                    { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), "HIIT and conditioning coach.", "ACE CPT", 38m, true, "https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80", new Guid("33333333-3333-3333-3333-333333333335") },
                    { new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), "Powerlifting and strength cycles.", "IPF Level 1", 45m, true, "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80", new Guid("33333333-3333-3333-3333-333333333336") }
                });

            migrationBuilder.InsertData(
                table: "GymTrainers",
                columns: new[] { "GymId", "TrainerId", "AssignedAtUtc" },
                values: new object[,]
                {
                    { new Guid("12121212-1212-1212-1212-121212121212"), new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("13131313-1313-1313-1313-131313131313"), new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("01010101-0101-0101-0101-010101010101"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("02020202-0202-0202-0202-020202020202"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "Comment", "CreatedAtUtc", "GymId", "Rating", "TrainerId", "UserId" },
                values: new object[] { new Guid("94949494-9494-9494-9494-949494949494"), "Nice class.", new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3150), new Guid("12121212-1212-1212-1212-121212121212"), 4, new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), new Guid("88888888-8888-8888-8888-888888888888") });

            migrationBuilder.InsertData(
                table: "TrainerSchedules",
                columns: new[] { "Id", "EndUtc", "GymId", "IsAvailable", "StartUtc", "TrainerId" },
                values: new object[,]
                {
                    { new Guid("82828282-8282-8282-8282-828282828282"), new DateTime(2025, 1, 3, 18, 0, 0, 0, DateTimeKind.Utc), new Guid("12121212-1212-1212-1212-121212121212"), true, new DateTime(2025, 1, 3, 17, 0, 0, 0, DateTimeKind.Utc), new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee") },
                    { new Guid("83838383-8383-8383-8383-838383838383"), new DateTime(2025, 1, 3, 9, 0, 0, 0, DateTimeKind.Utc), new Guid("13131313-1313-1313-1313-131313131313"), false, new DateTime(2025, 1, 3, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff") },
                    { new Guid("84848484-8484-8484-8484-848484848484"), new DateTime(2025, 1, 4, 16, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), true, new DateTime(2025, 1, 4, 15, 0, 0, 0, DateTimeKind.Utc), new Guid("01010101-0101-0101-0101-010101010101") },
                    { new Guid("85858585-8585-8585-8585-858585858585"), new DateTime(2025, 1, 4, 19, 0, 0, 0, DateTimeKind.Utc), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), true, new DateTime(2025, 1, 4, 18, 0, 0, 0, DateTimeKind.Utc), new Guid("02020202-0202-0202-0202-020202020202") }
                });

            migrationBuilder.InsertData(
                table: "TrainingSessions",
                columns: new[] { "Id", "EndUtc", "GymId", "StartUtc", "Status", "TrainerId", "UserId" },
                values: new object[] { new Guid("91919191-9191-9191-9191-919191919191"), new DateTime(2025, 1, 3, 18, 0, 0, 0, DateTimeKind.Utc), new Guid("12121212-1212-1212-1212-121212121212"), new DateTime(2025, 1, 3, 17, 0, 0, 0, DateTimeKind.Utc), 2, new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), new Guid("88888888-8888-8888-8888-888888888888") });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"));

            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("96969696-9696-9696-9696-969696969696"));

            migrationBuilder.DeleteData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("97979797-9797-9797-9797-979797979797"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"));

            migrationBuilder.DeleteData(
                table: "GymPlans",
                keyColumn: "Id",
                keyValue: new Guid("30303030-3030-3030-3030-303030303030"));

            migrationBuilder.DeleteData(
                table: "GymPlans",
                keyColumn: "Id",
                keyValue: new Guid("40404040-4040-4040-4040-404040404040"));

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
                keyValues: new object[] { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("02020202-0202-0202-0202-020202020202") });

            migrationBuilder.DeleteData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"));

            migrationBuilder.DeleteData(
                table: "Messages",
                keyColumn: "Id",
                keyValue: new Guid("98989898-9898-9898-9898-989898989898"));

            migrationBuilder.DeleteData(
                table: "Payments",
                keyColumn: "Id",
                keyValue: new Guid("92929292-9292-9292-9292-929292929292"));

            migrationBuilder.DeleteData(
                table: "QRCodes",
                keyColumn: "Id",
                keyValue: new Guid("70707070-7070-7070-7070-707070707070"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"));

            migrationBuilder.DeleteData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("80808080-8080-8080-8080-808080808080"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("81818181-8181-8181-8181-818181818181"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("82828282-8282-8282-8282-828282828282"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("83838383-8383-8383-8383-838383838383"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("84848484-8484-8484-8484-848484848484"));

            migrationBuilder.DeleteData(
                table: "TrainerSchedules",
                keyColumn: "Id",
                keyValue: new Guid("85858585-8585-8585-8585-858585858585"));

            migrationBuilder.DeleteData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: new Guid("91919191-9191-9191-9191-919191919191"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"));

            migrationBuilder.DeleteData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("95959595-9595-9595-9595-959595959595"));

            migrationBuilder.DeleteData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("12121212-1212-1212-1212-121212121212"));

            migrationBuilder.DeleteData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("13131313-1313-1313-1313-131313131313"));

            migrationBuilder.DeleteData(
                table: "Memberships",
                keyColumn: "Id",
                keyValue: new Guid("60606060-6060-6060-6060-606060606060"));

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("01010101-0101-0101-0101-010101010101"));

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("02020202-0202-0202-0202-020202020202"));

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"));

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"));

            migrationBuilder.DeleteData(
                table: "TrainingSessions",
                keyColumn: "Id",
                keyValue: new Guid("90909090-9090-9090-9090-909090909090"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"));

            migrationBuilder.DropColumn(
                name: "HourlyRate",
                table: "Trainers");

            migrationBuilder.DropColumn(
                name: "PhotoUrl",
                table: "Trainers");

            migrationBuilder.DropColumn(
                name: "PhotoUrl",
                table: "Gyms");

            migrationBuilder.DropColumn(
                name: "WorkHours",
                table: "Gyms");

            migrationBuilder.InsertData(
                table: "CentralAdministrators",
                columns: new[] { "Id", "AssignedAtUtc", "UserId" },
                values: new object[] { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(273), new Guid("11111111-1111-1111-1111-111111111111") });

            migrationBuilder.InsertData(
                table: "Conversations",
                columns: new[] { "Id", "CreatedAtUtc", "Title" },
                values: new object[] { new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(573), "Training chat" });

            migrationBuilder.InsertData(
                table: "GymAdministrators",
                columns: new[] { "Id", "AssignedAtUtc", "GymId", "UserId" },
                values: new object[] { new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(301), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("22222222-2222-2222-2222-222222222222") });

            migrationBuilder.UpdateData(
                table: "GymPlans",
                keyColumn: "Id",
                keyValue: new Guid("20202020-2020-2020-2020-202020202020"),
                column: "GymId",
                value: new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"));

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
                columns: new[] { "Address", "Description", "PhoneNumber" },
                values: new object[] { "Main Street 1", "Main gym location.", "111-222" });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
                columns: new[] { "Address", "Description", "Name", "PhoneNumber" },
                values: new object[] { "River Road 10", "Second gym location.", "FitCity East", "333-444" });

            migrationBuilder.InsertData(
                table: "MembershipRequests",
                columns: new[] { "Id", "GymId", "GymPlanId", "RequestedAtUtc", "Status", "UserId" },
                values: new object[] { new Guid("30303030-3030-3030-3030-303030303030"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("10101010-1010-1010-1010-101010101010"), new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(361), 1, new Guid("55555555-5555-5555-5555-555555555555") });

            migrationBuilder.InsertData(
                table: "Memberships",
                columns: new[] { "Id", "EndDateUtc", "GymId", "GymPlanId", "StartDateUtc", "Status", "UserId" },
                values: new object[] { new Guid("40404040-4040-4040-4040-404040404040"), new DateTime(2025, 4, 1, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("20202020-2020-2020-2020-202020202020"), new DateTime(2024, 12, 22, 8, 0, 0, 0, DateTimeKind.Utc), 1, new Guid("66666666-6666-6666-6666-666666666666") });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "Comment", "CreatedAtUtc", "GymId", "Rating", "TrainerId", "UserId" },
                values: new object[,]
                {
                    { new Guid("a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a0a0"), "Great session.", new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(546), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), 5, new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new Guid("77777777-7777-7777-7777-777777777777") },
                    { new Guid("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0"), "Nice class.", new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(549), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), 4, new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), new Guid("88888888-8888-8888-8888-888888888888") }
                });

            migrationBuilder.InsertData(
                table: "TrainerSchedules",
                columns: new[] { "Id", "EndUtc", "GymId", "IsAvailable", "StartUtc", "TrainerId" },
                values: new object[,]
                {
                    { new Guid("60606060-6060-6060-6060-606060606060"), new DateTime(2025, 1, 2, 12, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), true, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Utc), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc") },
                    { new Guid("70707070-7070-7070-7070-707070707070"), new DateTime(2025, 1, 3, 16, 0, 0, 0, DateTimeKind.Utc), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), true, new DateTime(2025, 1, 3, 14, 0, 0, 0, DateTimeKind.Utc), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd") }
                });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"),
                columns: new[] { "Bio", "Certifications" },
                values: new object[] { "Strength coach.", "NSCA" });

            migrationBuilder.UpdateData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"),
                columns: new[] { "Bio", "UserId" },
                values: new object[] { "Yoga and mobility.", new Guid("44444444-4444-4444-4444-444444444444") });

            migrationBuilder.InsertData(
                table: "TrainingSessions",
                columns: new[] { "Id", "EndUtc", "GymId", "StartUtc", "Status", "TrainerId", "UserId" },
                values: new object[] { new Guid("80808080-8080-8080-8080-808080808080"), new DateTime(2025, 1, 2, 11, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Utc), 2, new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new Guid("77777777-7777-7777-7777-777777777777") });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9784));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "CreatedAtUtc", "Email", "FullName", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9797), "admin@gym.local", "Gym Admin", "HASHED:gymadmin" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "CreatedAtUtc", "FullName" },
                values: new object[] { new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9799), "Trainer One" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9803), "HASHED:user1" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9805), "HASHED:user2" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9807), "HASHED:user3" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9810), "HASHED:user4" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                columns: new[] { "CreatedAtUtc", "PasswordHash" },
                values: new object[] { new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9812), "HASHED:user5" });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAtUtc", "Email", "FullName", "PasswordHash", "PhoneNumber", "Role" },
                values: new object[] { new Guid("44444444-4444-4444-4444-444444444444"), new DateTime(2026, 1, 21, 20, 21, 49, 823, DateTimeKind.Utc).AddTicks(9801), "trainer2@gym.local", "Trainer Two", "HASHED:trainer2", null, 2 });

            migrationBuilder.InsertData(
                table: "ConversationParticipants",
                columns: new[] { "Id", "ConversationId", "JoinedAtUtc", "UserId" },
                values: new object[,]
                {
                    { new Guid("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"), new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(595), new Guid("55555555-5555-5555-5555-555555555555") },
                    { new Guid("e0e0e0e0-e0e0-e0e0-e0e0-e0e0e0e0e0e0"), new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new DateTime(2026, 1, 21, 20, 21, 49, 824, DateTimeKind.Utc).AddTicks(597), new Guid("33333333-3333-3333-3333-333333333333") }
                });

            migrationBuilder.InsertData(
                table: "Messages",
                columns: new[] { "Id", "Content", "ConversationId", "SenderUserId", "SentAtUtc" },
                values: new object[] { new Guid("f0f0f0f0-f0f0-f0f0-f0f0-f0f0f0f0f0f0"), "Welcome to FitCity!", new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2025, 1, 1, 3, 0, 0, 0, DateTimeKind.Utc) });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Amount", "MembershipId", "Method", "PaidAtUtc", "TrainingSessionId" },
                values: new object[] { new Guid("90909090-9090-9090-9090-909090909090"), 30m, null, 1, new DateTime(2024, 12, 31, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("80808080-8080-8080-8080-808080808080") });

            migrationBuilder.InsertData(
                table: "QRCodes",
                columns: new[] { "Id", "ExpiresAtUtc", "MembershipId", "TokenHash" },
                values: new object[] { new Guid("50505050-5050-5050-5050-505050505050"), new DateTime(2025, 1, 31, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("40404040-4040-4040-4040-404040404040"), "token-hash-1" });
        }
    }
}
