using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Chat;

public record ConversationDto(
    Guid Id,
    Guid ShopId,
    string ShopName,
    Guid BuyerId,
    string BuyerName,
    // Tên phía đối thoại (đối với khách = tên shop, đối với seller = tên khách).
    string OtherName,
    string? LastMessage,
    DateTime LastMessageAt,
    int UnreadCount);

public record ChatMessageDto(
    Guid Id,
    Guid ConversationId,
    Guid SenderId,
    string Content,
    DateTime CreatedAt);

public class StartConversationRequest
{
    [Required]
    public Guid ShopId { get; set; }
}

public class SendMessageRequest
{
    [Required(ErrorMessage = "Nội dung không được để trống")]
    [StringLength(2000, MinimumLength = 1)]
    public string Content { get; set; } = string.Empty;
}
