using System.ComponentModel.DataAnnotations;
using KernelStore.Api.Contracts.Products;

namespace KernelStore.Api.Contracts.Reviews;

public record ProductReviewsDto(
    List<ReviewDto> Reviews,
    double AverageRating,
    int ReviewCount);

public class CreateReviewRequest
{
    [Required(ErrorMessage = "Sản phẩm là bắt buộc")]
    public Guid ProductId { get; set; }

    [Range(1, 5, ErrorMessage = "Đánh giá phải từ 1 đến 5 sao")]
    public int Rating { get; set; }

    [StringLength(1000, ErrorMessage = "Nhận xét tối đa 1000 ký tự")]
    public string Comment { get; set; } = string.Empty;
}
