using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Warranty;

// Khách gửi yêu cầu bảo hành cho một dòng sản phẩm đã mua.
public class CreateWarrantyClaimRequest
{
    [Required(ErrorMessage = "Thiếu dòng sản phẩm cần bảo hành")]
    public Guid OrderDetailId { get; set; }

    [Required(ErrorMessage = "Vui lòng mô tả tình trạng lỗi")]
    [StringLength(2000, MinimumLength = 10,
        ErrorMessage = "Mô tả từ 10 đến 2000 ký tự")]
    public string Description { get; set; } = string.Empty;

    [StringLength(500)]
    public string ImageUrl { get; set; } = string.Empty;
}

// Shop/Admin chấp nhận bảo hành và chọn hình thức xử lý.
public class ApproveWarrantyRequest
{
    [Required(ErrorMessage = "Chọn hình thức xử lý (Repair/Replace/Refund)")]
    public string Resolution { get; set; } = string.Empty;

    [StringLength(1000)]
    public string Note { get; set; } = string.Empty;
}

// Ghi chú kèm khi từ chối / hoàn tất.
public class WarrantyNoteRequest
{
    [StringLength(1000)]
    public string Note { get; set; } = string.Empty;
}

public record WarrantyClaimDto(
    Guid Id,
    string ClaimCode,
    string Status,
    string Resolution,
    string ResolutionNote,
    string Description,
    string? ImageUrl,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    DateTime? ResolvedAt,
    Guid OrderDetailId,
    Guid OrderId,
    string OrderCode,
    Guid ProductId,
    string ProductName,
    string ProductSlug,
    string? ProductImageUrl,
    int Quantity,
    int WarrantyMonths,
    DateTime? WarrantyExpiresAt,
    Guid ShopId,
    string? ShopName,
    Guid UserId,
    string UserName,
    // Người xem là shop sở hữu / admin → được xử lý yêu cầu.
    bool CanManage);
