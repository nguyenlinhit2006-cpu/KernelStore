using System.Security.Claims;
using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Admin;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/admin/users")]
[Authorize(Roles = "Admin")]
public class AdminUsersController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public AdminUsersController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] string? search,
        [FromQuery] string? role,
        [FromQuery] bool? isActive)
    {
        var query = _db.Users.AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(u =>
                (u.UserName != null && u.UserName.ToLower().Contains(term)) ||
                (u.Email != null && u.Email.ToLower().Contains(term)) ||
                u.FullName.ToLower().Contains(term));
        }

        if (!string.IsNullOrWhiteSpace(role) && Enum.TryParse<UserRole>(role, true, out var parsedRole))
            query = query.Where(u => u.Role == parsedRole);

        if (isActive.HasValue)
            query = query.Where(u => u.IsActive == isActive.Value);

        var users = await query.OrderByDescending(u => u.CreatedAt).ToListAsync();

        var dtos = users.Select(ToDto).ToList();
        return Ok(ApiResponse<List<AdminUserDto>>.Ok(dtos, "OK"));
    }

    [HttpPost("{id:guid}/ban")]
    public async Task<IActionResult> Ban(Guid id)
    {
        var (user, error) = await GetTargetAsync(id);
        if (error != null)
            return error;

        if (user!.Role == UserRole.Admin)
            return BadRequest(ApiResponse.Fail("Không thể vô hiệu hóa tài khoản Admin"));

        if (!user.IsActive)
            return BadRequest(ApiResponse.Fail("Tài khoản đã bị vô hiệu hóa"));

        user.IsActive = false;

        // Thu hồi refresh token để phiên hiện tại không thể gia hạn
        var tokens = await _db.RefreshTokens.Where(t => t.UserId == id && !t.IsRevoked).ToListAsync();
        foreach (var t in tokens)
            t.IsRevoked = true;

        await _db.SaveChangesAsync();
        return Ok(ApiResponse<AdminUserDto>.Ok(ToDto(user), "Đã vô hiệu hóa người dùng"));
    }

    [HttpPost("{id:guid}/unban")]
    public async Task<IActionResult> Unban(Guid id)
    {
        var (user, error) = await GetTargetAsync(id);
        if (error != null)
            return error;

        if (user!.IsActive)
            return BadRequest(ApiResponse.Fail("Tài khoản đang hoạt động"));

        user.IsActive = true;
        await _db.SaveChangesAsync();
        return Ok(ApiResponse<AdminUserDto>.Ok(ToDto(user), "Đã kích hoạt lại người dùng"));
    }

    private async Task<(ApplicationUser? user, IActionResult? error)> GetTargetAsync(Guid id)
    {
        var currentIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (Guid.TryParse(currentIdClaim, out var currentId) && currentId == id)
            return (null, BadRequest(ApiResponse.Fail("Không thể thao tác trên chính tài khoản của bạn")));

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (user == null)
            return (null, NotFound(ApiResponse.Fail("Không tìm thấy người dùng")));

        return (user, null);
    }

    private static AdminUserDto ToDto(ApplicationUser u) => new(
        u.Id, u.UserName ?? string.Empty, u.Email ?? string.Empty,
        u.FullName, u.Role.ToString(), u.IsActive, u.CreatedAt);
}
