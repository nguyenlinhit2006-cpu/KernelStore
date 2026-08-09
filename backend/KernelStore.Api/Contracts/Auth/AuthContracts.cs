using System.ComponentModel.DataAnnotations;

namespace KernelStore.Api.Contracts.Auth;

public class RegisterRequest
{
    [Required(ErrorMessage = "FullName là bắt buộc")]
    [StringLength(200, MinimumLength = 2)]
    public string FullName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email là bắt buộc")]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "UserName là bắt buộc")]
    [StringLength(50, MinimumLength = 3)]
    public string UserName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password là bắt buộc")]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;
}

public class LoginRequest
{
    [Required(ErrorMessage = "Email là bắt buộc")]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password là bắt buộc")]
    public string Password { get; set; } = string.Empty;
}

public class RefreshRequest
{
    [Required(ErrorMessage = "RefreshToken là bắt buộc")]
    public string RefreshToken { get; set; } = string.Empty;
}

public record AuthResponse(string AccessToken, string RefreshToken, DateTime ExpiresAt, UserInfoDto User);

public record UserInfoDto(
    Guid Id,
    string UserName,
    string Email,
    string FullName,
    string AvatarUrl,
    string Role,
    bool IsActive);
