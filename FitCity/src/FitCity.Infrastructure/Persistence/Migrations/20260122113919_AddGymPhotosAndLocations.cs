using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddGymPhotosAndLocations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "Latitude",
                table: "Gyms",
                type: "float",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Longitude",
                table: "Gyms",
                type: "float",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "GymPhotos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Url = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GymPhotos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GymPhotos_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("12121212-1212-1212-1212-121212121212"),
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("13131313-1313-1313-1313-131313131313"),
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { 43.850099999999998, 18.395800000000001 });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"),
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { null, null });

            migrationBuilder.InsertData(
                table: "Gyms",
                columns: new[] { "Id", "Address", "City", "Description", "IsActive", "Latitude", "Longitude", "Name", "PhoneNumber", "PhotoUrl", "WorkHours" },
                values: new object[,]
                {
                    { new Guid("14141414-1414-1414-1414-141414141414"), "Zmaja od Bosne 45", "Sarajevo", "Modern gym with strength and cardio zones.", true, 43.852899999999998, 18.401199999999999, "GYM NOVO SARAJEVO", "033-510-510", "https://images.unsplash.com/photo-1534367610401-9f5ed68180aa?auto=format&fit=crop&w=800&q=80", "Mon–Fri 06:00–22:30, Sat 08:00–20:00, Sun 10:00–18:00" },
                    { new Guid("15151515-1515-1515-1515-151515151515"), "Grbavicka 12", "Sarajevo", "Neighborhood gym with group classes.", true, 43.851300000000002, 18.402799999999999, "GYM GRBAVICA", "033-520-520", "https://images.unsplash.com/photo-1574680096145-d05b474e2155?auto=format&fit=crop&w=800&q=80", "Mon–Fri 06:30–22:00, Sat 08:00–19:00, Sun 10:00–16:00" },
                    { new Guid("16161616-1616-1616-1616-161616161616"), "Marijin Dvor 5", "Sarajevo", "Fitness center with spa and recovery.", true, 43.857700000000001, 18.412700000000001, "GYM BOSNA", "033-530-530", "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?auto=format&fit=crop&w=800&q=80", "Mon–Fri 05:30–23:00, Sat 07:00–21:00, Sun 09:00–19:00" },
                    { new Guid("17171717-1717-1717-1717-171717171717"), "Bascarsija 3", "Sarajevo", "Old town gym with functional training.", true, 43.859400000000001, 18.430199999999999, "TERETANA GRADA", "033-540-540", "https://images.unsplash.com/photo-1593079831268-3381b0db4a77?auto=format&fit=crop&w=800&q=80", "Mon–Fri 07:00–21:00, Sat 08:00–18:00, Sun 10:00–16:00" }
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
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1904));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1906));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1908));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1910));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1913));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 11, 39, 18, 491, DateTimeKind.Utc).AddTicks(1915));

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

            migrationBuilder.Sql(@"
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [Email] = 'admin.novosarajevo@fitcity.local')
BEGIN
  INSERT INTO [Users] ([Id], [CreatedAtUtc], [Email], [FullName], [PasswordHash], [PhoneNumber], [Role])
  VALUES ('22222222-2222-2222-2222-222222222226', '2026-01-22T11:39:18.4911917Z', 'admin.novosarajevo@fitcity.local', 'Novo Sarajevo Admin', 'HASHED:gymnovo1', NULL, 3);
END
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [Email] = 'admin.grbavica@fitcity.local')
BEGIN
  INSERT INTO [Users] ([Id], [CreatedAtUtc], [Email], [FullName], [PasswordHash], [PhoneNumber], [Role])
  VALUES ('22222222-2222-2222-2222-222222222227', '2026-01-22T11:39:18.4911919Z', 'admin.grbavica@fitcity.local', 'Grbavica Admin', 'HASHED:gymgrb1', NULL, 3);
END
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [Email] = 'admin.bosna@fitcity.local')
BEGIN
  INSERT INTO [Users] ([Id], [CreatedAtUtc], [Email], [FullName], [PasswordHash], [PhoneNumber], [Role])
  VALUES ('22222222-2222-2222-2222-222222222228', '2026-01-22T11:39:18.4911922Z', 'admin.bosna@fitcity.local', 'Bosna Admin', 'HASHED:gymbosna1', NULL, 3);
