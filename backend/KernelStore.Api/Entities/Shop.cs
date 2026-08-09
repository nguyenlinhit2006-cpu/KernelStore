using KernelStore.Api.Entities.Enums;

namespace KernelStore.Api.Entities;

public class Shop
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string LogoUrl { get; set; } = string.Empty;
    public ShopStatus Status { get; set; } = ShopStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Guid OwnerId { get; set; }
    public virtual ApplicationUser? Owner { get; set; }
    public virtual ICollection<Product> Products { get; set; } = new List<Product>();
}
