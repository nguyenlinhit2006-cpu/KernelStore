using KernelStore.Api.Data;
using KernelStore.Api.Entities;
using KernelStore.Api.Entities.Enums;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace KernelStore.Api.Common;

public static class DatabaseSeeder
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        var db = services.GetRequiredService<ApplicationDbContext>();
        await db.Database.MigrateAsync();

        var roleManager = services.GetRequiredService<RoleManager<IdentityRole<Guid>>>();

        var roles = new[] { UserRole.Customer.ToString(), UserRole.Seller.ToString(), UserRole.Admin.ToString() };
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
                await roleManager.CreateAsync(new IdentityRole<Guid> { Name = role, NormalizedName = role.ToUpper() });
        }

        await SeedAdminUserAsync(services);
    }

    private static async Task SeedAdminUserAsync(IServiceProvider services)
    {
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();

        const string email = "admin@ks.com";
        if (await userManager.FindByEmailAsync(email) != null)
            return;

        var admin = new ApplicationUser
        {
            UserName = "admin",
            Email = email,
            FullName = "System Admin",
            AvatarUrl = string.Empty,
            Role = UserRole.Admin,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var result = await userManager.CreateAsync(admin, "Admin@12345");
        if (result.Succeeded)
            await userManager.AddToRoleAsync(admin, UserRole.Admin.ToString());
    }

    /// Seeds sample categories, approved shops and products for a demo/dev run.
    /// Idempotent: does nothing if the demo data already exists.
    public static async Task SeedDemoDataAsync(IServiceProvider services)
    {
        var db = services.GetRequiredService<ApplicationDbContext>();
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();

        await db.Database.MigrateAsync();

        const string markerEmail = "seller1@demo.ks";
        // Completion marker: the last product added below. If present, a full
        // seed already ran — skip. Otherwise (partial run) we re-run; every
        // step below is get-or-create, so it converges without duplicates.
        if (await db.Products.AnyAsync(p => p.Slug == "monitor-arm-dual"))
        {
            Console.WriteLine("[seed] demo data already present — skipping.");
            return;
        }

        // ── Categories (create-if-missing by slug) ─────────────────────────
        var electronics = await EnsureCategoryAsync(db, "Electronics", "electronics", null);
        var laptops = await EnsureCategoryAsync(db, "Laptops", "laptops", electronics.Id);
        var phones = await EnsureCategoryAsync(db, "Phones", "phones", electronics.Id);
        var accessories = await EnsureCategoryAsync(db, "Accessories", "accessories", null);
        var home = await EnsureCategoryAsync(db, "Home & Office", "home-office", null);
        await db.SaveChangesAsync();

        // ── Sellers + approved shops ───────────────────────────────────────
        var alice = await CreateSellerAsync(userManager, markerEmail, "demo_alice", "Alice Nguyen");
        var bob = await CreateSellerAsync(userManager, "seller2@demo.ks", "demo_bob", "Bob Tran");

        var shopAlice = await EnsureShopAsync(db, alice.Id, "Kernel Gadgets", "kernel-gadgets",
            "Laptops, phones and dev gear.");
        var shopBob = await EnsureShopAsync(db, bob.Id, "Terminal Supplies", "terminal-supplies",
            "Keyboards, cables and home-office kit.");
        await db.SaveChangesAsync();

        // ── Products ───────────────────────────────────────────────────────
        await EnsureProductAsync(db, shopAlice.Id, laptops.Id, "KernelBook Pro 14", "kernelbook-pro-14",
            "14\" dev laptop, 32GB RAM, 1TB SSD.", 1899.00m, 1699.00m, 12, "KB-PRO-14");
        await EnsureProductAsync(db, shopAlice.Id, laptops.Id, "KernelBook Air", "kernelbook-air",
            "Fanless ultrabook for on-the-go hacking.", 1099.00m, null, 20, "KB-AIR");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "Pixel Shell X", "pixel-shell-x",
            "Bootloader-unlockable phone, 5000mAh.", 699.00m, 649.00m, 30, "PS-X");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "Pixel Shell Mini", "pixel-shell-mini",
            "Compact phone that fits one hand.", 499.00m, null, 25, "PS-MINI");

        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "Mechanical Keyboard 87", "mechanical-keyboard-87",
            "Tenkeyless hot-swap board, tactile switches.", 129.00m, 99.00m, 50, "MK-87");
        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "USB-C Hub 7-in-1", "usb-c-hub-7in1",
            "HDMI, USB-A, SD, PD passthrough.", 59.00m, null, 80, "HUB-7");
        await EnsureProductAsync(db, shopBob.Id, home.Id, "Standing Desk V2", "standing-desk-v2",
            "Electric sit/stand desk, memory presets.", 399.00m, 349.00m, 8, "DESK-V2");
        await EnsureProductAsync(db, shopBob.Id, home.Id, "Monitor Arm Dual", "monitor-arm-dual",
            "Gas-spring dual monitor arm.", 89.00m, null, 40, "ARM-2");

        await db.SaveChangesAsync();
        Console.WriteLine("[seed] demo data created: 5 categories, 2 shops, 8 products.");
    }

    private static async Task<Category> EnsureCategoryAsync(
        ApplicationDbContext db, string name, string slug, Guid? parentId)
    {
        var existing = await db.Categories.FirstOrDefaultAsync(c => c.Slug == slug);
        if (existing != null)
            return existing;

        var cat = new Category
        {
            Id = Guid.NewGuid(),
            Name = name,
            Slug = slug,
            Description = string.Empty,
            ParentId = parentId
        };
        db.Categories.Add(cat);
        return cat;
    }

    private static async Task<ApplicationUser> CreateSellerAsync(
        UserManager<ApplicationUser> userManager, string email, string userName, string fullName)
    {
        var existing = await userManager.FindByEmailAsync(email);
        if (existing != null)
            return existing;

        var user = new ApplicationUser
        {
            UserName = userName,
            Email = email,
            FullName = fullName,
            AvatarUrl = string.Empty,
            Role = UserRole.Seller,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        var result = await userManager.CreateAsync(user, "Seller@12345");
        if (!result.Succeeded)
            throw new InvalidOperationException(
                $"[seed] failed to create seller {email}: " +
                string.Join("; ", result.Errors.Select(e => e.Description)));

        await userManager.AddToRoleAsync(user, UserRole.Seller.ToString());
        return user;
    }

    private static async Task<Shop> EnsureShopAsync(
        ApplicationDbContext db, Guid ownerId, string name, string slug, string description)
    {
        var existing = await db.Shops.FirstOrDefaultAsync(s => s.Slug == slug);
        if (existing != null)
            return existing;

        var shop = new Shop
        {
            Id = Guid.NewGuid(),
            Name = name,
            Slug = slug,
            Description = description,
            LogoUrl = string.Empty,
            Status = ShopStatus.Approved,
            CreatedAt = DateTime.UtcNow,
            OwnerId = ownerId
        };
        db.Shops.Add(shop);
        return shop;
    }

    private static async Task EnsureProductAsync(
        ApplicationDbContext db, Guid shopId, Guid categoryId, string name, string slug,
        string description, decimal price, decimal? salePrice, int stock, string sku)
    {
        if (await db.Products.AnyAsync(p => p.Slug == slug))
            return;

        var product = new Product
        {
            Id = Guid.NewGuid(),
            Name = name,
            Slug = slug,
            Description = description,
            Price = price,
            SalePrice = salePrice,
            StockQuantity = stock,
            Sku = sku,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            ShopId = shopId,
            CategoryId = categoryId
        };
        product.Images.Add(new ProductImage
        {
            Id = Guid.NewGuid(),
            Url = $"https://picsum.photos/seed/{slug}/600/600",
            AltText = name,
            IsPrimary = true,
            DisplayOrder = 0
        });
        db.Products.Add(product);
    }
}
