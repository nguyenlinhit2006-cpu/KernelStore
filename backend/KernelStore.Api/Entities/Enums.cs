namespace KernelStore.Api.Entities.Enums;

public enum UserRole
{
    Customer = 0,
    Seller = 1,
    Admin = 2
}

public enum ShopStatus
{
    Pending = 0,
    Approved = 1,
    Rejected = 2,
    // Ban tạm thời (vi phạm) — có thể gỡ ban để hoạt động lại.
    Banned = 3,
    // Ban vĩnh viễn (xóa shop) — ẩn shop & sản phẩm, không thể khôi phục.
    Deleted = 4
}

public enum OrderStatus
{
    Pending = 0,
    Confirmed = 1,
    Processing = 2,
    Shipped = 3,
    Delivered = 4,
    Cancelled = 5,
    // Khách yêu cầu trả hàng sau khi đã nhận (Delivered → ReturnRequested)
    ReturnRequested = 6,
    // Seller/Admin duyệt trả hàng → hoàn kho (ReturnRequested → Returned)
    Returned = 7
}

// Vòng đời một yêu cầu bảo hành.
public enum WarrantyStatus
{
    // Khách vừa gửi yêu cầu, chờ shop/admin xử lý.
    Pending = 0,
    // Shop/Admin chấp nhận bảo hành (kèm hình thức xử lý).
    Approved = 1,
    // Shop/Admin từ chối (ngoài điều kiện bảo hành...).
    Rejected = 2,
    // Đang tiến hành sửa/đổi/hoàn tiền.
    Processing = 3,
    // Đã hoàn tất bảo hành cho khách.
    Completed = 4,
    // Khách tự hủy yêu cầu khi còn ở trạng thái Pending.
    Cancelled = 5
}

// Hình thức xử lý bảo hành mà shop chọn khi chấp nhận.
public enum WarrantyResolution
{
    // Chưa quyết định (khi còn Pending / bị từ chối).
    None = 0,
    // Sửa chữa sản phẩm.
    Repair = 1,
    // Đổi sản phẩm mới.
    Replace = 2,
    // Hoàn tiền.
    Refund = 3
}
