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
