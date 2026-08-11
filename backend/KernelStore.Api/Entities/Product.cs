namespace KernelStore.Api.Entities;

public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public decimal? SalePrice { get; set; }
    public int StockQuantity { get; set; }
    public string Sku { get; set; } = string.Empty;
    // Thời hạn bảo hành tính theo tháng (0 = không bảo hành).
    public int WarrantyMonths { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Guid? CategoryId { get; set; }
    public Guid ShopId { get; set; }
    public virtual Category? Category { get; set; }
    public virtual Shop? Shop { get; set; }
    public virtual ICollection<ProductImage> Images { get; set; } = new List<ProductImage>();
    public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();
    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}
