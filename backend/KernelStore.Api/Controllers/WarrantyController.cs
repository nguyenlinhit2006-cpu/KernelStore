using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Warranty;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/warranty")]
[Authorize]
public class WarrantyController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public WarrantyController(ApplicationDbContext db)
    {
        _db = db;
    }

    // Khách gửi yêu cầu bảo hành cho một dòng sản phẩm đã nhận.
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWarrantyClaimRequest request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var detail = await _db.OrderDetails
            .Include(d => d.Order)
            .Include(d => d.Product)
            .FirstOrDefaultAsync(d => d.Id == request.OrderDetailId);

        if (detail == null || detail.Order == null || detail.Product == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy sản phẩm trong đơn hàng"));

        if (detail.Order.UserId != userId)
            return StatusCode(StatusCodes.Status403Forbidden,
                ApiResponse.Fail("Bạn không có quyền bảo hành sản phẩm này"));

        if (detail.Order.Status != OrderStatus.Delivered)
            return BadRequest(ApiResponse.Fail(
                "Chỉ bảo hành khi đơn đã nhận hàng (Delivered)"));

        if (detail.Product.WarrantyMonths <= 0)
            return BadRequest(ApiResponse.Fail("Sản phẩm này không có chính sách bảo hành"));

        var deliveredAt = detail.Order.PaidAt ?? detail.Order.CreatedAt;
        var expiresAt = deliveredAt.AddMonths(detail.Product.WarrantyMonths);
        if (DateTime.UtcNow > expiresAt)
            return BadRequest(ApiResponse.Fail(
                $"Sản phẩm đã hết hạn bảo hành ({expiresAt:dd/MM/yyyy})"));

        // Không cho tạo trùng khi đang có yêu cầu chưa kết thúc cho cùng dòng hàng.
        var hasOpen = await _db.WarrantyClaims.AnyAsync(w =>
            w.OrderDetailId == detail.Id &&
            (w.Status == WarrantyStatus.Pending
             || w.Status == WarrantyStatus.Approved
             || w.Status == WarrantyStatus.Processing));
        if (hasOpen)
            return BadRequest(ApiResponse.Fail(
                "Đã có một yêu cầu bảo hành đang xử lý cho sản phẩm này"));

        var claim = new WarrantyClaim
        {
            Id = Guid.NewGuid(),
            ClaimCode = await GenerateClaimCodeAsync(),
            Description = request.Description.Trim(),
            ImageUrl = request.ImageUrl.Trim(),
            Status = WarrantyStatus.Pending,
            Resolution = WarrantyResolution.None,
            CreatedAt = DateTime.UtcNow,
            OrderDetailId = detail.Id,
            UserId = userId,
            ProductId = detail.ProductId,
            ShopId = detail.Product.ShopId
        };

        _db.WarrantyClaims.Add(claim);
        await _db.SaveChangesAsync();

        var dto = await LoadDtoAsync(claim.Id, canManage: false);
        return Ok(ApiResponse<WarrantyClaimDto>.Ok(dto!, "Đã gửi yêu cầu bảo hành"));
    }

    // Danh sách yêu cầu bảo hành của chính khách hàng.
    [HttpGet("mine")]
    public async Task<IActionResult> Mine()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var claims = await BaseQuery()
            .Where(w => w.UserId == userId)
            .OrderByDescending(w => w.CreatedAt)
            .ToListAsync();

        var dtos = claims.Select(w => BuildDto(w, canManage: false)).ToList();
        return Ok(ApiResponse<List<WarrantyClaimDto>>.Ok(dtos, "OK"));
    }

    // Danh sách yêu cầu bảo hành gửi tới shop (seller) / toàn hệ thống (admin).
    // Lọc theo trạng thái nếu truyền `status`.
    [HttpGet("shop")]
    [Authorize(Roles = "Seller,Admin")]
    public async Task<IActionResult> ForShop([FromQuery] string? status)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var isAdmin = User.IsInRole("Admin");
        var query = BaseQuery();

        if (!isAdmin)
        {
            var shopId = await GetSellerShopIdAsync(userId);
            if (shopId is not Guid sid)
                return NotFound(ApiResponse.Fail("Bạn chưa có shop"));
            query = query.Where(w => w.ShopId == sid);
        }

        if (!string.IsNullOrWhiteSpace(status)
            && Enum.TryParse<WarrantyStatus>(status, ignoreCase: true, out var st)
            && Enum.IsDefined(st))
        {
            query = query.Where(w => w.Status == st);
        }

        var claims = await query
            .OrderByDescending(w => w.CreatedAt)
            .ToListAsync();

        var dtos = claims.Select(w => BuildDto(w, canManage: true)).ToList();
        return Ok(ApiResponse<List<WarrantyClaimDto>>.Ok(dtos, "OK"));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var claim = await BaseQuery().FirstOrDefaultAsync(w => w.Id == id);
        if (claim == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy yêu cầu bảo hành"));

        var isAdmin = User.IsInRole("Admin");
        var shopId = await GetSellerShopIdAsync(userId);
        var isOwnerSeller = shopId is Guid sid && claim.ShopId == sid;

        if (claim.UserId != userId && !isAdmin && !isOwnerSeller)
            return StatusCode(StatusCodes.Status403Forbidden,
                ApiResponse.Fail("Bạn không có quyền xem yêu cầu này"));

        var dto = BuildDto(claim, canManage: isAdmin || isOwnerSeller);
        return Ok(ApiResponse<WarrantyClaimDto>.Ok(dto, "OK"));
    }

    // Khách tự hủy yêu cầu khi còn ở trạng thái Pending.
    [HttpPost("{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var claim = await BaseQuery().FirstOrDefaultAsync(w => w.Id == id);
        if (claim == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy yêu cầu bảo hành"));

        if (claim.UserId != userId)
            return StatusCode(StatusCodes.Status403Forbidden,
                ApiResponse.Fail("Bạn không có quyền hủy yêu cầu này"));

        if (claim.Status != WarrantyStatus.Pending)
            return BadRequest(ApiResponse.Fail("Chỉ hủy được khi yêu cầu đang chờ xử lý"));

        claim.Status = WarrantyStatus.Cancelled;
        claim.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<WarrantyClaimDto>.Ok(
            BuildDto(claim, canManage: false), "Đã hủy yêu cầu bảo hành"));
    }

    // Shop/Admin chấp nhận bảo hành và chọn hình thức xử lý (Pending → Approved).
    [HttpPost("{id:guid}/approve")]
    [Authorize(Roles = "Seller,Admin")]
    public async Task<IActionResult> Approve(Guid id, [FromBody] ApproveWarrantyRequest request)
    {
        if (!Enum.TryParse<WarrantyResolution>(request.Resolution, ignoreCase: true, out var resolution)
            || resolution == WarrantyResolution.None)
            return BadRequest(ApiResponse.Fail("Hình thức xử lý không hợp lệ (Repair/Replace/Refund)"));

        var (claim, error) = await LoadForManageAsync(id);
        if (error != null) return error;

        if (claim!.Status != WarrantyStatus.Pending)
            return BadRequest(ApiResponse.Fail("Chỉ duyệt được yêu cầu đang chờ xử lý"));

        claim.Status = WarrantyStatus.Approved;
        claim.Resolution = resolution;
        claim.ResolutionNote = request.Note.Trim();
        claim.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<WarrantyClaimDto>.Ok(
            BuildDto(claim, canManage: true), "Đã chấp nhận bảo hành"));
    }

    // Shop/Admin từ chối bảo hành (Pending → Rejected).
    [HttpPost("{id:guid}/reject")]
    [Authorize(Roles = "Seller,Admin")]
    public async Task<IActionResult> Reject(Guid id, [FromBody] WarrantyNoteRequest request)
    {
        var (claim, error) = await LoadForManageAsync(id);
        if (error != null) return error;

        if (claim!.Status != WarrantyStatus.Pending)
            return BadRequest(ApiResponse.Fail("Chỉ từ chối được yêu cầu đang chờ xử lý"));

        claim.Status = WarrantyStatus.Rejected;
        claim.Resolution = WarrantyResolution.None;
        claim.ResolutionNote = request.Note.Trim();
        claim.UpdatedAt = DateTime.UtcNow;
        claim.ResolvedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<WarrantyClaimDto>.Ok(
            BuildDto(claim, canManage: true), "Đã từ chối yêu cầu bảo hành"));
    }

    // Shop/Admin bắt đầu xử lý (Approved → Processing).
    [HttpPost("{id:guid}/process")]
    [Authorize(Roles = "Seller,Admin")]
    public async Task<IActionResult> Process(Guid id)
    {
        var (claim, error) = await LoadForManageAsync(id);
        if (error != null) return error;

        if (claim!.Status != WarrantyStatus.Approved)
            return BadRequest(ApiResponse.Fail("Chỉ chuyển xử lý khi yêu cầu đã được chấp nhận"));

        claim.Status = WarrantyStatus.Processing;
        claim.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<WarrantyClaimDto>.Ok(
            BuildDto(claim, canManage: true), "Đã bắt đầu xử lý bảo hành"));
    }

    // Shop/Admin hoàn tất bảo hành (Approved/Processing → Completed).
    [HttpPost("{id:guid}/complete")]
    [Authorize(Roles = "Seller,Admin")]
    public async Task<IActionResult> Complete(Guid id, [FromBody] WarrantyNoteRequest request)
    {
        var (claim, error) = await LoadForManageAsync(id);
        if (error != null) return error;

        if (claim!.Status is not (WarrantyStatus.Approved or WarrantyStatus.Processing))
            return BadRequest(ApiResponse.Fail("Chỉ hoàn tất khi yêu cầu đã được chấp nhận"));

        claim.Status = WarrantyStatus.Completed;
        if (!string.IsNullOrWhiteSpace(request.Note))
            claim.ResolutionNote = request.Note.Trim();
        claim.UpdatedAt = DateTime.UtcNow;
        claim.ResolvedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<WarrantyClaimDto>.Ok(
            BuildDto(claim, canManage: true), "Đã hoàn tất bảo hành"));
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    private IQueryable<WarrantyClaim> BaseQuery() => _db.WarrantyClaims
        .Include(w => w.User)
        .Include(w => w.Shop)
        .Include(w => w.Product)!
            .ThenInclude(p => p!.Images)
        .Include(w => w.OrderDetail)!
            .ThenInclude(d => d!.Order)
        .AsQueryable();

    // Nạp claim + kiểm tra quyền quản lý (seller sở hữu shop hoặc admin).
    private async Task<(WarrantyClaim? claim, IActionResult? error)> LoadForManageAsync(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return (null, Unauthorized(ApiResponse.Fail("Không xác định được người dùng")));

        var claim = await BaseQuery().FirstOrDefaultAsync(w => w.Id == id);
        if (claim == null)
            return (null, NotFound(ApiResponse.Fail("Không tìm thấy yêu cầu bảo hành")));

        if (User.IsInRole("Admin"))
            return (claim, null);

        var shopId = await GetSellerShopIdAsync(userId);
        if (shopId is Guid sid && claim.ShopId == sid)
            return (claim, null);

        return (null, StatusCode(StatusCodes.Status403Forbidden,
            ApiResponse.Fail("Bạn không có quyền xử lý yêu cầu này")));
    }

    private async Task<Guid?> GetSellerShopIdAsync(Guid userId)
    {
        if (!User.IsInRole("Seller"))
            return null;
        var shop = await _db.Shops.FirstOrDefaultAsync(s => s.OwnerId == userId);
        return shop?.Id;
    }

    private async Task<WarrantyClaimDto?> LoadDtoAsync(Guid id, bool canManage)
    {
        var claim = await BaseQuery().FirstOrDefaultAsync(w => w.Id == id);
        return claim == null ? null : BuildDto(claim, canManage);
    }

    private static WarrantyClaimDto BuildDto(WarrantyClaim w, bool canManage)
    {
        var order = w.OrderDetail?.Order;
        var product = w.Product;

        var imageUrl = product?.Images
            .OrderByDescending(i => i.IsPrimary)
            .ThenBy(i => i.DisplayOrder)
            .Select(i => i.Url)
            .FirstOrDefault();

        int warrantyMonths = product?.WarrantyMonths ?? 0;
        DateTime? expiresAt = null;
        if (order != null && warrantyMonths > 0)
        {
            var deliveredAt = order.PaidAt ?? order.CreatedAt;
            expiresAt = deliveredAt.AddMonths(warrantyMonths);
        }

        return new WarrantyClaimDto(
            w.Id,
            w.ClaimCode,
            w.Status.ToString(),
            w.Resolution.ToString(),
            w.ResolutionNote,
            w.Description,
            string.IsNullOrEmpty(w.ImageUrl) ? null : w.ImageUrl,
            w.CreatedAt,
            w.UpdatedAt,
            w.ResolvedAt,
            w.OrderDetailId,
            order?.Id ?? Guid.Empty,
            order?.OrderCode ?? string.Empty,
            w.ProductId,
            product?.Name ?? string.Empty,
            product?.Slug ?? string.Empty,
            imageUrl,
            w.OrderDetail?.Quantity ?? 0,
            warrantyMonths,
            expiresAt,
            w.ShopId,
            w.Shop?.Name,
            w.UserId,
            w.User?.FullName ?? string.Empty,
            canManage);
    }

    private bool TryGetUserId(out Guid userId)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdClaim, out userId);
    }

    private async Task<string> GenerateClaimCodeAsync()
    {
        var datePart = DateTime.UtcNow.ToString("yyyyMMdd");
        for (var attempt = 0; attempt < 10; attempt++)
        {
            var suffix = Random.Shared.Next(0, 10000).ToString("D4");
            var code = $"WR-{datePart}-{suffix}";
            if (!await _db.WarrantyClaims.AnyAsync(w => w.ClaimCode == code))
                return code;
        }
        return $"WR-{datePart}-{Guid.NewGuid():N}"[..21];
    }
}
