namespace KernelStore.Api.Common;

public class ApiResponse<T>
{
    public bool Success { get; set; }
    public T? Data { get; set; }
    public string Message { get; set; } = string.Empty;
    public List<string> Errors { get; set; } = new();

    public static ApiResponse<T> Ok(T data, string message = "OK") => new()
    {
        Success = true,
        Data = data,
        Message = message
    };

    public static ApiResponse<T> Fail(string message, params string[] errors) => new()
    {
        Success = false,
        Message = message,
        Errors = errors.ToList()
    };
}

public class ApiResponse
{
    public bool Success { get; set; }
    public object? Data { get; set; }
    public string Message { get; set; } = string.Empty;
    public List<string> Errors { get; set; } = new();

    public static ApiResponse Ok(object? data = null, string message = "OK") => new()
    {
        Success = true,
        Data = data,
        Message = message
    };

    public static ApiResponse Fail(string message, params string[] errors) => new()
    {
        Success = false,
        Message = message,
        Errors = errors.ToList()
    };
}
