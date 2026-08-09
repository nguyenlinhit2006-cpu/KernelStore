using KernelStore.Api.Entities.Enums;

namespace KernelStore.Api.Entities;

public class Order
{
    public Guid Id { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public decimal TotalAmount { get; set; }
    public decimal ShippingFee { get; set; }
    public string Note { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? PaidAt { get; set; }

    public Guid UserId { get; set; }
    public Guid AddressId { get; set; }
    public virtual ApplicationUser? User { get; set; }
    public virtual Address? Address { get; set; }
    public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();
}
