using System.Collections.Concurrent;
using System.Net.WebSockets;
using System.Text;

namespace KernelStore.Api.Services;

/// <summary>
/// Theo dõi các WebSocket đang kết nối theo userId (một user có thể mở nhiều tab).
/// Dùng để đẩy tin nhắn realtime tới đúng người nhận. Singleton, in-memory (1 server).
/// </summary>
public class ChatConnectionManager
{
    private readonly ConcurrentDictionary<Guid, ConcurrentDictionary<Guid, WebSocket>> _connections = new();

    public void Add(Guid userId, Guid connectionId, WebSocket socket)
    {
        var sockets = _connections.GetOrAdd(userId, _ => new ConcurrentDictionary<Guid, WebSocket>());
        sockets[connectionId] = socket;
    }

    public void Remove(Guid userId, Guid connectionId)
    {
        if (_connections.TryGetValue(userId, out var sockets))
        {
            sockets.TryRemove(connectionId, out _);
            if (sockets.IsEmpty)
                _connections.TryRemove(userId, out _);
        }
    }

    /// <summary>Gửi payload JSON tới mọi kết nối đang mở của user (bỏ qua nếu offline).</summary>
    public async Task SendToUserAsync(Guid userId, string json)
    {
        if (!_connections.TryGetValue(userId, out var sockets))
            return;

        var bytes = Encoding.UTF8.GetBytes(json);
        foreach (var kv in sockets)
        {
            var socket = kv.Value;
            if (socket.State != WebSocketState.Open)
                continue;
            try
            {
                await socket.SendAsync(
                    new ArraySegment<byte>(bytes), WebSocketMessageType.Text, true, CancellationToken.None);
            }
            catch
            {
                // Kết nối hỏng → dọn dẹp.
                sockets.TryRemove(kv.Key, out _);
            }
        }
    }
}
