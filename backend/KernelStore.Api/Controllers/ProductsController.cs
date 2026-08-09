using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Products;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/products")]
[Authorize]
public class ProductsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public ProductsController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> List(
        [FromQuery] string? category,
        [FromQuery] string? shop,
        [FromQuery] decimal? minPrice,
        [FromQuery] decimal? maxPrice,
        [FromQuery] string? search,
        [FromQuery] string? sort,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 12)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        var query = _db.Products
            .Include(p => p.Images)
            .Include(p => p.Category)
            .Include(p => p.Shop)
            .Where(p => p.IsActive)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(category))
        {
            var cat = await ResolveCategoryAsync(category);
            if (cat == null)
                return Ok(ApiResponse<PagedResult<ProductDto>>.Ok(
                    new PagedResult<ProductDto>(page, pageSize, 0, 0, new()), "OK"));
            var ids = await GetCategoryAndChildrenIdsAsync(cat.Id);
            query = query.Where(p => p.CategoryId != null && ids.Contains(p.CategoryId.Value));
        }

        if (!string.IsNullOrWhiteSpace(shop))
        {
            var shopEntity = await _db.Shops
                .FirstOrDefaultAsync(s => s.Slug == shop && s.Status == ShopStatus.Approved);
            if (shopEntity == null)
                return Ok(ApiResponse<PagedResult<ProductDto>>.Ok(
                    new PagedResult<ProductDto>(page, pageSize, 0, 0, new()), "OK"));
            query = query.Where(p => p.ShopId == shopEntity.Id);
        }

        if (minPrice.HasValue)
            query = query.Where(p => (p.SalePrice ?? p.Price) >= minPrice.Value);
        if (maxPrice.HasValue)
            query = query.Where(p => (p.SalePrice ?? p.Price) <= maxPrice.Value);
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(p =>
                p.Name.ToLower().Contains(term) ||
                p.Description.ToLower().Contains(term));
        }

        var total = await query.CountAsync();

        query = sort switch
        {
            "price_asc" => query.OrderBy(p => p.SalePrice ?? p.Price),
            "price_desc" => query.OrderByDescending(p => p.SalePrice ?? p.Price),
            "name" => query.OrderBy(p => p.Name),
            _ => query.OrderByDescending(p => p.CreatedAt)
        };

        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        var totalPages = (int)Math.Ceiling((double)total / pageSize);
        return Ok(ApiResponse<PagedResult<ProductDto>>.Ok(
            new PagedResult<ProductDto>(page, pageSize, total, totalPages, items.Select(ToDto).ToList()), "OK"));
    }

    [HttpGet("featured")]
    [AllowAnonymous]
    public async Task<IActionResult> Featured([FromQuery] int take = 8)
    {
        take = Math.Clamp(take, 1, 50);
        var items = await _db.Products
            .Include(p => p.Images)
            .Include(p => p.Category)
            .Include(p => p.Shop)
            .Where(p => p.IsActive)
            .OrderByDescending(p => p.CreatedAt)
            .Take(take)
            .ToListAsync();

        return Ok(ApiResponse<List<ProductDto>>.Ok(items.Select(ToDto).ToList(), "OK"));
    }

    [HttpGet("{slug}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetDetail(string slug)
    {
        Guid.TryParse(slug, out var slugId);
        var product = await _db.Products
            .Include(p => p.Images)
            .Include(p => p.Category)
            .Include(p => p.Shop)
            .FirstOrDefaultAsync(p =>
                p.IsActive &&
                (p.Slug == slug || p.Id == slugId));

        if (product == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy sản phẩm"));

        var reviews = await _db.Reviews
            .Include(r => r.User)
            .Where(r => r.ProductId == product.Id)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        var productCount = await _db.Products.CountAsync(p =>
            p.ShopId == product.ShopId && p.IsActive);

        var reviewDtos = reviews.Select(r => new ReviewDto(
            r.Id, r.Rating, r.Comment, r.CreatedAt, r.UserId,
            r.User?.FullName ?? string.Empty)).ToList();

        var average = reviewDtos.Count > 0
            ? Math.Round(reviewDtos.Average(r => r.Rating), 2)
            : 0.0;

        var shopSummary = new ShopSummaryDto(
            product.Shop?.Id ?? product.ShopId,
            product.Shop?.Name ?? string.Empty,
            product.Shop?.Slug ?? string.Empty,
            product.Shop?.Description ?? string.Empty,
            product.Shop?.LogoUrl ?? string.Empty,
            productCount);

        var dto = new ProductDetailDto(
            product.Id, product.Name, product.Slug, product.Description,
            product.Price, product.SalePrice, product.StockQuantity,
            product.Sku, product.CreatedAt, product.ShopId, product.Shop?.Name,
            product.CategoryId, product.Category?.Name,
            product.Images.OrderBy(i => i.DisplayOrder)
                .Select(i => new ProductImageDto(
                    i.Id, i.Url, i.AltText, i.IsPrimary, i.DisplayOrder)).ToList(),
            reviewDtos, shopSummary, average, reviewDtos.Count);

        return Ok(ApiResponse<ProductDetailDto>.Ok(dto, "OK"));
    }

    private async Task<Category?> ResolveCategoryAsync(string category)
    {
        if (Guid.TryParse(category, out var id))
            return await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);
        return await _db.Categories.FirstOrDefaultAsync(c => c.Slug == category);
    }

    private async Task<HashSet<Guid>> GetCategoryAndChildrenIdsAsync(Guid id)
    {
        var ids = new HashSet<Guid> { id };
        var queue = new Queue<Guid>();
        queue.Enqueue(id);

        while (queue.Count > 0)
        {
            var current = queue.Dequeue();
            var children = await _db.Categories
                .Where(c => c.ParentId == current)
                .Select(c => c.Id)
                .ToListAsync();
            foreach (var child in children)
            {
                if (ids.Add(child))
                    queue.Enqueue(child);
            }
        }

        return ids;
    }

    private async Task<(Guid shopId, bool ok)> GetOwnShopIdAsync(bool requireApproved = true)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return (Guid.Empty, false);

        var shop = await _db.Shops.FirstOrDefaultAsync(s => s.OwnerId == userId);
        if (shop == null)
            return (Guid.Empty, false);

        if (requireApproved && shop.Status != ShopStatus.Approved)
            return (Guid.Empty, false);

        return (shop.Id, true);
    }

    private async Task<(Product? product, IActionResult? error)> GetOwnProductAsync(Guid id)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return (null, Unauthorized(ApiResponse.Fail("Không xác định được người dùng")));

        var shop = await _db.Shops.FirstOrDefaultAsync(s => s.OwnerId == userId);
        if (shop == null)
            return (null, BadRequest(ApiResponse.Fail("Bạn chưa có shop")));

        if (shop.Status != ShopStatus.Approved)
            return (null, BadRequest(ApiResponse.Fail("Bạn chưa có shop hoặc shop chưa được duyệt")));

        var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == id && p.ShopId == shop.Id);
        if (product == null)
            return (null, NotFound(ApiResponse.Fail("Không tìm thấy sản phẩm")));

        return (product, null);
    }

    [HttpPost]
    [Authorize(Roles = "Seller")]
    public async Task<IActionResult> Create([FromBody] CreateProductRequest request)
    {
        var (shopId, ok) = await GetOwnShopIdAsync();
        if (!ok)
            return BadRequest(ApiResponse.Fail("Bạn chưa có shop hoặc shop chưa được duyệt"));

        if (await _db.Products.AnyAsync(p => p.Slug == request.Slug))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        if (request.CategoryId is Guid cid && !await _db.Categories.AnyAsync(c => c.Id == cid))
            return BadRequest(ApiResponse.Fail("Danh mục không tồn tại"));

        var product = new Product
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Slug = request.Slug,
            Description = request.Description,
            Price = request.Price,
            SalePrice = request.SalePrice,
            StockQuantity = request.StockQuantity,
            Sku = request.Sku,
            CategoryId = request.CategoryId,
            ShopId = shopId,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        ApplyImages(product, request.Images);

        _db.Products.Add(product);
        await _db.SaveChangesAsync();

        var dto = await ToDtoAsync(product);
        return Ok(ApiResponse<ProductDto>.Ok(dto, "Đã thêm sản phẩm"));
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy()
    {
        var (shopId, ok) = await GetOwnShopIdAsync(requireApproved: false);
        if (!ok)
            return Ok(ApiResponse<List<ProductDto>>.Ok(new List<ProductDto>(), "Chưa có shop"));

        var products = await _db.Products
            .Include(p => p.Images)
            .Include(p => p.Category)
            .Where(p => p.ShopId == shopId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        return Ok(ApiResponse<List<ProductDto>>.Ok(
            products.Select(ToDto).ToList(), "OK"));
    }

    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Seller")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateProductRequest request)
    {
        var (product, error) = await GetOwnProductAsync(id);
        if (error != null)
            return error;

        if (product!.Slug != request.Slug &&
            await _db.Products.AnyAsync(p => p.Slug == request.Slug))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        if (request.CategoryId is Guid cid && !await _db.Categories.AnyAsync(c => c.Id == cid))
            return BadRequest(ApiResponse.Fail("Danh mục không tồn tại"));

        product.Name = request.Name;
        product.Slug = request.Slug;
        product.Description = request.Description;
        product.Price = request.Price;
        product.SalePrice = request.SalePrice;
        product.StockQuantity = request.StockQuantity;
        product.Sku = request.Sku;
        product.CategoryId = request.CategoryId;
        product.IsActive = request.IsActive;

        await _db.SaveChangesAsync();

        var oldImages = await _db.ProductImages.Where(i => i.ProductId == product.Id).ToListAsync();
        if (oldImages.Count > 0 || request.Images.Count > 0)
        {
            _db.ProductImages.RemoveRange(oldImages);

            var cleaned = request.Images
                .Select(u => u.Trim())
                .Where(u => u.Length > 0)
                .Take(10)
                .ToList();

            for (var i = 0; i < cleaned.Count; i++)
            {
                _db.ProductImages.Add(new ProductImage
                {
                    Id = Guid.NewGuid(),
                    ProductId = product.Id,
                    Url = cleaned[i],
                    AltText = product.Name,
                    IsPrimary = i == 0,
                    DisplayOrder = i
                });
            }

            await _db.SaveChangesAsync();
        }

        var dto = await ToDtoAsync(product);
        return Ok(ApiResponse<ProductDto>.Ok(dto, "Đã cập nhật sản phẩm"));
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Seller")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var (product, error) = await GetOwnProductAsync(id);
        if (error != null)
            return error;

        _db.Products.Remove(product!);
        await _db.SaveChangesAsync();
        return Ok(ApiResponse.Ok(null, "Đã xóa sản phẩm"));
    }

    private static void ApplyImages(Product product, List<string> urls)
    {
        var cleaned = urls
            .Select(u => u.Trim())
            .Where(u => u.Length > 0)
            .Take(10)
            .ToList();

        for (var i = 0; i < cleaned.Count; i++)
        {
            product.Images.Add(new ProductImage
            {
                Id = Guid.NewGuid(),
                Url = cleaned[i],
                AltText = product.Name,
                IsPrimary = i == 0,
                DisplayOrder = i
            });
        }
    }

    private async Task<ProductDto> ToDtoAsync(Product p)
    {
        var categoryName = p.Category?.Name;
        if (categoryName == null && p.CategoryId is Guid cid)
            categoryName = await _db.Categories
                .Where(c => c.Id == cid)
                .Select(c => c.Name)
                .FirstOrDefaultAsync();

        var shopName = p.Shop?.Name;
        if (shopName == null)
            shopName = await _db.Shops
                .Where(s => s.Id == p.ShopId)
                .Select(s => s.Name)
                .FirstOrDefaultAsync();

        var images = await _db.ProductImages
            .Where(i => i.ProductId == p.Id)
            .OrderBy(i => i.DisplayOrder)
            .ToListAsync();

        return new ProductDto(
            p.Id, p.Name, p.Slug, p.Description, p.Price, p.SalePrice,
            p.StockQuantity, p.Sku, p.IsActive, p.CreatedAt, p.ShopId, shopName,
            p.CategoryId, categoryName, images.Select(i => new ProductImageDto(
                i.Id, i.Url, i.AltText, i.IsPrimary, i.DisplayOrder)).ToList());
    }

    private static ProductDto ToDto(Product p) => new(
        p.Id, p.Name, p.Slug, p.Description, p.Price, p.SalePrice,
        p.StockQuantity, p.Sku, p.IsActive, p.CreatedAt, p.ShopId, p.Shop?.Name,
        p.CategoryId, p.Category?.Name,
        p.Images.OrderBy(i => i.DisplayOrder)
            .Select(i => new ProductImageDto(
                i.Id, i.Url, i.AltText, i.IsPrimary, i.DisplayOrder)).ToList());
}
