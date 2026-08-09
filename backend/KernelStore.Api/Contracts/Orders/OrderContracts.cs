using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Orders;

public class CreateOrderRequest
{
    [Required(ErrorMessage = "Họ tên người nhận là bắt buộc")]
    [StringLength(200, MinimumLength = 2)]
    public string FullName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Số điện thoại là bắt buộc")]
    [RegularExpression(@"^[0-9+\-\s]{8,20}$", ErrorMessage = "Số điện thoại không hợp lệ")]
    public string Phone { get; set; } = string.Empty;

    [Required(ErrorMessage = "Địa chỉ là bắt buộc")]
    [StringLength(300, MinimumLength = 2)]
    public string Street { get; set; } = string.Empty;

    [StringLength(150)]
    public string Ward { get; set; } = string.Empty;

    [StringLength(150)]
    public string District { get; set; } = string.Empty;

    [Required(ErrorMessage = "Tỉnh/Thành phố là bắt buộc")]
    [StringLength(150)]
    public string City { get; set; } = string.Empty;

    [StringLength(1000)]
    public string Note { get; set; } = string.Empty;
}

public class UpdateOrderStatusRequest
{
    [Required(ErrorMessage = "Trạng thái là bắt buộc")]
    public string Status { get; set; } = string.Empty;
}

public record OrderAddressDto(
    string FullName,
    string Phone,
    string Street,
    string Ward,
    string District,
    string City);

public record OrderItemDto(
    Guid Id,
    Guid ProductId,
    string ProductName,
    string ProductSlug,
    string? ImageUrl,
    decimal UnitPrice,
    int Quantity,
    decimal TotalPrice,
    Guid ShopId,
    string? ShopName);

public record OrderDto(
    Guid Id,
    string OrderCode,
    string Status,
    decimal TotalAmount,
    decimal ShippingFee,
    string Note,
    DateTime CreatedAt,
    DateTime? PaidAt,
    OrderAddressDto Address,
    List<OrderItemDto> Items,
    int ItemCount,
    // True nếu người xem được phép quản lý trạng thái đơn (seller sở hữu hàng trong đơn, hoặc admin).
    bool CanManage);
