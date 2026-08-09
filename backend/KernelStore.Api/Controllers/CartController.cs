using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Cart;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/cart")]
[Authorize]
public class CartController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public CartController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var dto = await BuildCartAsync(userId);
        return Ok(ApiResponse<CartDto>.Ok(dto, "OK"));
    }

    [HttpPost]
    public async Task<IActionResult> Add([FromBody] AddToCartRequest request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var product = await _db.Products
            .FirstOrDefaultAsync(p => p.Id == request.ProductId && p.IsActive);
        if (product == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy sản phẩm"));

        var item = await _db.CartItems
            .FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == product.Id);

        var newQuantity = (item?.Quantity ?? 0) + request.Quantity;
        if (newQuantity > product.StockQuantity)
            return BadRequest(ApiResponse.Fail(
                $"Số lượng vượt quá tồn kho (còn {product.StockQuantity})"));

        if (item == null)
        {
            item = new CartItem
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                ProductId = product.Id,
                Quantity = request.Quantity
            };
            _db.CartItems.Add(item);
        }
        else
        {
            item.Quantity = newQuantity;
        }

        await _db.SaveChangesAsync();

        var dto = await BuildCartAsync(userId);
        return Ok(ApiResponse<CartDto>.Ok(dto, "Đã thêm vào giỏ hàng"));
    }

    [HttpPut("{productId:guid}")]
    public async Task<IActionResult> Update(Guid productId, [FromBody] UpdateCartItemRequest request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var item = await _db.CartItems
            .FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == productId);
        if (item == null)
            return NotFound(ApiResponse.Fail("Sản phẩm không có trong giỏ hàng"));

        if (request.Quantity <= 0)
        {
            _db.CartItems.Remove(item);
            await _db.SaveChangesAsync();
            var removed = await BuildCartAsync(userId);
            return Ok(ApiResponse<CartDto>.Ok(removed, "Đã xóa khỏi giỏ hàng"));
        }

        var product = await _db.Products
            .FirstOrDefaultAsync(p => p.Id == productId && p.IsActive);
        if (product == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy sản phẩm"));

        if (request.Quantity > product.StockQuantity)
            return BadRequest(ApiResponse.Fail(
                $"Số lượng vượt quá tồn kho (còn {product.StockQuantity})"));

        item.Quantity = request.Quantity;
        await _db.SaveChangesAsync();

        var dto = await BuildCartAsync(userId);
        return Ok(ApiResponse<CartDto>.Ok(dto, "Đã cập nhật giỏ hàng"));
    }

    [HttpDelete("{productId:guid}")]
    public async Task<IActionResult> Delete(Guid productId)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var item = await _db.CartItems
            .FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == productId);
        if (item == null)
            return NotFound(ApiResponse.Fail("Sản phẩm không có trong giỏ hàng"));

        _db.CartItems.Remove(item);
        await _db.SaveChangesAsync();

        var dto = await BuildCartAsync(userId);
        return Ok(ApiResponse<CartDto>.Ok(dto, "Đã xóa khỏi giỏ hàng"));
    }

    private bool TryGetUserId(out Guid userId)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdClaim, out userId);
    }

    private async Task<CartDto> BuildCartAsync(Guid userId)
    {
        var items = await _db.CartItems
            .Where(c => c.UserId == userId)
            .Include(c => c.Product)
                .ThenInclude(p => p!.Images)
            .Include(c => c.Product)
                .ThenInclude(p => p!.Shop)
            .ToListAsync();

        var dtos = items
            .Where(c => c.Product != null)
            .OrderBy(c => c.Product!.Name)
            .Select(c =>
            {
                var product = c.Product!;
                var unitPrice = product.SalePrice ?? product.Price;
                var imageUrl = product.Images
                    .OrderByDescending(i => i.IsPrimary)
                    .ThenBy(i => i.DisplayOrder)
                    .Select(i => i.Url)
                    .FirstOrDefault();

                return new CartItemDto(
                    c.Id,
                    product.Id,
                    product.Name,
                    product.Slug,
                    product.Price,
                    product.SalePrice,
                    unitPrice,
                    c.Quantity,
                    product.StockQuantity,
                    unitPrice * c.Quantity,
                    imageUrl,
                    product.ShopId,
                    product.Shop?.Name);
            })
            .ToList();

        var totalItems = dtos.Sum(i => i.Quantity);
        var subtotal = dtos.Sum(i => i.LineTotal);

        return new CartDto(dtos, totalItems, subtotal);
    }
}
