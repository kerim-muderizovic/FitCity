using System;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitCity.Infrastructure.Persistence.Migrations
{
    [DbContext(typeof(FitCityDbContext))]
    [Migration("20260123120000_AddMembershipRequestPaymentFlow")]
    /// <inheritdoc />
    public partial class AddMembershipRequestPaymentFlow : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ApprovedAtUtc",
                table: "MembershipRequests",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ApprovedByUserId",
                table: "MembershipRequests",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PaidAtUtc",
                table: "MembershipRequests",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "PaymentId",
                table: "MembershipRequests",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PaymentStatus",
                table: "MembershipRequests",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddCheckConstraint(
                name: "CK_MembershipRequest_PaymentStatus",
                table: "MembershipRequests",
                sql: "[PaymentStatus] IN (1,2)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_MembershipRequest_PaymentStatus",
                table: "MembershipRequests");

            migrationBuilder.DropColumn(
                name: "ApprovedAtUtc",
                table: "MembershipRequests");

            migrationBuilder.DropColumn(
                name: "ApprovedByUserId",
                table: "MembershipRequests");

            migrationBuilder.DropColumn(
                name: "PaidAtUtc",
                table: "MembershipRequests");

            migrationBuilder.DropColumn(
                name: "PaymentId",
                table: "MembershipRequests");

            migrationBuilder.DropColumn(
                name: "PaymentStatus",
                table: "MembershipRequests");
        }
    }
}
