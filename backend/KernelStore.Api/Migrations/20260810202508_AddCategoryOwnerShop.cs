using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KernelStore.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddCategoryOwnerShop : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "OwnerShopId",
                table: "Categories",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OwnerShopId",
                table: "Categories");
        }
    }
}
