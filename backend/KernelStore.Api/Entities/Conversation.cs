namespace KernelStore.Api.Entities;

/// <summary>Cuộc hội thoại chat giữa 1 khách mua và 1 shop (duy nhất theo cặp Buyer+Shop).</summary>
public class Conversation
{
    public Guid Id { get; set; }
    public Guid BuyerId { get; set; }
    public Guid ShopId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime LastMessageAt { get; set; } = DateTime.UtcNow;

    public virtual ApplicationUser? Buyer { get; set; }
    public virtual Shop? Shop { get; set; }
    public virtual ICollection<ChatMessage> Messages { get; set; } = new List<ChatMessage>();
}
