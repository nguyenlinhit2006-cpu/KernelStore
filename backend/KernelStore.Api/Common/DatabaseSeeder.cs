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
        if (await db.Products.AnyAsync(p => p.Slug == "apple-iphone-charger"))
        {
            Console.WriteLine("[seed] demo data already present — skipping.");
            return;
        }

        // ── Categories (create-if-missing by slug) ─────────────────────────
        var electronics = await EnsureCategoryAsync(db, "Electronics", "electronics", null);
        var laptops = await EnsureCategoryAsync(db, "Laptops", "laptops", electronics.Id);
        var phones = await EnsureCategoryAsync(db, "Phones", "phones", electronics.Id);
        var tablets = await EnsureCategoryAsync(db, "Tablets", "tablets", electronics.Id);
        var accessories = await EnsureCategoryAsync(db, "Accessories", "accessories", null);
        await db.SaveChangesAsync();

        // ── Sellers + approved shops ───────────────────────────────────────
        var alice = await CreateSellerAsync(userManager, markerEmail, "demo_alice", "Alice Nguyen");
        var bob = await CreateSellerAsync(userManager, "seller2@demo.ks", "demo_bob", "Bob Tran");

        var shopAlice = await EnsureShopAsync(db, alice.Id, "TechWorld Store", "techworld-store",
            "Authentic laptops, smartphones and tablets from top brands.");
        var shopBob = await EnsureShopAsync(db, bob.Id, "GadgetHub", "gadgethub",
            "Audio, smart speakers, chargers and mobile accessories.");
        await db.SaveChangesAsync();

        // ── Products ───────────────────────────────────────────────────────
        await EnsureProductAsync(db, shopAlice.Id, laptops.Id, "Apple MacBook Pro 14 Inch Space Grey", "apple-macbook-pro-14-inch-space-grey",
            "The MacBook Pro 14 Inch in Space Grey is a powerful and sleek laptop, featuring Apple's M1 Pro chip for exceptional performance and a stunning Retina display.", 1999.99m, 1906.19m, 24, "LAP-APP-APP-078");
        await EnsureProductAsync(db, shopAlice.Id, laptops.Id, "Asus Zenbook Pro Dual Screen Laptop", "asus-zenbook-pro-dual-screen-laptop",
            "The Asus Zenbook Pro Dual Screen Laptop is a high-performance device with dual screens, providing productivity and versatility for creative professionals.", 1799.99m, 1599.47m, 45, "LAP-ASU-ASU-079");
        await EnsureProductAsync(db, shopAlice.Id, laptops.Id, "Huawei Matebook X Pro", "huawei-matebook-x-pro",
            "The Huawei Matebook X Pro is a slim and stylish laptop with a high-resolution touchscreen display, offering a premium experience for users on the go.", 1399.99m, 1268.67m, 75, "LAP-HUA-HUA-080");
        await EnsureProductAsync(db, shopAlice.Id, laptops.Id, "Lenovo Yoga 920", "lenovo-yoga-920",
            "The Lenovo Yoga 920 is a 2-in-1 convertible laptop with a flexible hinge, allowing you to use it as a laptop or tablet, offering versatility and portability.", 1099.99m, 1027.94m, 40, "LAP-LEN-LEN-081");
        await EnsureProductAsync(db, shopAlice.Id, laptops.Id, "New DELL XPS 13 9300 Laptop", "new-dell-xps-13-9300-laptop",
            "The New DELL XPS 13 9300 Laptop is a compact and powerful device, featuring a virtually borderless InfinityEdge display and high-end performance for various...", 1499.99m, 1321.64m, 74, "LAP-DEL-DEL-082");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "iPhone 5s", "iphone-5s",
            "The iPhone 5s is a classic smartphone known for its compact design and advanced features during its release. While it's an older model, it still provides a r...", 199.99m, 174.17m, 25, "SMA-APP-IPH-121");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "iPhone 6", "iphone-6",
            "The iPhone 6 is a stylish and capable smartphone with a larger display and improved performance. It introduced new features and design elements, making it a...", 299.99m, 279.92m, 60, "SMA-APP-IPH-122");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "iPhone 13 Pro", "iphone-13-pro",
            "The iPhone 13 Pro is a cutting-edge smartphone with a powerful camera system, high-performance chip, and stunning display. It offers advanced features for us...", 1099.99m, 996.92m, 56, "SMA-APP-IPH-123");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "iPhone X", "iphone-x",
            "The iPhone X is a flagship smartphone featuring a bezel-less OLED display, facial recognition technology (Face ID), and impressive performance. It represents...", 899.99m, 723.68m, 37, "SMA-APP-IPH-124");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "Oppo A57", "oppo-a57",
            "The Oppo A57 is a mid-range smartphone known for its sleek design and capable features. It offers a balance of performance and affordability, making it a pop...", 249.99m, null, 19, "SMA-OPP-OPP-125");
        await EnsureProductAsync(db, shopAlice.Id, phones.Id, "Oppo F19 Pro Plus", "oppo-f19-pro-plus",
            "The Oppo F19 Pro Plus is a feature-rich smartphone with a focus on camera capabilities. It boasts advanced photography features and a powerful performance fo...", 399.99m, 325.43m, 78, "SMA-OPP-OPP-126");
        await EnsureProductAsync(db, shopAlice.Id, tablets.Id, "iPad Mini 2021 Starlight", "ipad-mini-2021-starlight",
            "The iPad Mini 2021 in Starlight is a compact and powerful tablet from Apple. Featuring a stunning Retina display, powerful A-series chip, and a sleek design,...", 499.99m, 481.79m, 47, "TAB-APP-IPA-159");
        await EnsureProductAsync(db, shopAlice.Id, tablets.Id, "Samsung Galaxy Tab S8 Plus Grey", "samsung-galaxy-tab-s8-plus-grey",
            "The Samsung Galaxy Tab S8 Plus in Grey is a high-performance Android tablet by Samsung. With a large AMOLED display, powerful processor, and S Pen support, i...", 599.99m, 520.13m, 62, "TAB-SAM-SAM-160");
        await EnsureProductAsync(db, shopAlice.Id, tablets.Id, "Samsung Galaxy Tab White", "samsung-galaxy-tab-white",
            "The Samsung Galaxy Tab in White is a sleek and versatile Android tablet. With a vibrant display, long-lasting battery, and a range of features, it offers a g...", 349.99m, 286.29m, 92, "TAB-SAM-SAM-161");
        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "Amazon Echo Plus", "amazon-echo-plus",
            "The Amazon Echo Plus is a smart speaker with built-in Alexa voice control. It features premium sound quality and serves as a hub for controlling smart home d...", 99.99m, 87.92m, 61, "MOB-AMA-AMA-099");
        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "Apple Airpods", "apple-airpods",
            "The Apple Airpods offer a seamless wireless audio experience. With easy pairing, high-quality sound, and Siri integration, they are perfect for on-the-go lis...", 129.99m, 109.79m, 67, "MOB-APP-APP-100");
        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "Apple AirPods Max Silver", "apple-airpods-max-silver",
            "The Apple AirPods Max in Silver are premium over-ear headphones with high-fidelity audio, adaptive EQ, and active noise cancellation. Experience immersive so...", 549.99m, 474.81m, 59, "MOB-APP-APP-101");
        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "Apple Airpower Wireless Charger", "apple-airpower-wireless-charger",
            "The Apple AirPower Wireless Charger provides a convenient way to charge your compatible Apple devices wirelessly. Simply place your devices on the charging m...", 79.99m, 76.41m, 1, "MOB-APP-APP-102");
        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "Apple HomePod Mini Cosmic Grey", "apple-homepod-mini-cosmic-grey",
            "The Apple HomePod Mini in Cosmic Grey is a compact smart speaker that delivers impressive audio and integrates seamlessly with the Apple ecosystem for a smar...", 99.99m, 81.89m, 27, "MOB-APP-APP-103");
        await EnsureProductAsync(db, shopBob.Id, accessories.Id, "Apple iPhone Charger", "apple-iphone-charger",
            "The Apple iPhone Charger is a high-quality charger designed for fast and efficient charging of your iPhone. Ensure your device stays powered up and ready to go.", 19.99m, 16.29m, 31, "MOB-APP-APP-104");

        await db.SaveChangesAsync();
        Console.WriteLine("[seed] demo data created: 5 categories, 2 shops, 20 products.");
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
            Url = $"http://localhost:5000/uploads/{slug}.jpg",
            AltText = name,
            IsPrimary = true,
            DisplayOrder = 0
        });
        db.Products.Add(product);
    }
}
