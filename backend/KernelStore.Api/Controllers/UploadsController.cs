using KernelStore.Api.Common;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace KernelStore.Api.Controllers;

/// <summary>
/// File uploads for product imagery. Stores under wwwroot/uploads and returns
/// an absolute URL so the frontend (served from another origin) can render it.
/// </summary>
[ApiController]
[Route("api/uploads")]
[Authorize]
public class UploadsController : ControllerBase
{
    private const long MaxBytes = 5 * 1024 * 1024; // 5 MB

    // Extension -> expected content type. Drives what the file picker accepts.
    private static readonly Dictionary<string, string> Allowed = new()
    {
        [".jpg"] = "image/jpeg",
        [".jpeg"] = "image/jpeg",
        [".png"] = "image/png",
        [".svg"] = "image/svg+xml",
    };

    private readonly IWebHostEnvironment _env;

    public UploadsController(IWebHostEnvironment env) => _env = env;

    [HttpPost("image")]
    [RequestSizeLimit(MaxBytes)]
    public async Task<IActionResult> UploadImage(IFormFile? file)
    {
        if (file is null || file.Length == 0)
            return BadRequest(ApiResponse.Fail("Chưa chọn file"));

        if (file.Length > MaxBytes)
            return BadRequest(ApiResponse.Fail("File quá lớn (tối đa 5MB)"));

        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!Allowed.ContainsKey(ext))
            return BadRequest(ApiResponse.Fail("Chỉ chấp nhận ảnh jpg, png hoặc svg"));

        var webRoot = _env.WebRootPath
            ?? Path.Combine(_env.ContentRootPath, "wwwroot");
        var uploadsDir = Path.Combine(webRoot, "uploads");
        Directory.CreateDirectory(uploadsDir);

        var fileName = $"{Guid.NewGuid():N}{ext}";
        var fullPath = Path.Combine(uploadsDir, fileName);
        await using (var stream = System.IO.File.Create(fullPath))
        {
            await file.CopyToAsync(stream);
        }

        var url = $"{Request.Scheme}://{Request.Host}/uploads/{fileName}";
        return Ok(ApiResponse.Ok(new { url }, "Đã tải ảnh lên"));
    }
}
