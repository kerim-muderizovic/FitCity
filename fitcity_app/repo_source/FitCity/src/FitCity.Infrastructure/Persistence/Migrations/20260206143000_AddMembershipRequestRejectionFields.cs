using System;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    [DbContext(typeof(FitCityDbContext))]
    [Migration("20260206143000_AddMembershipRequestRejectionFields")]
    public partial class AddMembershipRequestRejectionFields : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "RejectedAtUtc",
                table: "MembershipRequests",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "RejectedByUserId",
                table: "MembershipRequests",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RejectionReason",
                table: "MembershipRequests",
                type: "nvarchar(400)",
                maxLength: 400,
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RejectedAtUtc",
                table: "MembershipRequests");

            migrationBuilder.DropColumn(
                name: "RejectedByUserId",
                table: "MembershipRequests");

            migrationBuilder.DropColumn(
                name: "RejectionReason",
                table: "MembershipRequests");
        }
    }
}
