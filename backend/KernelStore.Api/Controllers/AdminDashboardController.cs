using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Admin;
using KernelStore.Api.Data;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminDashboardController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public AdminDashboardController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> Dashboard()
    {
        var totalUsers = await _db.Users.CountAsync();
        var totalShops = await _db.Shops.CountAsync();
        var pendingShops = await _db.Shops.CountAsync(s => s.Status == ShopStatus.Pending);
        var approvedShops = await _db.Shops.CountAsync(s => s.Status == ShopStatus.Approved);
        var totalProducts = await _db.Products.CountAsync();
        var activeProducts = await _db.Products.CountAsync(p => p.IsActive);
        var totalOrders = await _db.Orders.CountAsync();

        // Doanh thu = tổng các đơn không bị hủy / không bị trả hàng
        var totalRevenue = await _db.Orders
            .Where(o => o.Status != OrderStatus.Cancelled && o.Status != OrderStatus.Returned)
            .SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;

        var grouped = await _db.Orders
            .GroupBy(o => o.Status)
            .Select(g => new { g.Key, Count = g.Count() })
            .ToListAsync();

        // Liệt kê đủ mọi trạng thái (kèm 0) theo thứ tự enum
        var ordersByStatus = Enum.GetValues<OrderStatus>()
            .Select(status => new OrderStatusCount(
                status.ToString(),
                grouped.FirstOrDefault(g => g.Key == status)?.Count ?? 0))
            .ToList();

        var dto = new AdminDashboardDto(
            totalUsers, totalShops, pendingShops, approvedShops,
            totalProducts, activeProducts, totalOrders, totalRevenue, ordersByStatus);

        return Ok(ApiResponse<AdminDashboardDto>.Ok(dto, "OK"));
    }
}
