using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Cart;

public class AddToCartRequest
{
    [Required(ErrorMessage = "Sản phẩm là bắt buộc")]
    public Guid ProductId { get; set; }

    [Range(1, 1000, ErrorMessage = "Số lượng phải từ 1 đến 1000")]
    public int Quantity { get; set; } = 1;
}

public class UpdateCartItemRequest
{
    [Range(0, 1000, ErrorMessage = "Số lượng phải từ 0 đến 1000")]
    public int Quantity { get; set; }
}

public record CartItemDto(
    Guid Id,
    Guid ProductId,
    string Name,
    string Slug,
    decimal Price,
    decimal? SalePrice,
    decimal UnitPrice,
    int Quantity,
    int StockQuantity,
    decimal LineTotal,
    string? ImageUrl,
    Guid ShopId,
    string? ShopName);

public record CartDto(
    List<CartItemDto> Items,
    int TotalItems,
    decimal Subtotal);
