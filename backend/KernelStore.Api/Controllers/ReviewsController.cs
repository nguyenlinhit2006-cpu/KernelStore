using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Products;
using KernelStore.Api.Contracts.Reviews;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/reviews")]
[Authorize]
public class ReviewsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public ReviewsController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetByProduct([FromQuery] Guid productId)
    {
        if (productId == Guid.Empty)
            return BadRequest(ApiResponse.Fail("Thiếu productId"));

        var reviews = await _db.Reviews
            .Include(r => r.User)
            .Where(r => r.ProductId == productId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        var dtos = reviews.Select(r => new ReviewDto(
            r.Id, r.Rating, r.Comment, r.CreatedAt, r.UserId,
            r.User?.FullName ?? string.Empty)).ToList();

        var average = dtos.Count > 0 ? Math.Round(dtos.Average(r => r.Rating), 2) : 0.0;

        var result = new ProductReviewsDto(dtos, average, dtos.Count);
        return Ok(ApiResponse<ProductReviewsDto>.Ok(result, "OK"));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateReviewRequest request)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == request.ProductId);
        if (product == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy sản phẩm"));

        // Chỉ cho đánh giá khi đã mua (có đơn không bị hủy chứa sản phẩm này)
        var purchased = await _db.OrderDetails.AnyAsync(d =>
            d.ProductId == request.ProductId &&
            d.Order!.UserId == userId &&
            d.Order.Status != OrderStatus.Cancelled);
        if (!purchased)
            return StatusCode(StatusCodes.Status403Forbidden,
                ApiResponse.Fail("Bạn cần mua sản phẩm này trước khi đánh giá"));

        // Mỗi user chỉ đánh giá 1 lần cho mỗi sản phẩm
        if (await _db.Reviews.AnyAsync(r => r.ProductId == request.ProductId && r.UserId == userId))
            return BadRequest(ApiResponse.Fail("Bạn đã đánh giá sản phẩm này"));

        var review = new Review
        {
            Id = Guid.NewGuid(),
            ProductId = request.ProductId,
            UserId = userId,
            Rating = request.Rating,
            Comment = request.Comment.Trim(),
            CreatedAt = DateTime.UtcNow
        };

        _db.Reviews.Add(review);
        await _db.SaveChangesAsync();

        var userName = await _db.Users
            .Where(u => u.Id == userId)
            .Select(u => u.FullName)
            .FirstOrDefaultAsync() ?? string.Empty;

        var dto = new ReviewDto(review.Id, review.Rating, review.Comment, review.CreatedAt, userId, userName);
        return Ok(ApiResponse<ReviewDto>.Ok(dto, "Đã gửi đánh giá"));
    }
}
