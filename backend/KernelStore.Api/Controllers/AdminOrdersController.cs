using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Admin;
using KernelStore.Api.Contracts.Products;
using KernelStore.Api.Data;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/admin/orders")]
[Authorize(Roles = "Admin")]
public class AdminOrdersController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public AdminOrdersController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] string? status,
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        var query = _db.Orders
            .Include(o => o.User)
            .Include(o => o.OrderDetails)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(status) && Enum.TryParse<OrderStatus>(status, true, out var parsed))
            query = query.Where(o => o.Status == parsed);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(o => o.OrderCode.ToLower().Contains(term));
        }

        var total = await query.CountAsync();

        var orders = await query
            .OrderByDescending(o => o.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        var items = orders.Select(o => new AdminOrderDto(
            o.Id,
            o.OrderCode,
            o.Status.ToString(),
            o.TotalAmount,
            o.OrderDetails.Sum(d => d.Quantity),
            o.CreatedAt,
            o.UserId,
            o.User?.FullName ?? string.Empty,
            o.User?.Email ?? string.Empty)).ToList();

        var totalPages = (int)Math.Ceiling((double)total / pageSize);
        return Ok(ApiResponse<PagedResult<AdminOrderDto>>.Ok(
            new PagedResult<AdminOrderDto>(page, pageSize, total, totalPages, items), "OK"));
    }
}
