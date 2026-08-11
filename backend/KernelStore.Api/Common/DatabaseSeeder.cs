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
        if (await db.Products.AnyAsync(p => p.Slug == "github-copilot-1-year"))
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
        // IT-specialization categories (top-level so they surface as their own
        // storefront sections): IoT, AI/ML, Security, SysAdmin, Developer.
        var iot = await EnsureCategoryAsync(db, "IoT & Embedded", "iot", null);
        var aiml = await EnsureCategoryAsync(db, "AI & Machine Learning", "ai-ml", null);
        var security = await EnsureCategoryAsync(db, "Cybersecurity", "security", null);
        var sysadmin = await EnsureCategoryAsync(db, "SysAdmin & DevOps", "sysadmin", null);
        var developer = await EnsureCategoryAsync(db, "Developer Tools", "developer", null);
        await db.SaveChangesAsync();

        // ── Sellers + approved shops ───────────────────────────────────────
        var alice = await CreateSellerAsync(userManager, markerEmail, "demo_alice", "Alice Nguyen");
        var bob = await CreateSellerAsync(userManager, "seller2@demo.ks", "demo_bob", "Bob Tran");

        var shopAlice = await EnsureShopAsync(db, alice.Id, "TechWorld Store", "techworld-store",
            "Authentic laptops, smartphones and tablets from top brands.");
        var shopBob = await EnsureShopAsync(db, bob.Id, "GadgetHub", "gadgethub",
            "Audio, smart speakers, chargers and mobile accessories.");

        // Specialist tech shops — one storefront per IT domain.
        var carol = await CreateSellerAsync(userManager, "iot@demo.ks", "demo_iot", "Carol Pham");
        var david = await CreateSellerAsync(userManager, "ai@demo.ks", "demo_ai", "David Le");
        var emma = await CreateSellerAsync(userManager, "security@demo.ks", "demo_sec", "Emma Vo");
        var frank = await CreateSellerAsync(userManager, "sysadmin@demo.ks", "demo_ops", "Frank Do");
        var grace = await CreateSellerAsync(userManager, "developer@demo.ks", "demo_dev", "Grace Ha");

        var shopIot = await EnsureShopAsync(db, carol.Id, "IoT Depot", "iot-depot",
            "Single-board computers, microcontrollers, sensors and gateways for makers and embedded engineers.");
        var shopAi = await EnsureShopAsync(db, david.Id, "Neural Forge", "neural-forge",
            "GPUs, edge accelerators and workstations built for training and deploying AI models.");
        var shopSec = await EnsureShopAsync(db, emma.Id, "SecOps Armory", "secops-armory",
            "Hardware keys, pentest gadgets and security tooling for red and blue teams.");
        var shopOps = await EnsureShopAsync(db, frank.Id, "OpsCenter", "opscenter",
            "Networking, rackmount servers, NAS and power gear to run reliable infrastructure.");
        var shopDev = await EnsureShopAsync(db, grace.Id, "DevTools Hub", "devtools-hub",
            "Keyboards, monitors, docks and software licenses that power a developer's workflow.");
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

        // ── IoT & Embedded — IoT Depot ─────────────────────────────────────
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "Raspberry Pi 5 8GB", "raspberry-pi-5-8gb",
            "The Raspberry Pi 5 with 8GB RAM is a credit-card sized computer powered by a quad-core Cortex-A76 CPU. Ideal for edge computing, home labs and IoT gateways.", 89.99m, 82.99m, 120, "IOT-RPI-RP5-201");
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "ESP32 DevKit V1", "esp32-devkit-v1",
            "The ESP32 DevKit V1 is a low-cost Wi-Fi + Bluetooth microcontroller board, perfect for connected sensors, home automation and battery-powered IoT nodes.", 12.99m, 9.99m, 300, "IOT-ESP-E32-202");
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "Arduino Uno R4 WiFi", "arduino-uno-r4-wifi",
            "The Arduino Uno R4 WiFi pairs a 32-bit Renesas MCU with an ESP32-S3 radio and a built-in LED matrix — a friendly board for learning embedded and IoT.", 27.99m, 24.50m, 180, "IOT-ARD-R4W-203");
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "Raspberry Pi Pico W", "raspberry-pi-pico-w",
            "The Raspberry Pi Pico W is a tiny, ultra-affordable RP2040 microcontroller board with wireless connectivity for compact embedded projects.", 6.99m, null, 500, "IOT-RPI-PCW-204");
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "LoRa Gateway 8-Channel", "lora-gateway-8-channel",
            "An 8-channel LoRaWAN gateway that bridges long-range, low-power sensor networks to the internet — the backbone of city-scale and agricultural IoT.", 159.99m, 139.99m, 45, "IOT-LOR-8CH-205");
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "Zigbee Smart Hub", "zigbee-smart-hub",
            "A Zigbee 3.0 smart home hub that locally controls lights, sensors and switches with low latency and no cloud dependency.", 49.99m, 42.99m, 90, "IOT-ZIG-HUB-206");
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "DHT22 Sensor Kit", "dht22-sensor-kit",
            "A DHT22 temperature and humidity sensor kit with jumper wires and resistors — a classic starting point for environmental monitoring builds.", 14.99m, 11.99m, 240, "IOT-DHT-K22-207");
        await EnsureProductAsync(db, shopIot.Id, iot.Id, "mmWave Radar Sensor", "mmwave-radar-sensor",
            "A 60GHz mmWave presence-detection radar module that senses micro-movements for reliable room occupancy and fall detection in smart spaces.", 19.99m, null, 160, "IOT-MMW-RAD-208");

        // ── AI & Machine Learning — Neural Forge ───────────────────────────
        await EnsureProductAsync(db, shopAi.Id, aiml.Id, "NVIDIA RTX 4090 24GB", "nvidia-rtx-4090-24gb",
            "The NVIDIA RTX 4090 with 24GB GDDR6X delivers massive throughput for training and fine-tuning deep learning models, plus blistering local inference.", 1799.99m, 1699.99m, 20, "AI-NVD-4090-301");
        await EnsureProductAsync(db, shopAi.Id, aiml.Id, "NVIDIA Jetson Orin Nano", "nvidia-jetson-orin-nano",
            "The Jetson Orin Nano developer kit brings up to 40 TOPS of AI performance to the edge, running modern vision and robotics models in a tiny footprint.", 499.99m, 469.99m, 55, "AI-NVD-ORN-302");
        await EnsureProductAsync(db, shopAi.Id, aiml.Id, "Google Coral USB Accelerator", "google-coral-usb-accelerator",
            "The Coral USB Accelerator adds an Edge TPU coprocessor over USB-C, running TensorFlow Lite models fast and efficiently on any host machine.", 59.99m, 54.99m, 130, "AI-GOO-COR-303");
        await EnsureProductAsync(db, shopAi.Id, aiml.Id, "Hailo-8 AI Accelerator", "hailo-8-ai-accelerator",
            "The Hailo-8 M.2 module delivers up to 26 TOPS at remarkable power efficiency, ideal for embedding real-time neural inference into edge products.", 219.99m, null, 40, "AI-HAI-H8A-304");
        await EnsureProductAsync(db, shopAi.Id, aiml.Id, "Intel Neural Compute Stick 2", "intel-neural-compute-stick-2",
            "The Intel Neural Compute Stick 2 is a plug-and-play USB accelerator powered by the Movidius Myriad X VPU for prototyping deep-learning inference.", 99.99m, 84.99m, 70, "AI-INT-NCS-305");
        await EnsureProductAsync(db, shopAi.Id, aiml.Id, "AI Workstation Threadripper", "ai-workstation-threadripper",
            "A pre-built AI workstation with an AMD Threadripper CPU, 128GB RAM and dual GPUs — ready for serious model training straight out of the box.", 4999.99m, 4699.99m, 8, "AI-WKS-TRX-306");
        await EnsureProductAsync(db, shopAi.Id, aiml.Id, "NVIDIA A100 80GB Tensor Core", "nvidia-a100-80gb",
            "The NVIDIA A100 80GB is a data-center GPU engineered for large-scale training and high-throughput inference across demanding AI and HPC workloads.", 15999.99m, null, 5, "AI-NVD-A100-307");

        // ── Cybersecurity — SecOps Armory ──────────────────────────────────
        await EnsureProductAsync(db, shopSec.Id, security.Id, "YubiKey 5 NFC", "yubikey-5-nfc",
            "The YubiKey 5 NFC is a hardware security key supporting FIDO2, U2F, OTP and smart-card protocols for phishing-resistant multi-factor authentication.", 55.00m, 49.00m, 200, "SEC-YUB-5NF-401");
        await EnsureProductAsync(db, shopSec.Id, security.Id, "Flipper Zero", "flipper-zero",
            "The Flipper Zero is a portable multi-tool for pentesters and hardware hackers — sub-GHz radio, RFID/NFC, infrared and GPIO in a pocket device.", 169.99m, 159.99m, 60, "SEC-FLP-ZRO-402");
        await EnsureProductAsync(db, shopSec.Id, security.Id, "Hak5 WiFi Pineapple", "hak5-wifi-pineapple",
            "The Hak5 WiFi Pineapple is a purpose-built platform for authorized wireless auditing and rogue-AP assessments during red-team engagements.", 119.99m, null, 35, "SEC-HAK-WPA-403");
        await EnsureProductAsync(db, shopSec.Id, security.Id, "Proxmark3 RDV4", "proxmark3-rdv4",
            "The Proxmark3 RDV4 is the reference tool for RFID research, reading, emulating and analyzing LF and HF contactless cards and tags.", 299.99m, 279.99m, 25, "SEC-PXM-RV4-404");
        await EnsureProductAsync(db, shopSec.Id, security.Id, "USB Rubber Ducky", "usb-rubber-ducky",
            "The USB Rubber Ducky is a keystroke-injection tool that a target sees as a keyboard — a staple for demonstrating HID attack payloads in labs.", 79.99m, 69.99m, 80, "SEC-HAK-DUK-405");
        await EnsureProductAsync(db, shopSec.Id, security.Id, "Nitrokey HSM 2", "nitrokey-hsm-2",
            "The Nitrokey HSM 2 is an open-source hardware security module that securely generates and stores cryptographic keys for PKI and code signing.", 109.00m, null, 50, "SEC-NTK-HS2-406");
        await EnsureProductAsync(db, shopSec.Id, security.Id, "Faraday Signal-Blocking Bag", "faraday-signal-blocking-bag",
            "A Faraday bag that blocks cellular, Wi-Fi, GPS and RFID signals to preserve digital evidence and protect devices from remote wiping or tracking.", 29.99m, 24.99m, 150, "SEC-FRD-BAG-407");

        // ── SysAdmin & DevOps — OpsCenter ──────────────────────────────────
        await EnsureProductAsync(db, shopOps.Id, sysadmin.Id, "Ubiquiti UniFi Dream Machine", "ubiquiti-unifi-dream-machine",
            "The UniFi Dream Machine combines a security gateway, controller, switch and access point into one appliance for clean, manageable networks.", 379.99m, 349.99m, 40, "OPS-UBI-UDM-501");
        await EnsureProductAsync(db, shopOps.Id, sysadmin.Id, "24-Port Managed Switch", "24-port-managed-switch",
            "A 24-port gigabit managed switch with VLANs, LACP and PoE budget — the workhorse of a well-segmented server rack.", 219.99m, 199.99m, 55, "OPS-NET-24S-502");
        await EnsureProductAsync(db, shopOps.Id, sysadmin.Id, "1U Rackmount Server", "1u-rackmount-server",
            "A 1U rackmount server with a Xeon CPU, ECC memory and redundant PSUs — dense, reliable compute for virtualization and self-hosting.", 1299.99m, 1199.99m, 18, "OPS-SRV-1U-503");
        await EnsureProductAsync(db, shopOps.Id, sysadmin.Id, "Synology 4-Bay NAS", "synology-4-bay-nas",
            "The Synology 4-Bay NAS delivers centralized storage, backups and Docker services with a polished DSM interface for homelabs and small teams.", 449.99m, 419.99m, 30, "OPS-SYN-4BN-504");
        await EnsureProductAsync(db, shopOps.Id, sysadmin.Id, "KVM over IP Switch", "kvm-over-ip-switch",
            "A KVM-over-IP switch that gives BIOS-level remote keyboard, video and mouse access to headless servers from anywhere.", 189.99m, null, 42, "OPS-KVM-IP-505");
        await EnsureProductAsync(db, shopOps.Id, sysadmin.Id, "UPS 1500VA Rackmount", "ups-1500va-rackmount",
            "A 1500VA line-interactive rackmount UPS with pure sine-wave output and network monitoring to keep infrastructure alive through outages.", 279.99m, 249.99m, 36, "OPS-UPS-15R-506");
        await EnsureProductAsync(db, shopOps.Id, sysadmin.Id, "Managed PDU Rack Strip", "managed-pdu-rack-strip",
            "A managed rack PDU with per-outlet metering and remote switching, so you can power-cycle any device in the rack over the network.", 159.99m, 144.99m, 48, "OPS-PDU-RCK-507");

        // ── Developer Tools — DevTools Hub ─────────────────────────────────
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "Keychron Q1 Mechanical Keyboard", "keychron-q1-mechanical-keyboard",
            "The Keychron Q1 is a gasket-mounted, hot-swappable mechanical keyboard with a CNC aluminum body — a favorite for long coding sessions.", 179.99m, 164.99m, 90, "DEV-KEY-Q1M-601");
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "4K Dev Monitor 27-inch", "dev-monitor-4k-27",
            "A 27-inch 4K IPS monitor with USB-C power delivery and factory color calibration — crisp text and plenty of room for code and terminals.", 399.99m, 359.99m, 60, "DEV-MON-4K27-602");
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "USB-C Docking Station", "usb-c-docking-station",
            "A single-cable USB-C dock that adds dual displays, gigabit Ethernet, USB-A ports and 100W passthrough charging to any laptop.", 129.99m, 114.99m, 110, "DEV-DOK-USC-603");
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "Elgato Stream Deck MK.2", "elgato-stream-deck-mk2",
            "The Elgato Stream Deck MK.2 gives you 15 programmable LCD keys to trigger builds, run scripts and control your dev workflow at a tap.", 149.99m, 139.99m, 75, "DEV-ELG-SD2-604");
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "Ergonomic Vertical Mouse", "ergonomic-vertical-mouse",
            "An ergonomic vertical mouse that keeps your wrist in a natural handshake position to reduce strain during all-day work.", 39.99m, 34.99m, 200, "DEV-MOU-VRT-605");
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "Aluminum Laptop Stand", "aluminum-laptop-stand",
            "A sturdy aluminum laptop stand that raises your screen to eye level and improves airflow, keeping thermals and posture in check.", 34.99m, 29.99m, 180, "DEV-STD-ALU-606");
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "JetBrains All Products Pack", "jetbrains-all-products-pack",
            "A one-year individual license for the JetBrains All Products Pack — IntelliJ IDEA, PyCharm, WebStorm, Rider and every other JetBrains IDE.", 289.00m, null, 999, "DEV-JBR-APP-607");
        await EnsureProductAsync(db, shopDev.Id, developer.Id, "GitHub Copilot 1-Year", "github-copilot-1-year",
            "A one-year GitHub Copilot subscription — AI pair-programming that suggests whole lines and functions right inside your editor.", 100.00m, null, 999, "DEV-GHC-1YR-608");

        await db.SaveChangesAsync();
        Console.WriteLine("[seed] demo data created: 10 categories, 7 shops, 57 products.");
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
        string description, decimal price, decimal? salePrice, int stock, string sku,
        string imageExt = "jpg", int warrantyMonths = 12)
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
            WarrantyMonths = warrantyMonths,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            ShopId = shopId,
            CategoryId = categoryId
        };
        product.Images.Add(new ProductImage
        {
            Id = Guid.NewGuid(),
            Url = $"http://localhost:5000/uploads/{slug}.{imageExt}",
            AltText = name,
            IsPrimary = true,
            DisplayOrder = 0
        });
        db.Products.Add(product);
    }
}
