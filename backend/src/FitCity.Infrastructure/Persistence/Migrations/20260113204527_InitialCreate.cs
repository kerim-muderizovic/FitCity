using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitCity.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Conversations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Conversations", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Gyms",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Address = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    City = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: true),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Gyms", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: true),
                    Role = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "GymPlans",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    DurationMonths = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GymPlans", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GymPlans_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CentralAdministrators",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AssignedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CentralAdministrators", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CentralAdministrators_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CheckInLogs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ScannedByUserId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    CheckInAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CheckInLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CheckInLogs_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CheckInLogs_Users_ScannedByUserId",
                        column: x => x.ScannedByUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CheckInLogs_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ConversationParticipants",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ConversationId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    JoinedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ConversationParticipants", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ConversationParticipants_Conversations_ConversationId",
                        column: x => x.ConversationId,
                        principalTable: "Conversations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ConversationParticipants_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "GymAdministrators",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AssignedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GymAdministrators", x => x.Id);
                    table.ForeignKey(
                        name: "FK_GymAdministrators_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_GymAdministrators_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Messages",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ConversationId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    SenderUserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    SentAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Messages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Messages_Conversations_ConversationId",
                        column: x => x.ConversationId,
                        principalTable: "Conversations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Messages_Users_SenderUserId",
                        column: x => x.SenderUserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Preferences",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    FitnessGoal = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    PreferredWorkoutTime = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    NotificationsEnabled = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Preferences", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Preferences_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Trainers",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Bio = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    Certifications = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Trainers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Trainers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "MembershipRequests",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymPlanId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    Status = table.Column<int>(type: "int", nullable: false),
                    RequestedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MembershipRequests", x => x.Id);
                    table.CheckConstraint("CK_MembershipRequest_Status", "[Status] IN (1,2,3,4)");
                    table.ForeignKey(
                        name: "FK_MembershipRequests_GymPlans_GymPlanId",
                        column: x => x.GymPlanId,
                        principalTable: "GymPlans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_MembershipRequests_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MembershipRequests_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Memberships",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymPlanId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    StartDateUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDateUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Memberships", x => x.Id);
                    table.CheckConstraint("CK_Membership_Status", "[Status] IN (1,2,3,4)");
                    table.ForeignKey(
                        name: "FK_Memberships_GymPlans_GymPlanId",
                        column: x => x.GymPlanId,
                        principalTable: "GymPlans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Memberships_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Memberships_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "GymTrainers",
                columns: table => new
                {
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TrainerId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AssignedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GymTrainers", x => new { x.GymId, x.TrainerId });
                    table.ForeignKey(
                        name: "FK_GymTrainers_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_GymTrainers_Trainers_TrainerId",
                        column: x => x.TrainerId,
                        principalTable: "Trainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TrainerId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    Rating = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.Id);
                    table.CheckConstraint("CK_Review_Rating", "[Rating] BETWEEN 1 AND 5");
                    table.ForeignKey(
                        name: "FK_Reviews_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Reviews_Trainers_TrainerId",
                        column: x => x.TrainerId,
                        principalTable: "Trainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Reviews_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "TrainerSchedules",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TrainerId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    StartUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainerSchedules", x => x.Id);
                    table.CheckConstraint("CK_TrainerSchedule_Time", "[EndUtc] > [StartUtc]");
                    table.ForeignKey(
                        name: "FK_TrainerSchedules_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_TrainerSchedules_Trainers_TrainerId",
                        column: x => x.TrainerId,
                        principalTable: "Trainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TrainingSessions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TrainerId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    GymId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    StartUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingSessions", x => x.Id);
                    table.CheckConstraint("CK_TrainingSession_Status", "[Status] IN (1,2,3,4)");
                    table.CheckConstraint("CK_TrainingSession_Time", "[EndUtc] > [StartUtc]");
                    table.ForeignKey(
                        name: "FK_TrainingSessions_Gyms_GymId",
                        column: x => x.GymId,
                        principalTable: "Gyms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_TrainingSessions_Trainers_TrainerId",
                        column: x => x.TrainerId,
                        principalTable: "Trainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TrainingSessions_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "QRCodes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    MembershipId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TokenHash = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    ExpiresAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_QRCodes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_QRCodes_Memberships_MembershipId",
                        column: x => x.MembershipId,
                        principalTable: "Memberships",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Method = table.Column<int>(type: "int", nullable: false),
                    PaidAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    MembershipId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    TrainingSessionId = table.Column<Guid>(type: "uniqueidentifier", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.Id);
                    table.CheckConstraint("CK_Payment_Method", "[Method] IN (1,2,3)");
                    table.CheckConstraint("CK_Payment_Target", "([MembershipId] IS NOT NULL AND [TrainingSessionId] IS NULL) OR ([MembershipId] IS NULL AND [TrainingSessionId] IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_Payments_Memberships_MembershipId",
                        column: x => x.MembershipId,
                        principalTable: "Memberships",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Payments_TrainingSessions_TrainingSessionId",
                        column: x => x.TrainingSessionId,
                        principalTable: "TrainingSessions",
                        principalColumn: "Id");
                });

            migrationBuilder.InsertData(
                table: "Conversations",
                columns: new[] { "Id", "CreatedAtUtc", "Title" },
                values: new object[] { new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8949), "Training chat" });

            migrationBuilder.InsertData(
                table: "Gyms",
                columns: new[] { "Id", "Address", "City", "Description", "IsActive", "Name", "PhoneNumber" },
                values: new object[,]
                {
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), "Main Street 1", "Sarajevo", "Main gym location.", true, "FitCity Downtown", "111-222" },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), "River Road 10", "Sarajevo", "Second gym location.", true, "FitCity East", "333-444" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAtUtc", "Email", "FullName", "PasswordHash", "PhoneNumber", "Role" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8308), "central@fitcity.local", "Central Admin", "HASHED:central", null, 4 },
                    { new Guid("22222222-2222-2222-2222-222222222222"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8318), "admin@gym.local", "Gym Admin", "HASHED:gymadmin", null, 3 },
                    { new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8320), "trainer1@gym.local", "Trainer One", "HASHED:trainer1", null, 2 },
                    { new Guid("44444444-4444-4444-4444-444444444444"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8323), "trainer2@gym.local", "Trainer Two", "HASHED:trainer2", null, 2 },
                    { new Guid("55555555-5555-5555-5555-555555555555"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8325), "user1@gym.local", "User One", "HASHED:user1", null, 1 },
                    { new Guid("66666666-6666-6666-6666-666666666666"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8327), "user2@gym.local", "User Two", "HASHED:user2", null, 1 },
                    { new Guid("77777777-7777-7777-7777-777777777777"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8329), "user3@gym.local", "User Three", "HASHED:user3", null, 1 },
                    { new Guid("88888888-8888-8888-8888-888888888888"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8331), "user4@gym.local", "User Four", "HASHED:user4", null, 1 },
                    { new Guid("99999999-9999-9999-9999-999999999999"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8333), "user5@gym.local", "User Five", "HASHED:user5", null, 1 }
                });

            migrationBuilder.InsertData(
                table: "CentralAdministrators",
                columns: new[] { "Id", "AssignedAtUtc", "UserId" },
                values: new object[] { new Guid("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8664), new Guid("11111111-1111-1111-1111-111111111111") });

            migrationBuilder.InsertData(
                table: "ConversationParticipants",
                columns: new[] { "Id", "ConversationId", "JoinedAtUtc", "UserId" },
                values: new object[,]
                {
                    { new Guid("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"), new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8972), new Guid("55555555-5555-5555-5555-555555555555") },
                    { new Guid("e0e0e0e0-e0e0-e0e0-e0e0-e0e0e0e0e0e0"), new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8973), new Guid("33333333-3333-3333-3333-333333333333") }
                });

            migrationBuilder.InsertData(
                table: "GymAdministrators",
                columns: new[] { "Id", "AssignedAtUtc", "GymId", "UserId" },
                values: new object[] { new Guid("ffffffff-ffff-ffff-ffff-ffffffffffff"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8686), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("22222222-2222-2222-2222-222222222222") });

            migrationBuilder.InsertData(
                table: "GymPlans",
                columns: new[] { "Id", "Description", "DurationMonths", "GymId", "IsActive", "Name", "Price" },
                values: new object[,]
                {
                    { new Guid("10101010-1010-1010-1010-101010101010"), "One month access.", 1, new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), true, "Monthly", 49.99m },
                    { new Guid("20202020-2020-2020-2020-202020202020"), "Three months access.", 3, new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), true, "Quarterly", 129.99m }
                });

            migrationBuilder.InsertData(
                table: "Messages",
                columns: new[] { "Id", "Content", "ConversationId", "SenderUserId", "SentAtUtc" },
                values: new object[] { new Guid("f0f0f0f0-f0f0-f0f0-f0f0-f0f0f0f0f0f0"), "Welcome to FitCity!", new Guid("c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0"), new Guid("33333333-3333-3333-3333-333333333333"), new DateTime(2025, 1, 1, 3, 0, 0, 0, DateTimeKind.Utc) });

            migrationBuilder.InsertData(
                table: "Trainers",
                columns: new[] { "Id", "Bio", "Certifications", "IsActive", "UserId" },
                values: new object[,]
                {
                    { new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), "Strength coach.", "NSCA", true, new Guid("33333333-3333-3333-3333-333333333333") },
                    { new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), "Yoga and mobility.", "RYT-200", true, new Guid("44444444-4444-4444-4444-444444444444") }
                });

            migrationBuilder.InsertData(
                table: "GymTrainers",
                columns: new[] { "GymId", "TrainerId", "AssignedAtUtc" },
                values: new object[,]
                {
                    { new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), new DateTime(2025, 1, 1, 8, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "MembershipRequests",
                columns: new[] { "Id", "GymId", "GymPlanId", "RequestedAtUtc", "Status", "UserId" },
                values: new object[] { new Guid("30303030-3030-3030-3030-303030303030"), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("10101010-1010-1010-1010-101010101010"), new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8745), 1, new Guid("55555555-5555-5555-5555-555555555555") });

            migrationBuilder.InsertData(
                table: "Memberships",
                columns: new[] { "Id", "EndDateUtc", "GymId", "GymPlanId", "StartDateUtc", "Status", "UserId" },
                values: new object[] { new Guid("40404040-4040-4040-4040-404040404040"), new DateTime(2025, 4, 1, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new Guid("20202020-2020-2020-2020-202020202020"), new DateTime(2024, 12, 22, 8, 0, 0, 0, DateTimeKind.Utc), 1, new Guid("66666666-6666-6666-6666-666666666666") });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "Id", "Comment", "CreatedAtUtc", "GymId", "Rating", "TrainerId", "UserId" },
                values: new object[,]
                {
                    { new Guid("a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a0a0"), "Great session.", new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8923), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), 5, new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new Guid("77777777-7777-7777-7777-777777777777") },
                    { new Guid("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0"), "Nice class.", new DateTime(2026, 1, 13, 20, 45, 26, 1, DateTimeKind.Utc).AddTicks(8926), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), 4, new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd"), new Guid("88888888-8888-8888-8888-888888888888") }
                });

            migrationBuilder.InsertData(
                table: "TrainerSchedules",
                columns: new[] { "Id", "EndUtc", "GymId", "IsAvailable", "StartUtc", "TrainerId" },
                values: new object[,]
                {
                    { new Guid("60606060-6060-6060-6060-606060606060"), new DateTime(2025, 1, 2, 12, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), true, new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Utc), new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc") },
                    { new Guid("70707070-7070-7070-7070-707070707070"), new DateTime(2025, 1, 3, 16, 0, 0, 0, DateTimeKind.Utc), new Guid("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"), true, new DateTime(2025, 1, 3, 14, 0, 0, 0, DateTimeKind.Utc), new Guid("dddddddd-dddd-dddd-dddd-dddddddddddd") }
                });

            migrationBuilder.InsertData(
                table: "TrainingSessions",
                columns: new[] { "Id", "EndUtc", "GymId", "StartUtc", "Status", "TrainerId", "UserId" },
                values: new object[] { new Guid("80808080-8080-8080-8080-808080808080"), new DateTime(2025, 1, 2, 11, 0, 0, 0, DateTimeKind.Utc), new Guid("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"), new DateTime(2025, 1, 2, 10, 0, 0, 0, DateTimeKind.Utc), 2, new Guid("cccccccc-cccc-cccc-cccc-cccccccccccc"), new Guid("77777777-7777-7777-7777-777777777777") });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Amount", "MembershipId", "Method", "PaidAtUtc", "TrainingSessionId" },
                values: new object[] { new Guid("90909090-9090-9090-9090-909090909090"), 30m, null, 1, new DateTime(2024, 12, 31, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("80808080-8080-8080-8080-808080808080") });

            migrationBuilder.InsertData(
                table: "QRCodes",
                columns: new[] { "Id", "ExpiresAtUtc", "MembershipId", "TokenHash" },
                values: new object[] { new Guid("50505050-5050-5050-5050-505050505050"), new DateTime(2025, 1, 31, 8, 0, 0, 0, DateTimeKind.Utc), new Guid("40404040-4040-4040-4040-404040404040"), "token-hash-1" });

            migrationBuilder.CreateIndex(
                name: "IX_CentralAdministrators_UserId",
                table: "CentralAdministrators",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CheckInLogs_GymId",
                table: "CheckInLogs",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_CheckInLogs_ScannedByUserId",
                table: "CheckInLogs",
                column: "ScannedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_CheckInLogs_UserId",
                table: "CheckInLogs",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ConversationParticipants_ConversationId_UserId",
                table: "ConversationParticipants",
                columns: new[] { "ConversationId", "UserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ConversationParticipants_UserId",
                table: "ConversationParticipants",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_GymAdministrators_GymId_UserId",
                table: "GymAdministrators",
                columns: new[] { "GymId", "UserId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_GymAdministrators_UserId",
                table: "GymAdministrators",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_GymPlans_GymId",
                table: "GymPlans",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_GymTrainers_TrainerId",
                table: "GymTrainers",
                column: "TrainerId");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipRequests_GymId",
                table: "MembershipRequests",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipRequests_GymPlanId",
                table: "MembershipRequests",
                column: "GymPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipRequests_UserId_GymId",
                table: "MembershipRequests",
                columns: new[] { "UserId", "GymId" });

            migrationBuilder.CreateIndex(
                name: "IX_Memberships_GymId",
                table: "Memberships",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_Memberships_GymPlanId",
                table: "Memberships",
                column: "GymPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_Memberships_UserId_GymId",
                table: "Memberships",
                columns: new[] { "UserId", "GymId" });

            migrationBuilder.CreateIndex(
                name: "IX_Messages_ConversationId",
                table: "Messages",
                column: "ConversationId");

            migrationBuilder.CreateIndex(
                name: "IX_Messages_SenderUserId",
                table: "Messages",
                column: "SenderUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_MembershipId",
                table: "Payments",
                column: "MembershipId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_TrainingSessionId",
                table: "Payments",
                column: "TrainingSessionId",
                unique: true,
                filter: "[TrainingSessionId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Preferences_UserId",
                table: "Preferences",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_QRCodes_MembershipId",
                table: "QRCodes",
                column: "MembershipId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_GymId",
                table: "Reviews",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_TrainerId",
                table: "Reviews",
                column: "TrainerId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UserId_TrainerId_GymId",
                table: "Reviews",
                columns: new[] { "UserId", "TrainerId", "GymId" },
                unique: true,
                filter: "[GymId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Trainers_UserId",
                table: "Trainers",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TrainerSchedules_GymId",
                table: "TrainerSchedules",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainerSchedules_TrainerId_StartUtc_EndUtc",
                table: "TrainerSchedules",
                columns: new[] { "TrainerId", "StartUtc", "EndUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_GymId",
                table: "TrainingSessions",
                column: "GymId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_TrainerId_StartUtc_EndUtc",
                table: "TrainingSessions",
                columns: new[] { "TrainerId", "StartUtc", "EndUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_TrainingSessions_UserId",
                table: "TrainingSessions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CentralAdministrators");

            migrationBuilder.DropTable(
                name: "CheckInLogs");

            migrationBuilder.DropTable(
                name: "ConversationParticipants");

            migrationBuilder.DropTable(
                name: "GymAdministrators");

            migrationBuilder.DropTable(
                name: "GymTrainers");

            migrationBuilder.DropTable(
                name: "MembershipRequests");

            migrationBuilder.DropTable(
                name: "Messages");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "Preferences");

            migrationBuilder.DropTable(
                name: "QRCodes");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "TrainerSchedules");

            migrationBuilder.DropTable(
                name: "Conversations");

            migrationBuilder.DropTable(
                name: "TrainingSessions");

            migrationBuilder.DropTable(
                name: "Memberships");

            migrationBuilder.DropTable(
                name: "Trainers");

            migrationBuilder.DropTable(
                name: "GymPlans");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Gyms");
        }
    }
}
