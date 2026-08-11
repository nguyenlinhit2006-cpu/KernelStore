using KernelStore.Api.Entities.Enums;

namespace KernelStore.Api.Entities;

// Một yêu cầu bảo hành do khách gửi cho một dòng sản phẩm đã mua (OrderDetail).
// Chỉ hợp lệ khi đơn đã Delivered và còn trong thời hạn bảo hành của sản phẩm.
public class WarrantyClaim
{
    public Guid Id { get; set; }
    public string ClaimCode { get; set; } = string.Empty;

    // Mô tả lỗi/tình trạng do khách cung cấp.
    public string Description { get; set; } = string.Empty;
    // Ảnh minh chứng (tùy chọn), tái dùng UploadsController.
    public string ImageUrl { get; set; } = string.Empty;

    public WarrantyStatus Status { get; set; } = WarrantyStatus.Pending;
    public WarrantyResolution Resolution { get; set; } = WarrantyResolution.None;
    // Ghi chú của shop khi duyệt/từ chối/hoàn tất.
    public string ResolutionNote { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    public DateTime? ResolvedAt { get; set; }

    // Dòng sản phẩm cụ thể được bảo hành (gắn với đơn + sản phẩm + số lượng).
    public Guid OrderDetailId { get; set; }
    // Người mua tạo yêu cầu.
    public Guid UserId { get; set; }
    // Sản phẩm được bảo hành (tiện truy vấn/hiển thị).
    public Guid ProductId { get; set; }
    // Shop chịu trách nhiệm bảo hành (để lọc theo seller).
    public Guid ShopId { get; set; }

    public virtual OrderDetail? OrderDetail { get; set; }
    public virtual ApplicationUser? User { get; set; }
    public virtual Product? Product { get; set; }
    public virtual Shop? Shop { get; set; }
}
