namespace KernelStore.Api.Entities;

public class ProductImage
{
    public Guid Id { get; set; }
    public string Url { get; set; } = string.Empty;
    public string AltText { get; set; } = string.Empty;
    public bool IsPrimary { get; set; }
    public int DisplayOrder { get; set; }

    public Guid ProductId { get; set; }
    public virtual Product? Product { get; set; }
}
