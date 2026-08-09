using KernelStore.Api.Contracts.Admin;

namespace KernelStore.Api.Contracts.Seller;

/// <summary>Top-selling product của shop (theo doanh thu).</summary>
public record TopProductStat(Guid ProductId, string Name, int QuantitySold, decimal Revenue);

/// <summary>Thống kê doanh thu + đơn hàng cho dashboard của seller (giới hạn trong shop của họ).</summary>
public record SellerDashboardDto(
    decimal TotalRevenue,
    int TotalOrders,
    int PendingOrders,
    int ItemsSold,
    int TotalProducts,
    int ActiveProducts,
    List<OrderStatusCount> OrdersByStatus,
    List<TopProductStat> TopProducts);
