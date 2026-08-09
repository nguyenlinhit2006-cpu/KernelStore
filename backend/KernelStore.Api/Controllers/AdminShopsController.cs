using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Shops;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/admin/shops")]
[Authorize(Roles = "Admin")]
public class AdminShopsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly UserManager<ApplicationUser> _userManager;

    public AdminShopsController(ApplicationDbContext db, UserManager<ApplicationUser> userManager)
    {
        _db = db;
        _userManager = userManager;
    }

    [HttpGet]
    public async Task<IActionResult> List([FromQuery] string? status)
    {
        var query = _db.Shops.Include(s => s.Owner).AsQueryable();

        if (!string.IsNullOrWhiteSpace(status) && Enum.TryParse<ShopStatus>(status, true, out var parsed))
            query = query.Where(s => s.Status == parsed);

        var shops = await query.OrderByDescending(s => s.CreatedAt).ToListAsync();

        var dtos = shops.Select(s => new ShopDto(
            s.Id, s.Name, s.Slug, s.Description, s.LogoUrl,
            s.Status.ToString(), s.CreatedAt, s.OwnerId,
            s.Owner?.UserName ?? string.Empty)).ToList();

        return Ok(ApiResponse<List<ShopDto>>.Ok(dtos, "OK"));
    }

    [HttpPost("{id:guid}/approve")]
    public async Task<IActionResult> Approve(Guid id)
    {
        var shop = await _db.Shops
            .Include(s => s.Owner)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (shop == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy shop"));

        if (shop.Status == ShopStatus.Approved)
            return BadRequest(ApiResponse.Fail("Shop đã được duyệt rồi"));

        if (shop.Owner == null)
            return BadRequest(ApiResponse.Fail("Shop không có chủ sở hữu"));

        shop.Status = ShopStatus.Approved;
        await _db.SaveChangesAsync();

        shop.Owner.Role = UserRole.Seller;
        await _userManager.AddToRoleAsync(shop.Owner, UserRole.Seller.ToString());

        return Ok(ApiResponse<ShopDto>.Ok(ToDto(shop), "Đã duyệt shop. Người dùng trở thành Seller."));
    }

    [HttpPost("{id:guid}/reject")]
    public async Task<IActionResult> Reject(Guid id)
    {
        var shop = await _db.Shops
            .Include(s => s.Owner)
            .FirstOrDefaultAsync(s => s.Id == id);

        if (shop == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy shop"));

        if (shop.Status != ShopStatus.Pending)
            return BadRequest(ApiResponse.Fail("Chỉ shop đang chờ duyệt mới có thể từ chối"));

        shop.Status = ShopStatus.Rejected;
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<ShopDto>.Ok(ToDto(shop), "Đã từ chối shop"));
    }

    private static ShopDto ToDto(Shop shop) => new(
        shop.Id, shop.Name, shop.Slug, shop.Description, shop.LogoUrl,
        shop.Status.ToString(), shop.CreatedAt, shop.OwnerId,
        shop.Owner?.UserName ?? string.Empty);
}
