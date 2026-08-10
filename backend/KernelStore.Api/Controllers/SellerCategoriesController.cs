using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Categories;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

/// Category management scoped to the authenticated seller's own shop.
/// These categories (Category.OwnerShopId == shop.Id) are private to the shop
/// and can be assigned to that shop's products alongside the global ones.
[ApiController]
[Authorize(Roles = "Seller")]
[Route("api/seller/categories")]
public class SellerCategoriesController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public SellerCategoriesController(ApplicationDbContext db)
    {
        _db = db;
    }

    private async Task<Shop?> GetMyShopAsync()
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return null;
        return await _db.Shops.FirstOrDefaultAsync(s => s.OwnerId == userId);
    }

    private static CategoryDto ToDto(Category c, int productCount) =>
        new(c.Id, c.Name, c.Slug, c.Description, c.ParentId, productCount, null);

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var shop = await GetMyShopAsync();
        if (shop == null)
            return NotFound(ApiResponse.Fail("Bạn chưa có shop"));

        var cats = await _db.Categories
            .Where(c => c.OwnerShopId == shop.Id)
            .Include(c => c.Products)
            .OrderBy(c => c.Name)
            .ToListAsync();

        var dtos = cats.Select(c => ToDto(c, c.Products.Count)).ToList();
        return Ok(ApiResponse<List<CategoryDto>>.Ok(dtos, "OK"));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCategoryRequest request)
    {
        var shop = await GetMyShopAsync();
        if (shop == null)
            return NotFound(ApiResponse.Fail("Bạn chưa có shop"));

        if (await _db.Categories.AnyAsync(c => c.Slug == request.Slug))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        var category = new Category
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Slug = request.Slug,
            Description = request.Description,
            ParentId = null,           // shop categories are flat
            OwnerShopId = shop.Id
        };

        _db.Categories.Add(category);
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<CategoryDto>.Ok(ToDto(category, 0), "Đã tạo danh mục."));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCategoryRequest request)
    {
        var shop = await GetMyShopAsync();
        if (shop == null)
            return NotFound(ApiResponse.Fail("Bạn chưa có shop"));

        var category = await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);
        if (category == null || category.OwnerShopId != shop.Id)
            return NotFound(ApiResponse.Fail("Không tìm thấy danh mục của shop"));

        if (await _db.Categories.AnyAsync(c => c.Slug == request.Slug && c.Id != id))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        category.Name = request.Name;
        category.Slug = request.Slug;
        category.Description = request.Description;

        await _db.SaveChangesAsync();
        return Ok(ApiResponse<CategoryDto>.Ok(ToDto(category, 0), "Đã cập nhật danh mục."));
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var shop = await GetMyShopAsync();
        if (shop == null)
            return NotFound(ApiResponse.Fail("Bạn chưa có shop"));

        var category = await _db.Categories
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null || category.OwnerShopId != shop.Id)
            return NotFound(ApiResponse.Fail("Không tìm thấy danh mục của shop"));

        // Detach products from this category instead of blocking the delete.
        foreach (var p in category.Products)
            p.CategoryId = null;

        _db.Categories.Remove(category);
        await _db.SaveChangesAsync();

        return Ok(ApiResponse.Ok(null, "Đã xóa danh mục."));
    }
}
