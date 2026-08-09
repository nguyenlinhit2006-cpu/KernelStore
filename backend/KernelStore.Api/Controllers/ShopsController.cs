using System.Security.Claims;
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
[Route("api/shops")]
public class ShopsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly UserManager<ApplicationUser> _userManager;

    public ShopsController(ApplicationDbContext db, UserManager<ApplicationUser> userManager)
    {
        _db = db;
        _userManager = userManager;
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> CreateShop([FromBody] CreateShopRequest request)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy người dùng"));

        var existing = await _db.Shops.AnyAsync(s => s.OwnerId == userId);
        if (existing)
            return BadRequest(ApiResponse.Fail("Bạn đã có shop rồi"));

        if (await _db.Shops.AnyAsync(s => s.Slug == request.Slug))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        var shop = new Shop
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Slug = request.Slug,
            Description = request.Description,
            LogoUrl = string.Empty,
            Status = ShopStatus.Pending,
            OwnerId = userId,
            CreatedAt = DateTime.UtcNow
        };

        _db.Shops.Add(shop);
        await _db.SaveChangesAsync();

        // Mở shop = trở thành seller: nâng role Customer → Seller.
        // (Token hiện tại vẫn mang role cũ; client cần refresh/đăng nhập lại để nhận role mới.)
        if (user.Role == UserRole.Customer)
        {
            user.Role = UserRole.Seller;
            await _userManager.UpdateAsync(user);

            if (!await _userManager.IsInRoleAsync(user, UserRole.Seller.ToString()))
                await _userManager.AddToRoleAsync(user, UserRole.Seller.ToString());
            if (await _userManager.IsInRoleAsync(user, UserRole.Customer.ToString()))
                await _userManager.RemoveFromRoleAsync(user, UserRole.Customer.ToString());
        }

        var dto = ToDto(shop, user.UserName ?? string.Empty);
        return Ok(ApiResponse<ShopDto>.Ok(dto, "Đã gửi yêu cầu mở shop. Chờ admin duyệt."));
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<IActionResult> GetMyShop()
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var shop = await _db.Shops
            .Include(s => s.Owner)
            .FirstOrDefaultAsync(s => s.OwnerId == userId);

        if (shop == null)
            return Ok(ApiResponse<ShopDto?>.Ok(null, "Chưa có shop"));

        var ownerName = shop.Owner?.UserName ?? string.Empty;
        return Ok(ApiResponse<ShopDto>.Ok(ToDto(shop, ownerName), "OK"));
    }

    [Authorize]
    [HttpPut("me")]
    public async Task<IActionResult> UpdateMyShop([FromBody] UpdateShopRequest request)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var shop = await _db.Shops
            .Include(s => s.Owner)
            .FirstOrDefaultAsync(s => s.OwnerId == userId);

        if (shop == null)
            return NotFound(ApiResponse.Fail("Bạn chưa có shop"));

        if (await _db.Shops.AnyAsync(s => s.Slug == request.Slug && s.Id != shop.Id))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        shop.Name = request.Name;
        shop.Slug = request.Slug;
        shop.Description = request.Description;

        await _db.SaveChangesAsync();

        var ownerName = shop.Owner?.UserName ?? string.Empty;
        return Ok(ApiResponse<ShopDto>.Ok(ToDto(shop, ownerName), "Đã cập nhật thông tin shop."));
    }

    private static ShopDto ToDto(Shop shop, string ownerName) => new(
        shop.Id, shop.Name, shop.Slug, shop.Description,
        shop.LogoUrl, shop.Status.ToString(), shop.CreatedAt,
        shop.OwnerId, ownerName);
}
