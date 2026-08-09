using System.Net.WebSockets;
using System.Text;

var token = args.Length > 0 ? args[0] : "";
var seconds = args.Length > 1 ? int.Parse(args[1]) : 5;

var uri = new Uri($"ws://localhost:5000/ws/chat?access_token={Uri.EscapeDataString(token)}");
using var ws = new ClientWebSocket();
try
{
    await ws.ConnectAsync(uri, CancellationToken.None);
    Console.WriteLine("[ws] connected");
}
catch (Exception e)
{
    Console.WriteLine($"[ws] connect-failed: {e.Message}");
    return;
}

var cts = new CancellationTokenSource(TimeSpan.FromSeconds(seconds));
var buf = new byte[8192];
try
{
    while (ws.State == WebSocketState.Open)
    {
        var result = await ws.ReceiveAsync(new ArraySegment<byte>(buf), cts.Token);
        if (result.MessageType == WebSocketMessageType.Text)
            Console.WriteLine("[ws] " + Encoding.UTF8.GetString(buf, 0, result.Count));
    }
}
catch (OperationCanceledException)
{
}
catch (WebSocketException e)
{
    Console.WriteLine($"[ws] socket-error: {e.Message}");
}
Console.WriteLine("[ws] done");
