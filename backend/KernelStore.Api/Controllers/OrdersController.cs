using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Orders;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/orders")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public OrdersController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateOrderRequest request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var cartItems = await _db.CartItems
            .Where(c => c.UserId == userId)
            .Include(c => c.Product)
                .ThenInclude(p => p!.Images)
            .Include(c => c.Product)
                .ThenInclude(p => p!.Shop)
            .ToListAsync();

        if (cartItems.Count == 0)
            return BadRequest(ApiResponse.Fail("Giỏ hàng trống"));

        // Validate availability + stock trước khi tạo đơn
        var errors = new List<string>();
        foreach (var item in cartItems)
        {
            var product = item.Product;
            if (product == null || !product.IsActive)
            {
                errors.Add($"Sản phẩm không còn khả dụng");
                continue;
            }
            if (item.Quantity > product.StockQuantity)
                errors.Add($"'{product.Name}' chỉ còn {product.StockQuantity} trong kho");
        }

        if (errors.Count > 0)
            return BadRequest(ApiResponse.Fail("Không thể đặt hàng", errors.ToArray()));

        await using var transaction = await _db.Database.BeginTransactionAsync();

        var address = new Address
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            FullName = request.FullName.Trim(),
            Phone = request.Phone.Trim(),
            Street = request.Street.Trim(),
            Ward = request.Ward.Trim(),
            District = request.District.Trim(),
            City = request.City.Trim(),
            IsDefault = false
        };
        _db.Addresses.Add(address);

        var order = new Order
        {
            Id = Guid.NewGuid(),
            OrderCode = await GenerateOrderCodeAsync(),
            Status = OrderStatus.Pending,
            ShippingFee = 0m,
            Note = request.Note.Trim(),
            CreatedAt = DateTime.UtcNow,
            UserId = userId,
            AddressId = address.Id
        };

        decimal total = 0m;
        foreach (var item in cartItems)
        {
            var product = item.Product!;
            var unitPrice = product.SalePrice ?? product.Price;
            var lineTotal = unitPrice * item.Quantity;
            total += lineTotal;

            order.OrderDetails.Add(new OrderDetail
            {
                Id = Guid.NewGuid(),
                OrderId = order.Id,
                ProductId = product.Id,
                Quantity = item.Quantity,
                UnitPrice = unitPrice,
                TotalPrice = lineTotal
            });

            product.StockQuantity -= item.Quantity;
        }

        order.TotalAmount = total + order.ShippingFee;

        _db.Orders.Add(order);
        _db.CartItems.RemoveRange(cartItems);

        await _db.SaveChangesAsync();
        await transaction.CommitAsync();

        var dto = BuildDto(order, address, cartItems);
        return Ok(ApiResponse<OrderDto>.Ok(dto, "Đặt hàng thành công"));
    }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var isAdmin = User.IsInRole("Admin");
        var shopId = await GetSellerShopIdAsync(userId, isAdmin);

        var query = BaseQuery();

        if (isAdmin)
        {
            // Admin xem tất cả
        }
        else if (shopId is Guid sid)
        {
            // Seller thấy cả đơn mình đặt (người mua) lẫn đơn bán của shop mình.
            query = query.Where(o => o.UserId == userId
                || o.OrderDetails.Any(d => d.Product!.ShopId == sid));
        }
        else
        {
            query = query.Where(o => o.UserId == userId);
        }

        var orders = await query
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();

        // Đơn do chính user đặt → xem đầy đủ; đơn bán của shop → chỉ phần hàng của shop.
        var dtos = orders
            .Select(o => BuildDtoFromLoaded(o, o.UserId == userId ? null : shopId))
            .ToList();
        return Ok(ApiResponse<List<OrderDto>>.Ok(dtos, "OK"));
    }

    // Danh sách đơn BÁN của shop (seller): chỉ đơn chứa sản phẩm của shop mình,
    // hiển thị phần hàng thuộc shop. Lọc theo trạng thái nếu có.
    [HttpGet("sales")]
    [Authorize(Roles = "Seller,Admin")]
    public async Task<IActionResult> Sales([FromQuery] string? status)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var shop = await _db.Shops.FirstOrDefaultAsync(s => s.OwnerId == userId);
        if (shop == null)
            return NotFound(ApiResponse.Fail("Bạn chưa có shop"));

        var sid = shop.Id;
        var query = BaseQuery().Where(o => o.OrderDetails.Any(d => d.Product!.ShopId == sid));

        if (!string.IsNullOrWhiteSpace(status)
            && Enum.TryParse<OrderStatus>(status, ignoreCase: true, out var st)
            && Enum.IsDefined(st))
        {
            query = query.Where(o => o.Status == st);
        }

        var orders = await query
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync();

        var dtos = orders.Select(o => BuildDtoFromLoaded(o, sid)).ToList();
        return Ok(ApiResponse<List<OrderDto>>.Ok(dtos, "OK"));
    }

    // Khách xác nhận đã nhận hàng: Shipped → Delivered. Chỉ chủ đơn thực hiện.
    [HttpPost("{id:guid}/confirm-received")]
    public async Task<IActionResult> ConfirmReceived(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var order = await BaseQuery().FirstOrDefaultAsync(o => o.Id == id);
        if (order == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy đơn hàng"));

        if (order.UserId != userId)
            return StatusCode(StatusCodes.Status403Forbidden,
                ApiResponse.Fail("Bạn không có quyền xác nhận đơn hàng này"));

        if (order.Status == OrderStatus.Delivered)
            return BadRequest(ApiResponse.Fail("Đơn đã được xác nhận nhận hàng"));
        if (order.Status != OrderStatus.Shipped)
            return BadRequest(ApiResponse.Fail("Chỉ xác nhận được khi đơn đã giao (Shipped)"));

        order.Status = OrderStatus.Delivered;
        order.PaidAt ??= DateTime.UtcNow;
        await _db.SaveChangesAsync();

        var dto = BuildDtoFromLoaded(order, null);
        return Ok(ApiResponse<OrderDto>.Ok(dto, "Đã xác nhận nhận hàng"));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var order = await BaseQuery().FirstOrDefaultAsync(o => o.Id == id);
        if (order == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy đơn hàng"));

        var isAdmin = User.IsInRole("Admin");
        var shopId = await GetSellerShopIdAsync(userId, isAdmin);

        Guid? shopFilter = null;
        if (isAdmin)
        {
            // full view
        }
        else if (order.UserId == userId)
        {
            // buyer: full view
        }
        else if (shopId is Guid sid && order.OrderDetails.Any(d => d.Product!.ShopId == sid))
        {
            shopFilter = sid; // seller: chỉ xem phần thuộc shop của mình
        }
        else
        {
            return StatusCode(StatusCodes.Status403Forbidden,
                ApiResponse.Fail("Bạn không có quyền xem đơn hàng này"));
        }

        var dto = BuildDtoFromLoaded(order, shopFilter);
        return Ok(ApiResponse<OrderDto>.Ok(dto, "OK"));
    }

    [HttpPut("{id:guid}/status")]
    [Authorize(Roles = "Seller,Admin")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateOrderStatusRequest request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        if (!Enum.TryParse<OrderStatus>(request.Status, ignoreCase: true, out var newStatus)
            || !Enum.IsDefined(newStatus))
            return BadRequest(ApiResponse.Fail("Trạng thái không hợp lệ"));

        var order = await BaseQuery().FirstOrDefaultAsync(o => o.Id == id);
        if (order == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy đơn hàng"));

        var isAdmin = User.IsInRole("Admin");
        var shopId = await GetSellerShopIdAsync(userId, isAdmin);

        Guid? shopFilter = null;
        if (!isAdmin)
        {
            if (shopId is Guid sid && order.OrderDetails.Any(d => d.Product!.ShopId == sid))
                shopFilter = sid;
            else
                return StatusCode(StatusCodes.Status403Forbidden,
                    ApiResponse.Fail("Bạn không có quyền cập nhật đơn hàng này"));
        }

        // Không cho đổi trạng thái đơn đã kết thúc
        if (order.Status is OrderStatus.Delivered or OrderStatus.Cancelled)
            return BadRequest(ApiResponse.Fail(
                $"Đơn đã ở trạng thái '{order.Status}', không thể thay đổi"));

        // 'Delivered' là hành động xác nhận nhận hàng của khách; seller tối đa 'Shipped'.
        if (!isAdmin && newStatus == OrderStatus.Delivered)
            return BadRequest(ApiResponse.Fail(
                "Trạng thái 'Delivered' do khách xác nhận khi nhận hàng"));

        order.Status = newStatus;
        await _db.SaveChangesAsync();

        var dto = BuildDtoFromLoaded(order, shopFilter);
        return Ok(ApiResponse<OrderDto>.Ok(dto, "Đã cập nhật trạng thái đơn hàng"));
    }

    private IQueryable<Order> BaseQuery() => _db.Orders
        .Include(o => o.Address)
        .Include(o => o.OrderDetails)
            .ThenInclude(d => d.Product)
                .ThenInclude(p => p!.Images)
        .Include(o => o.OrderDetails)
            .ThenInclude(d => d.Product)
                .ThenInclude(p => p!.Shop)
        .AsQueryable();

    private async Task<Guid?> GetSellerShopIdAsync(Guid userId, bool isAdmin)
    {
        if (isAdmin || !User.IsInRole("Seller"))
            return null;
        var shop = await _db.Shops.FirstOrDefaultAsync(s => s.OwnerId == userId);
        return shop?.Id;
    }

    private static OrderDto BuildDtoFromLoaded(Order order, Guid? shopFilter)
    {
        var details = order.OrderDetails.AsEnumerable();
        if (shopFilter is Guid sid)
            details = details.Where(d => d.Product?.ShopId == sid);

        var items = details
            .OrderBy(d => d.Product?.Name)
            .Select(d =>
            {
                var product = d.Product;
                var imageUrl = product?.Images
                    .OrderByDescending(i => i.IsPrimary)
                    .ThenBy(i => i.DisplayOrder)
                    .Select(i => i.Url)
                    .FirstOrDefault();

                return new OrderItemDto(
                    d.Id,
                    d.ProductId,
                    product?.Name ?? string.Empty,
                    product?.Slug ?? string.Empty,
                    imageUrl,
                    d.UnitPrice,
                    d.Quantity,
                    d.TotalPrice,
                    product?.ShopId ?? Guid.Empty,
                    product?.Shop?.Name);
            })
            .ToList();

        // Seller chỉ thấy tổng phần hàng của shop mình (không gồm phí ship toàn đơn)
        var isPartial = shopFilter.HasValue;
        var shippingFee = isPartial ? 0m : order.ShippingFee;
        var totalAmount = isPartial ? items.Sum(i => i.TotalPrice) : order.TotalAmount;

        var address = order.Address;
        return new OrderDto(
            order.Id,
            order.OrderCode,
            order.Status.ToString(),
            totalAmount,
            shippingFee,
            order.Note,
            order.CreatedAt,
            order.PaidAt,
            new OrderAddressDto(
                address?.FullName ?? string.Empty,
                address?.Phone ?? string.Empty,
                address?.Street ?? string.Empty,
                address?.Ward ?? string.Empty,
                address?.District ?? string.Empty,
                address?.City ?? string.Empty),
            items,
            items.Sum(i => i.Quantity));
    }

    private bool TryGetUserId(out Guid userId)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdClaim, out userId);
    }

    private async Task<string> GenerateOrderCodeAsync()
    {
        var datePart = DateTime.UtcNow.ToString("yyyyMMdd");
        for (var attempt = 0; attempt < 10; attempt++)
        {
            var suffix = Random.Shared.Next(0, 10000).ToString("D4");
            var code = $"KS-{datePart}-{suffix}";
            if (!await _db.Orders.AnyAsync(o => o.OrderCode == code))
                return code;
        }
        // Cực hiếm khi va chạm 10 lần → dùng phần Guid làm hậu tố
        return $"KS-{datePart}-{Guid.NewGuid():N}"[..21];
    }

    private static OrderDto BuildDto(Order order, Address address, List<CartItem> sourceItems)
    {
        var productMap = sourceItems
            .Where(c => c.Product != null)
            .ToDictionary(c => c.ProductId, c => c.Product!);

        var items = order.OrderDetails.Select(d =>
        {
            productMap.TryGetValue(d.ProductId, out var product);
            var imageUrl = product?.Images
                .OrderByDescending(i => i.IsPrimary)
                .ThenBy(i => i.DisplayOrder)
                .Select(i => i.Url)
                .FirstOrDefault();

            return new OrderItemDto(
                d.Id,
                d.ProductId,
                product?.Name ?? string.Empty,
                product?.Slug ?? string.Empty,
                imageUrl,
                d.UnitPrice,
                d.Quantity,
                d.TotalPrice,
                product?.ShopId ?? Guid.Empty,
                product?.Shop?.Name);
        }).ToList();

        return new OrderDto(
            order.Id,
            order.OrderCode,
            order.Status.ToString(),
            order.TotalAmount,
            order.ShippingFee,
            order.Note,
            order.CreatedAt,
            order.PaidAt,
            new OrderAddressDto(
                address.FullName,
                address.Phone,
                address.Street,
                address.Ward,
                address.District,
                address.City),
            items,
            items.Sum(i => i.Quantity));
    }
}
