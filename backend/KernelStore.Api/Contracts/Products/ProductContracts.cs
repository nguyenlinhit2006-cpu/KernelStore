using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Products;

public class CreateProductRequest
{
    [Required(ErrorMessage = "Tên sản phẩm là bắt buộc")]
    [StringLength(300, MinimumLength = 3)]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Slug là bắt buộc")]
    [RegularExpression(@"^[a-z0-9][a-z0-9-]*$", ErrorMessage = "Slug chỉ gồm chữ thường, số và dấu gạch ngang")]
    [StringLength(300, MinimumLength = 3)]
    public string Slug { get; set; } = string.Empty;

    [StringLength(4000)]
    public string Description { get; set; } = string.Empty;

    [Range(0, 99_999_999, ErrorMessage = "Giá không hợp lệ")]
    public decimal Price { get; set; }

    [Range(0, 99_999_999)]
    public decimal? SalePrice { get; set; }

    [Range(0, 1_000_000, ErrorMessage = "Tồn kho không hợp lệ")]
    public int StockQuantity { get; set; }

    [StringLength(100)]
    public string Sku { get; set; } = string.Empty;

    public Guid? CategoryId { get; set; }

    public List<string> Images { get; set; } = new();
}

public class UpdateProductRequest
{
    [Required(ErrorMessage = "Tên sản phẩm là bắt buộc")]
    [StringLength(300, MinimumLength = 3)]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Slug là bắt buộc")]
    [RegularExpression(@"^[a-z0-9][a-z0-9-]*$", ErrorMessage = "Slug chỉ gồm chữ thường, số và dấu gạch ngang")]
    [StringLength(300, MinimumLength = 3)]
    public string Slug { get; set; } = string.Empty;

    [StringLength(4000)]
    public string Description { get; set; } = string.Empty;

    [Range(0, 99_999_999, ErrorMessage = "Giá không hợp lệ")]
    public decimal Price { get; set; }

    [Range(0, 99_999_999)]
    public decimal? SalePrice { get; set; }

    [Range(0, 1_000_000, ErrorMessage = "Tồn kho không hợp lệ")]
    public int StockQuantity { get; set; }

    [StringLength(100)]
    public string Sku { get; set; } = string.Empty;

    public Guid? CategoryId { get; set; }

    public bool IsActive { get; set; } = true;

    public List<string> Images { get; set; } = new();
}

public record ProductImageDto(
    Guid Id,
    string Url,
    string AltText,
    bool IsPrimary,
    int DisplayOrder);

public record ProductDto(
    Guid Id,
    string Name,
    string Slug,
    string Description,
    decimal Price,
    decimal? SalePrice,
    int StockQuantity,
    string Sku,
    bool IsActive,
    DateTime CreatedAt,
    Guid ShopId,
    string? ShopName,
    Guid? CategoryId,
    string? CategoryName,
    List<ProductImageDto> Images);

public record PagedResult<T>(int Page, int PageSize, int Total, int TotalPages, List<T> Items);

public record ReviewDto(
    Guid Id,
    int Rating,
    string Comment,
    DateTime CreatedAt,
    Guid UserId,
    string UserName);

public record ShopSummaryDto(
    Guid Id,
    string Name,
    string Slug,
    string Description,
    string LogoUrl,
    int ProductCount);

public record ProductDetailDto(
    Guid Id,
    string Name,
    string Slug,
    string Description,
    decimal Price,
    decimal? SalePrice,
    int StockQuantity,
    string Sku,
    DateTime CreatedAt,
    Guid ShopId,
    string? ShopName,
    Guid? CategoryId,
    string? CategoryName,
    List<ProductImageDto> Images,
    List<ReviewDto> Reviews,
    ShopSummaryDto Shop,
    double AverageRating,
    int ReviewCount);
