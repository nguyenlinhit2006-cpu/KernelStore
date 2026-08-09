using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Data;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<Shop> Shops => Set<Shop>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<ProductImage> ProductImages => Set<ProductImage>();
    public DbSet<Address> Addresses => Set<Address>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderDetail> OrderDetails => Set<OrderDetail>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<ApplicationUser>(e =>
        {
            e.Property(u => u.FullName).HasMaxLength(200);
            e.Property(u => u.AvatarUrl).HasMaxLength(500);
            e.HasOne(u => u.Shop)
                .WithOne(s => s.Owner)
                .HasForeignKey<Shop>(s => s.OwnerId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Shop>(e =>
        {
            e.Property(s => s.Name).IsRequired().HasMaxLength(200);
            e.Property(s => s.Slug).IsRequired().HasMaxLength(200);
            e.HasIndex(s => s.Slug).IsUnique();
        });

        builder.Entity<Category>(e =>
        {
            e.Property(c => c.Name).IsRequired().HasMaxLength(150);
            e.Property(c => c.Slug).IsRequired().HasMaxLength(150);
            e.HasIndex(c => c.Slug).IsUnique();
            e.HasOne(c => c.Parent)
                .WithMany(c => c.Children)
                .HasForeignKey(c => c.ParentId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Product>(e =>
        {
            e.Property(p => p.Name).IsRequired().HasMaxLength(300);
            e.Property(p => p.Slug).IsRequired().HasMaxLength(300);
            e.Property(p => p.Price).HasPrecision(18, 2);
            e.Property(p => p.SalePrice).HasPrecision(18, 2);
            e.HasIndex(p => p.Slug).IsUnique();
            e.HasOne(p => p.Shop)
                .WithMany(s => s.Products)
                .HasForeignKey(p => p.ShopId)
                .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(p => p.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(p => p.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<ProductImage>(e =>
        {
            e.Property(i => i.Url).IsRequired().HasMaxLength(500);
            e.HasOne(i => i.Product)
                .WithMany(p => p.Images)
                .HasForeignKey(i => i.ProductId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<Address>(e =>
        {
            e.HasOne(a => a.User)
                .WithMany(u => u.Addresses)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<Order>(e =>
        {
            e.Property(o => o.OrderCode).IsRequired().HasMaxLength(50);
            e.Property(o => o.TotalAmount).HasPrecision(18, 2);
            e.Property(o => o.ShippingFee).HasPrecision(18, 2);
            e.HasIndex(o => o.OrderCode).IsUnique();
            e.HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(o => o.Address)
                .WithMany()
                .HasForeignKey(o => o.AddressId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<OrderDetail>(e =>
        {
            e.Property(d => d.UnitPrice).HasPrecision(18, 2);
            e.Property(d => d.TotalPrice).HasPrecision(18, 2);
            e.HasOne(d => d.Order)
                .WithMany(o => o.OrderDetails)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasOne(d => d.Product)
                .WithMany(p => p.OrderDetails)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<Review>(e =>
        {
            e.Property(r => r.Comment).HasMaxLength(1000);
            e.HasOne(r => r.Product)
                .WithMany(p => p.Reviews)
                .HasForeignKey(r => r.ProductId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<CartItem>(e =>
        {
            e.HasOne(c => c.User)
                .WithMany(u => u.CartItems)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasOne(c => c.Product)
                .WithMany()
                .HasForeignKey(c => c.ProductId)
                .OnDelete(DeleteBehavior.Cascade);
            e.HasIndex(c => new { c.UserId, c.ProductId }).IsUnique();
        });

        builder.Entity<RefreshToken>(e =>
        {
            e.Property(t => t.Token).IsRequired().HasMaxLength(500);
            e.HasIndex(t => t.Token).IsUnique();
            e.HasOne(t => t.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
