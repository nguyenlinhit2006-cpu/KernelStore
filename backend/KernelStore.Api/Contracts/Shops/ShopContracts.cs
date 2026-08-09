using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Shops;

public class CreateShopRequest
{
    [Required(ErrorMessage = "Tên shop là bắt buộc")]
    [StringLength(200, MinimumLength = 3)]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Slug là bắt buộc")]
    [RegularExpression(@"^[a-z0-9][a-z0-9-]*$", ErrorMessage = "Slug chỉ gồm chữ thường, số và dấu gạch ngang")]
    [StringLength(200, MinimumLength = 3)]
    public string Slug { get; set; } = string.Empty;

    [StringLength(2000)]
    public string Description { get; set; } = string.Empty;
}

public class UpdateShopRequest
{
    [Required(ErrorMessage = "Tên shop là bắt buộc")]
    [StringLength(200, MinimumLength = 3)]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Slug là bắt buộc")]
    [RegularExpression(@"^[a-z0-9][a-z0-9-]*$", ErrorMessage = "Slug chỉ gồm chữ thường, số và dấu gạch ngang")]
    [StringLength(200, MinimumLength = 3)]
    public string Slug { get; set; } = string.Empty;

    [StringLength(2000)]
    public string Description { get; set; } = string.Empty;
}

public record ShopDto(
    Guid Id,
    string Name,
    string Slug,
    string Description,
    string LogoUrl,
    string Status,
    DateTime CreatedAt,
    Guid OwnerId,
    string OwnerName);
