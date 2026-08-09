namespace KernelStore.Api.Entities;

public class OrderDetail
{
    public Guid Id { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice { get; set; }

    public Guid OrderId { get; set; }
    public Guid ProductId { get; set; }
    public virtual Order? Order { get; set; }
    public virtual Product? Product { get; set; }
}
