namespace KernelStore.Api.Contracts.Admin;

public record OrderStatusCount(string Status, int Count);

public record AdminOrderDto(
    Guid Id,
    string OrderCode,
    string Status,
    decimal TotalAmount,
    int ItemCount,
    DateTime CreatedAt,
    Guid CustomerId,
    string CustomerName,
    string CustomerEmail);

public record AdminUserDto(
    Guid Id,
    string UserName,
    string Email,
    string FullName,
    string Role,
    bool IsActive,
    DateTime CreatedAt);

public record AdminDashboardDto(
    int TotalUsers,
    int TotalShops,
    int PendingShops,
    int ApprovedShops,
    int TotalProducts,
    int ActiveProducts,
    int TotalOrders,
    decimal TotalRevenue,
    List<OrderStatusCount> OrdersByStatus);