END
IF NOT EXISTS (SELECT 1 FROM [Users] WHERE [Email] = 'admin.grada@fitcity.local')
BEGIN
  INSERT INTO [Users] ([Id], [CreatedAtUtc], [Email], [FullName], [PasswordHash], [PhoneNumber], [Role])
  VALUES ('22222222-2222-2222-2222-222222222229', '2026-01-22T11:39:18.4911924Z', 'admin.grada@fitcity.local', 'Grada Admin', 'HASHED:gymgrada1', NULL, 3);
END
");

            migrationBuilder.Sql(@"
IF NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [GymId] = '14141414-1414-1414-1414-141414141414')
BEGIN
  DECLARE @UserIdNovo UNIQUEIDENTIFIER = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = 'admin.novosarajevo@fitcity.local');
  IF @UserIdNovo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [UserId] = @UserIdNovo)
    INSERT INTO [GymAdministrators] ([Id], [AssignedAtUtc], [GymId], [UserId])
    VALUES ('9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f', '2026-01-22T11:39:18.4912731Z', '14141414-1414-1414-1414-141414141414', @UserIdNovo);
END
IF NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [GymId] = '15151515-1515-1515-1515-151515151515')
BEGIN
  DECLARE @UserIdGrb UNIQUEIDENTIFIER = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = 'admin.grbavica@fitcity.local');
  IF @UserIdGrb IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [UserId] = @UserIdGrb)
    INSERT INTO [GymAdministrators] ([Id], [AssignedAtUtc], [GymId], [UserId])
    VALUES ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', '2026-01-22T11:39:18.4912732Z', '15151515-1515-1515-1515-151515151515', @UserIdGrb);
END
IF NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [GymId] = '16161616-1616-1616-1616-161616161616')
BEGIN
  DECLARE @UserIdBos UNIQUEIDENTIFIER = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = 'admin.bosna@fitcity.local');
  IF @UserIdBos IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [UserId] = @UserIdBos)
    INSERT INTO [GymAdministrators] ([Id], [AssignedAtUtc], [GymId], [UserId])
    VALUES ('a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', '2026-01-22T11:39:18.4912733Z', '16161616-1616-1616-1616-161616161616', @UserIdBos);
END
IF NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [GymId] = '17171717-1717-1717-1717-171717171717')
BEGIN
  DECLARE @UserIdGra UNIQUEIDENTIFIER = (SELECT TOP 1 [Id] FROM [Users] WHERE [Email] = 'admin.grada@fitcity.local');
  IF @UserIdGra IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [GymAdministrators] WHERE [UserId] = @UserIdGra)
    INSERT INTO [GymAdministrators] ([Id], [AssignedAtUtc], [GymId], [UserId])
    VALUES ('a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3', '2026-01-22T11:39:18.4912734Z', '17171717-1717-1717-1717-171717171717', @UserIdGra);
