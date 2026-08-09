namespace KernelStore.Api.Entities;

public class RefreshToken
{
    public Guid Id { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsRevoked { get; set; }
    public bool IsUsed { get; set; }

    public Guid UserId { get; set; }
    public virtual ApplicationUser? User { get; set; }
}
