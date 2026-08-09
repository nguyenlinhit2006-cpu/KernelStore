namespace KernelStore.Api.Entities;

/// <summary>Một tin nhắn trong cuộc hội thoại chat.</summary>
public class ChatMessage
{
    public Guid Id { get; set; }
    public Guid ConversationId { get; set; }
    public Guid SenderId { get; set; }
    public string Content { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public virtual Conversation? Conversation { get; set; }
    public virtual ApplicationUser? Sender { get; set; }
}
