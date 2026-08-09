using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Admin;
using KernelStore.Api.Contracts.Seller;
using KernelStore.Api.Data;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/seller")]
[Authorize(Roles = "Seller,Admin")]
public class SellerDashboardController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public SellerDashboardController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> Dashboard()
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var shop = await _db.Shops.FirstOrDefaultAsync(s => s.OwnerId == userId);
        if (shop == null)
            return NotFound(ApiResponse.Fail("Bạn chưa có shop"));

        var shopId = shop.Id;

        // Sản phẩm thuộc shop
        var totalProducts = await _db.Products.CountAsync(p => p.ShopId == shopId);
        var activeProducts = await _db.Products.CountAsync(p => p.ShopId == shopId && p.IsActive);

        // Các dòng đơn hàng chứa sản phẩm của shop
        var shopDetails = _db.OrderDetails.Where(d => d.Product!.ShopId == shopId);

        // Doanh thu chỉ tính đơn không bị hủy / không bị trả hàng
        var paidDetails = shopDetails.Where(d =>
            d.Order!.Status != OrderStatus.Cancelled &&
            d.Order.Status != OrderStatus.Returned);

        var totalRevenue = await paidDetails.SumAsync(d => (decimal?)d.TotalPrice) ?? 0m;
        var itemsSold = await paidDetails.SumAsync(d => (int?)d.Quantity) ?? 0;

        // Đơn hàng riêng biệt có chứa hàng của shop (kèm trạng thái)
        var orderStatuses = await shopDetails
            .Select(d => new { d.OrderId, d.Order!.Status })
            .Distinct()
            .ToListAsync();

        var totalOrders = orderStatuses.Count;
        var pendingOrders = orderStatuses.Count(o =>
            o.Status is OrderStatus.Pending or OrderStatus.Confirmed or OrderStatus.Processing);

        var ordersByStatus = Enum.GetValues<OrderStatus>()
            .Select(status => new OrderStatusCount(
                status.ToString(),
                orderStatuses.Count(o => o.Status == status)))
            .ToList();

        // Top 5 sản phẩm theo doanh thu (đơn không hủy).
        // Group theo ProductId (scalar) để EF dịch được sang SQL, rồi map tên sau.
        var topRaw = await paidDetails
            .GroupBy(d => d.ProductId)
            .Select(g => new
            {
                ProductId = g.Key,
                QuantitySold = g.Sum(x => x.Quantity),
                Revenue = g.Sum(x => x.TotalPrice)
            })
            .OrderByDescending(t => t.Revenue)
            .Take(5)
            .ToListAsync();

        var topIds = topRaw.Select(t => t.ProductId).ToList();
        var names = await _db.Products
            .Where(p => topIds.Contains(p.Id))
            .ToDictionaryAsync(p => p.Id, p => p.Name);

        var topProducts = topRaw
            .Select(t => new TopProductStat(
                t.ProductId,
                names.GetValueOrDefault(t.ProductId, string.Empty),
                t.QuantitySold,
                t.Revenue))
            .ToList();

        var dto = new SellerDashboardDto(
            totalRevenue, totalOrders, pendingOrders, itemsSold,
            totalProducts, activeProducts, ordersByStatus, topProducts);

        return Ok(ApiResponse<SellerDashboardDto>.Ok(dto, "OK"));
    }
}