END
");

            migrationBuilder.InsertData(
                table: "GymPhotos",
                columns: new[] { "Id", "GymId", "SortOrder", "Url" },
                values: new object[,]
                {
                    { new Guid("18181818-1818-1818-1818-181818181818"), new Guid("14141414-1414-1414-1414-141414141414"), 1, "https://images.unsplash.com/photo-1534367610401-9f5ed68180aa?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("19191919-1919-1919-1919-191919191919"), new Guid("14141414-1414-1414-1414-141414141414"), 2, "https://images.unsplash.com/photo-1550345332-09e3ac987658?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("1a1a1a1a-1a1a-1a1a-1a1a-1a1a1a1a1a1a"), new Guid("14141414-1414-1414-1414-141414141414"), 3, "https://images.unsplash.com/photo-1554284126-aa88f22d0a1d?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("1b1b1b1b-1b1b-1b1b-1b1b-1b1b1b1b1b1b"), new Guid("15151515-1515-1515-1515-151515151515"), 1, "https://images.unsplash.com/photo-1546483875-ad9014c88eba?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("1c1c1c1c-1c1c-1c1c-1c1c-1c1c1c1c1c1c"), new Guid("15151515-1515-1515-1515-151515151515"), 2, "https://images.unsplash.com/photo-1549576490-b0b4831ef60a?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("1d1d1d1d-1d1d-1d1d-1d1d-1d1d1d1d1d1d"), new Guid("15151515-1515-1515-1515-151515151515"), 3, "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("1e1e1e1e-1e1e-1e1e-1e1e-1e1e1e1e1e1e"), new Guid("16161616-1616-1616-1616-161616161616"), 1, "https://images.unsplash.com/photo-1546483875-ad9014c88eba?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("1f1f1f1f-1f1f-1f1f-1f1f-1f1f1f1f1f1f"), new Guid("16161616-1616-1616-1616-161616161616"), 2, "https://images.unsplash.com/photo-1554344728-77cf90d9ed26?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("20202020-2020-2020-2020-202020202020"), new Guid("16161616-1616-1616-1616-161616161616"), 3, "https://images.unsplash.com/photo-1556817411-31ae72fa3ea0?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("21212121-2121-2121-2121-212121212121"), new Guid("17171717-1717-1717-1717-171717171717"), 1, "https://images.unsplash.com/photo-1526401485004-46910ecc8e51?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("22222222-2222-2222-2222-222222222230"), new Guid("17171717-1717-1717-1717-171717171717"), 2, "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80" },
                    { new Guid("23232323-2323-2323-2323-232323232323"), new Guid("17171717-1717-1717-1717-171717171717"), 3, "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_GymPhotos_GymId_SortOrder",
                table: "GymPhotos",
                columns: new[] { "GymId", "SortOrder" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "GymPhotos");

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2"));

            migrationBuilder.DeleteData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"));

            migrationBuilder.DeleteData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("14141414-1414-1414-1414-141414141414"));

            migrationBuilder.DeleteData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("15151515-1515-1515-1515-151515151515"));

            migrationBuilder.DeleteData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("16161616-1616-1616-1616-161616161616"));

            migrationBuilder.DeleteData(
                table: "Gyms",
                keyColumn: "Id",
                keyValue: new Guid("17171717-1717-1717-1717-171717171717"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222226"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222227"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222228"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222229"));

            migrationBuilder.DropColumn(
                name: "Latitude",
                table: "Gyms");

            migrationBuilder.DropColumn(
                name: "Longitude",
                table: "Gyms");

            migrationBuilder.UpdateData(
                table: "CentralAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2535));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("96969696-9696-9696-9696-969696969696"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3236));

            migrationBuilder.UpdateData(
                table: "ConversationParticipants",
                keyColumn: "Id",
                keyValue: new Guid("97979797-9797-9797-9797-979797979797"),
                column: "JoinedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3239));

            migrationBuilder.UpdateData(
                table: "Conversations",
                keyColumn: "Id",
                keyValue: new Guid("95959595-9595-9595-9595-959595959595"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3196));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2657));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2660));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2661));

            migrationBuilder.UpdateData(
                table: "GymAdministrators",
                keyColumn: "Id",
                keyValue: new Guid("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e"),
                column: "AssignedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2662));

            migrationBuilder.UpdateData(
                table: "MembershipRequests",
                keyColumn: "Id",
                keyValue: new Guid("50505050-5050-5050-5050-505050505050"),
                column: "RequestedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(2780));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("93939393-9393-9393-9393-939393939393"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3147));

            migrationBuilder.UpdateData(
                table: "Reviews",
                keyColumn: "Id",
                keyValue: new Guid("94949494-9494-9494-9494-949494949494"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(3150));

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
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1453));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222223"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1455));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222224"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1459));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222225"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1461));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1464));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333334"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1467));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333335"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1470));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333336"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1473));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333337"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1549));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333338"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1553));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1556));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1558));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("77777777-7777-7777-7777-777777777777"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1561));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1564));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"),
                column: "CreatedAtUtc",
                value: new DateTime(2026, 1, 22, 10, 24, 33, 518, DateTimeKind.Utc).AddTicks(1566));
        }
    }
}
