namespace KernelStore.Api.Entities;

public class Review
{
    public Guid Id { get; set; }
    public int Rating { get; set; }
    public string Comment { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Guid ProductId { get; set; }
    public Guid UserId { get; set; }
    public virtual Product? Product { get; set; }
    public virtual ApplicationUser? User { get; set; }
}
