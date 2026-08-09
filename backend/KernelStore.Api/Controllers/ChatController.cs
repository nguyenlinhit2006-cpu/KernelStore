using System.Security.Claims;
using System.Text.Json;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Chat;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/chat")]
[Authorize]
public class ChatController : ControllerBase
{
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    private readonly ApplicationDbContext _db;
    private readonly ChatConnectionManager _connections;

    public ChatController(ApplicationDbContext db, ChatConnectionManager connections)
    {
        _db = db;
        _connections = connections;
    }

    // Danh sách hội thoại của user hiện tại (là khách hoặc là chủ shop).
    [HttpGet("conversations")]
    public async Task<IActionResult> ListConversations()
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var convos = await _db.Conversations
            .Include(c => c.Shop)
            .Include(c => c.Buyer)
            .Where(c => c.BuyerId == userId || c.Shop!.OwnerId == userId)
            .OrderByDescending(c => c.LastMessageAt)
            .ToListAsync();

        var ids = convos.Select(c => c.Id).ToList();
        var lastMsgs = await _db.ChatMessages
            .Where(m => ids.Contains(m.ConversationId))
            .GroupBy(m => m.ConversationId)
            .Select(g => new
            {
                ConversationId = g.Key,
                Last = g.OrderByDescending(m => m.CreatedAt).Select(m => m.Content).FirstOrDefault(),
                Unread = g.Count(m => m.SenderId != userId && !m.IsRead)
            })
            .ToListAsync();

        var dtos = convos.Select(c =>
        {
            var stat = lastMsgs.FirstOrDefault(x => x.ConversationId == c.Id);
            var isBuyer = c.BuyerId == userId;
            return new ConversationDto(
                c.Id, c.ShopId, c.Shop?.Name ?? string.Empty,
                c.BuyerId, c.Buyer?.FullName ?? string.Empty,
                isBuyer ? (c.Shop?.Name ?? string.Empty) : (c.Buyer?.FullName ?? string.Empty),
                stat?.Last, c.LastMessageAt, stat?.Unread ?? 0);
        }).ToList();

        return Ok(ApiResponse<List<ConversationDto>>.Ok(dtos, "OK"));
    }

    // Khách bắt đầu (hoặc lấy lại) hội thoại với một shop.
    [HttpPost("conversations")]
    public async Task<IActionResult> StartConversation([FromBody] StartConversationRequest request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var shop = await _db.Shops.FirstOrDefaultAsync(s => s.Id == request.ShopId);
        if (shop == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy shop"));
        if (shop.OwnerId == userId)
            return BadRequest(ApiResponse.Fail("Không thể chat với shop của chính bạn"));

        var convo = await _db.Conversations
            .Include(c => c.Shop).Include(c => c.Buyer)
            .FirstOrDefaultAsync(c => c.BuyerId == userId && c.ShopId == request.ShopId);

        if (convo == null)
        {
            convo = new Conversation
            {
                Id = Guid.NewGuid(),
                BuyerId = userId,
                ShopId = request.ShopId,
                CreatedAt = DateTime.UtcNow,
                LastMessageAt = DateTime.UtcNow
            };
            _db.Conversations.Add(convo);
            await _db.SaveChangesAsync();
            convo = await _db.Conversations
                .Include(c => c.Shop).Include(c => c.Buyer)
                .FirstAsync(c => c.Id == convo.Id);
        }

        return Ok(ApiResponse<ConversationDto>.Ok(ToDto(convo, userId), "OK"));
    }

    // Lịch sử tin nhắn; đồng thời đánh dấu đã đọc các tin của phía kia.
    [HttpGet("conversations/{id:guid}/messages")]
    public async Task<IActionResult> GetMessages(Guid id)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var convo = await _db.Conversations.Include(c => c.Shop)
            .FirstOrDefaultAsync(c => c.Id == id);
        if (convo == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy hội thoại"));
        if (!IsParticipant(convo, userId))
            return StatusCode(StatusCodes.Status403Forbidden, ApiResponse.Fail("Bạn không thuộc hội thoại này"));

        var messages = await _db.ChatMessages
            .Where(m => m.ConversationId == id)
            .OrderBy(m => m.CreatedAt)
            .ToListAsync();

        // Đánh dấu đã đọc các tin do phía kia gửi.
        var unread = messages.Where(m => m.SenderId != userId && !m.IsRead).ToList();
        if (unread.Count > 0)
        {
            foreach (var m in unread) m.IsRead = true;
            await _db.SaveChangesAsync();
        }

        var dtos = messages.Select(ToMessageDto).ToList();
        return Ok(ApiResponse<List<ChatMessageDto>>.Ok(dtos, "OK"));
    }

    // Gửi tin nhắn (REST). Lưu DB + đẩy realtime tới phía nhận qua WebSocket.
    [HttpPost("conversations/{id:guid}/messages")]
    public async Task<IActionResult> SendMessage(Guid id, [FromBody] SendMessageRequest request)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var convo = await _db.Conversations.Include(c => c.Shop)
            .FirstOrDefaultAsync(c => c.Id == id);
        if (convo == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy hội thoại"));
        if (!IsParticipant(convo, userId))
            return StatusCode(StatusCodes.Status403Forbidden, ApiResponse.Fail("Bạn không thuộc hội thoại này"));

        var message = new ChatMessage
        {
            Id = Guid.NewGuid(),
            ConversationId = id,
            SenderId = userId,
            Content = request.Content.Trim(),
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };
        _db.ChatMessages.Add(message);
        convo.LastMessageAt = message.CreatedAt;
        await _db.SaveChangesAsync();

        // Đẩy realtime tới người còn lại.
        var recipientId = convo.BuyerId == userId ? convo.Shop!.OwnerId : convo.BuyerId;
        var dto = ToMessageDto(message);
        await _connections.SendToUserAsync(recipientId, JsonSerializer.Serialize(dto, JsonOpts));

        return Ok(ApiResponse<ChatMessageDto>.Ok(dto, "OK"));
    }

    private static bool IsParticipant(Conversation convo, Guid userId) =>
        convo.BuyerId == userId || convo.Shop?.OwnerId == userId;

    private static ConversationDto ToDto(Conversation c, Guid userId)
    {
        var isBuyer = c.BuyerId == userId;
        return new ConversationDto(
            c.Id, c.ShopId, c.Shop?.Name ?? string.Empty,
            c.BuyerId, c.Buyer?.FullName ?? string.Empty,
            isBuyer ? (c.Shop?.Name ?? string.Empty) : (c.Buyer?.FullName ?? string.Empty),
            null, c.LastMessageAt, 0);
    }

    private static ChatMessageDto ToMessageDto(ChatMessage m) =>
        new(m.Id, m.ConversationId, m.SenderId, m.Content, m.CreatedAt);

    private bool TryGetUserId(out Guid userId)
    {
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(claim, out userId);
    }
}
