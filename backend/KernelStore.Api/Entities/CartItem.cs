namespace KernelStore.Api.Entities;

public class CartItem
{
    public Guid Id { get; set; }
    public int Quantity { get; set; }

    public Guid UserId { get; set; }
    public Guid ProductId { get; set; }
    public virtual ApplicationUser? User { get; set; }
    public virtual Product? Product { get; set; }
}
