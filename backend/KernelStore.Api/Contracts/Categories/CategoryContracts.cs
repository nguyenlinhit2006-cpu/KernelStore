using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Categories;

public class CreateCategoryRequest
{
    [Required(ErrorMessage = "Tên danh mục là bắt buộc")]
    [StringLength(150, MinimumLength = 2)]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Slug là bắt buộc")]
    [RegularExpression(@"^[a-z0-9][a-z0-9-]*$", ErrorMessage = "Slug chỉ gồm chữ thường, số và dấu gạch ngang")]
    [StringLength(150, MinimumLength = 2)]
    public string Slug { get; set; } = string.Empty;

    [StringLength(500)]
    public string Description { get; set; } = string.Empty;

    public Guid? ParentId { get; set; }
}

public class UpdateCategoryRequest
{
    [Required(ErrorMessage = "Tên danh mục là bắt buộc")]
    [StringLength(150, MinimumLength = 2)]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Slug là bắt buộc")]
    [RegularExpression(@"^[a-z0-9][a-z0-9-]*$", ErrorMessage = "Slug chỉ gồm chữ thường, số và dấu gạch ngang")]
    [StringLength(150, MinimumLength = 2)]
    public string Slug { get; set; } = string.Empty;

    [StringLength(500)]
    public string Description { get; set; } = string.Empty;

    public Guid? ParentId { get; set; }
}

public record CategoryDto(
    Guid Id,
    string Name,
    string Slug,
    string Description,
    Guid? ParentId,
    int ProductCount,
    List<CategoryDto>? Children);
