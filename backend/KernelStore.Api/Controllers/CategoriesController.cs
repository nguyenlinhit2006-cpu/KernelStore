using KernelStore.Api.Common;
using KernelStore.Api.Contracts.Categories;
using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Controllers;

[ApiController]
[Route("api/categories")]
public class CategoriesController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public CategoriesController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> List()
    {
        var all = await _db.Categories
            .Include(c => c.Products)
            .OrderBy(c => c.Name)
            .ToListAsync();

        var tree = BuildTree(all);
        return Ok(ApiResponse<List<CategoryDto>>.Ok(tree, "OK"));
    }

    [HttpGet("{slug}")]
    public async Task<IActionResult> GetBySlug(string slug)
    {
        var category = await _db.Categories
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.Slug == slug);

        if (category == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy danh mục"));

        var dto = new CategoryDto(
            category.Id, category.Name, category.Slug, category.Description,
            category.ParentId, category.Products.Count, null);
        return Ok(ApiResponse<CategoryDto>.Ok(dto, "OK"));
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCategoryRequest request)
    {
        if (await _db.Categories.AnyAsync(c => c.Slug == request.Slug))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        if (request.ParentId is Guid pid && !await _db.Categories.AnyAsync(c => c.Id == pid))
            return BadRequest(ApiResponse.Fail("Danh mục cha không tồn tại"));

        var category = new Category
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Slug = request.Slug,
            Description = request.Description,
            ParentId = request.ParentId
        };

        _db.Categories.Add(category);
        await _db.SaveChangesAsync();

        return Ok(ApiResponse<CategoryDto>.Ok(ToDto(category), "Đã tạo danh mục."));
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCategoryRequest request)
    {
        var category = await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);
        if (category == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy danh mục"));

        if (await _db.Categories.AnyAsync(c => c.Slug == request.Slug && c.Id != id))
            return BadRequest(ApiResponse.Fail("Slug đã được sử dụng"));

        if (request.ParentId == id)
            return BadRequest(ApiResponse.Fail("Danh mục không thể là cha của chính nó"));

        if (request.ParentId is Guid pid && pid != id && !await _db.Categories.AnyAsync(c => c.Id == pid))
            return BadRequest(ApiResponse.Fail("Danh mục cha không tồn tại"));

        category.Name = request.Name;
        category.Slug = request.Slug;
        category.Description = request.Description;
        category.ParentId = request.ParentId;

        await _db.SaveChangesAsync();

        return Ok(ApiResponse<CategoryDto>.Ok(ToDto(category), "Đã cập nhật danh mục."));
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var category = await _db.Categories
            .Include(c => c.Children)
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null)
            return NotFound(ApiResponse.Fail("Không tìm thấy danh mục"));

        if (category.Children.Count > 0)
            return BadRequest(ApiResponse.Fail("Danh mục có danh mục con. Không thể xóa."));

        if (category.Products.Count > 0)
            return BadRequest(ApiResponse.Fail("Danh mục đang chứa sản phẩm. Không thể xóa."));

        _db.Categories.Remove(category);
        await _db.SaveChangesAsync();

        return Ok(ApiResponse.Ok(null, "Đã xóa danh mục."));
    }

    private static CategoryDto ToDto(Category c) => new(
        c.Id, c.Name, c.Slug, c.Description, c.ParentId, 0, null);

    private static List<CategoryDto> BuildTree(List<Category> all)
    {
        var nodes = new Dictionary<Guid, CategoryDto>();
        foreach (var c in all)
        {
            nodes[c.Id] = new CategoryDto(
                c.Id, c.Name, c.Slug, c.Description, c.ParentId,
                c.Products.Count, new List<CategoryDto>());
        }

        var roots = new List<CategoryDto>();
        foreach (var c in all)
        {
            var node = nodes[c.Id];
            if (c.ParentId is Guid pid && nodes.TryGetValue(pid, out var parent))
                parent.Children!.Add(node);
            else
                roots.Add(node);
        }

        return roots;
    }
}
