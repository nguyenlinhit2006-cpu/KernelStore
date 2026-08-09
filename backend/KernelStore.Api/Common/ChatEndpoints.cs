using System.IdentityModel.Tokens.Jwt;
using System.Net.WebSockets;
using System.Security.Claims;
using System.Text;
using KernelStore.Api.Services;
using Microsoft.IdentityModel.Tokens;

namespace KernelStore.Api.Common;

public static class ChatEndpoints
{
    /// <summary>
    /// WebSocket realtime cho chat: client kết nối ws://host/ws/chat?access_token=JWT.
    /// Server chỉ đẩy tin nhắn xuống (client gửi tin qua REST). Vòng lặp nhận chỉ để
    /// giữ kết nối và phát hiện ngắt.
    /// </summary>
    public static void MapChatWebSocket(this WebApplication app)
    {
        app.Map("/ws/chat", async context =>
        {
            if (!context.WebSockets.IsWebSocketRequest)
            {
                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                return;
            }

            var token = context.Request.Query["access_token"].ToString();
            if (!TryValidate(app.Configuration, token, out var userId))
            {
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                return;
            }

            var manager = context.RequestServices.GetRequiredService<ChatConnectionManager>();
            using var socket = await context.WebSockets.AcceptWebSocketAsync();
            var connectionId = Guid.NewGuid();
            manager.Add(userId, connectionId, socket);

            try
            {
                var buffer = new byte[1024];
                while (socket.State == WebSocketState.Open)
                {
                    var result = await socket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                    if (result.MessageType == WebSocketMessageType.Close)
                    {
                        await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "bye", CancellationToken.None);
                        break;
                    }
                    // Client không cần gửi gì (gửi tin qua REST); bỏ qua nội dung nhận được.
                }
            }
            catch (WebSocketException)
            {
                // Ngắt kết nối bất thường → dọn dẹp phía dưới.
            }
            finally
            {
                manager.Remove(userId, connectionId);
            }
        });
    }

    private static bool TryValidate(IConfiguration config, string token, out Guid userId)
    {
        userId = Guid.Empty;
        if (string.IsNullOrWhiteSpace(token))
            return false;

        var jwt = config.GetSection("Jwt");
        var parameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwt["Issuer"],
            ValidAudience = jwt["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt["Secret"]!))
        };

        try
        {
            var principal = new JwtSecurityTokenHandler().ValidateToken(token, parameters, out _);
            var idClaim = principal.FindFirstValue(ClaimTypes.NameIdentifier);
            return Guid.TryParse(idClaim, out userId);
        }
        catch
        {
            return false;
        }
    }
}
