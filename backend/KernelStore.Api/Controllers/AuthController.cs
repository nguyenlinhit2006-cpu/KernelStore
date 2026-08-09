using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Auth;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using KernelStore.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ApplicationDbContext _db;
    private readonly ITokenService _tokenService;
    private readonly IConfiguration _configuration;

    public AuthController(
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db,
        ITokenService tokenService,
        IConfiguration configuration)
    {
        _userManager = userManager;
        _db = db;
        _tokenService = tokenService;
        _configuration = configuration;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var existing = await _userManager.FindByEmailAsync(request.Email);
        if (existing != null)
            return BadRequest(ApiResponse.Fail("Email đã được sử dụng", "Email đã tồn tại trong hệ thống"));

        var user = new ApplicationUser
        {
            UserName = request.UserName,
            Email = request.Email,
            FullName = request.FullName,
            AvatarUrl = string.Empty,
            Role = UserRole.Customer,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
            return BadRequest(ApiResponse.Fail("Đăng ký thất bại", result.Errors.Select(e => e.Description).ToArray()));

        await _userManager.AddToRoleAsync(user, UserRole.Customer.ToString());

        var response = await BuildAuthResponseAsync(user);
        return Ok(ApiResponse<AuthResponse>.Ok(response, "Đăng ký thành công"));
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var user = await _userManager.FindByEmailAsync(request.Email);
        if (user == null)
            return Unauthorized(ApiResponse.Fail("Email hoặc mật khẩu không đúng"));

        if (!user.IsActive)
            return Unauthorized(ApiResponse.Fail("Tài khoản đã bị vô hiệu hóa"));

        var passwordOk = await _userManager.CheckPasswordAsync(user, request.Password);
        if (!passwordOk)
            return Unauthorized(ApiResponse.Fail("Email hoặc mật khẩu không đúng"));

        var response = await BuildAuthResponseAsync(user);
        return Ok(ApiResponse<AuthResponse>.Ok(response, "Đăng nhập thành công"));
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
    {
        var stored = await _db.RefreshTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Token == request.RefreshToken);

        if (stored == null || stored.IsRevoked || stored.IsUsed)
            return Unauthorized(ApiResponse.Fail("Refresh token không hợp lệ"));

        if (stored.ExpiresAt < DateTime.UtcNow)
            return Unauthorized(ApiResponse.Fail("Refresh token đã hết hạn"));

        if (stored.User == null || !stored.User.IsActive)
            return Unauthorized(ApiResponse.Fail("Tài khoản không hợp lệ"));

        stored.IsUsed = true;
        await _db.SaveChangesAsync();

        var response = await BuildAuthResponseAsync(stored.User);
        return Ok(ApiResponse<AuthResponse>.Ok(response, "Refresh token thành công"));
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<IActionResult> GetMe()
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized(ApiResponse.Fail("Không xác định được người dùng"));

        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy người dùng"));

        var roles = await _userManager.GetRolesAsync(user);
        var info = new UserInfoDto(
            user.Id, user.UserName ?? string.Empty, user.Email ?? string.Empty,
            user.FullName, user.AvatarUrl, user.Role.ToString(), user.IsActive);

        return Ok(ApiResponse<object>.Ok(new { info, roles }, "OK"));
    }

    private async Task<AuthResponse> BuildAuthResponseAsync(ApplicationUser user)
    {
        var roles = await _userManager.GetRolesAsync(user);
        var accessToken = _tokenService.CreateAccessToken(user, roles);

        var refreshToken = new RefreshToken
        {
            Id = Guid.NewGuid(),
            Token = _tokenService.GenerateRefreshToken(),
            UserId = user.Id,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(int.Parse(_configuration["Jwt:RefreshTokenExpiryDays"] ?? "7")),
            IsRevoked = false,
            IsUsed = false
        };

        _db.RefreshTokens.Add(refreshToken);
        await _db.SaveChangesAsync();

        var info = new UserInfoDto(
            user.Id, user.UserName ?? string.Empty, user.Email ?? string.Empty,
            user.FullName, user.AvatarUrl, user.Role.ToString(), user.IsActive);

        var jwt = new JwtSecurityTokenHandler().ReadJwtToken(accessToken);
        return new AuthResponse(accessToken, refreshToken.Token, jwt.ValidTo, info);
    }
}
