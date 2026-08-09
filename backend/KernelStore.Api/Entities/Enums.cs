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
    Banned = 3
}

public enum OrderStatus
{
    Pending = 0,
    Confirmed = 1,
    Processing = 2,
    Shipped = 3,
    Delivered = 4,
    Cancelled = 5
}
