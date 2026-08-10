namespace KernelStore.Api.Entities;

public class Category
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    // Null = global category (managed by Admin, shown in the public catalog).
    // Set  = category owned by a specific shop, managed by that shop's seller.
    public Guid? OwnerShopId { get; set; }

    public Guid? ParentId { get; set; }
    public virtual Category? Parent { get; set; }
    public virtual ICollection<Category> Children { get; set; } = new List<Category>();
    public virtual ICollection<Product> Products { get; set; } = new List<Product>();
}
