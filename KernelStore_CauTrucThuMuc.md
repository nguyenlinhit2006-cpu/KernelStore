# KernelStore — Cấu trúc thư mục & File

> Đề tài: Sàn thương mại điện tử công nghệ đa nhà cung cấp
> Sinh viên: Nguyễn Huệ Thùy Linh · D24CNA12149 · Lớp D24CN03

---

## 📁 Cấu trúc tổng quan

```
KernelStore/
├── backend/                    ← Tầng Backend (ASP.NET Core 10 API)
│   └── KernelStore.Api/
│       ├── Controllers/        → API endpoint (Auth, Shops, Products, Orders, Chat...)
│       ├── Services/           → Logic nghiệp vụ tái sử dụng (Token, Chat WS)
│       ├── Entities/           → Model/Entity (User, Shop, Product, Order, Chat...)
│       ├── Data/               → EF Core DbContext
│       ├── Contracts/          → DTO (Auth, Shop, Product, Cart, Order, Review, Admin, Chat)
│       ├── Common/             → Tiện ích (ApiResponse, DatabaseSeeder, ChatEndpoints)
│       ├── Migrations/         → EF Core migrations (InitialCreate, AddChat...)
│       ├── wwwroot/uploads/    → Ảnh sản phẩm upload (static file)
│       ├── appsettings.json    → Cấu hình app (DB, JWT, CORS)
│       └── Program.cs          → Entry point khởi động backend
│
├── frontend/                   ← Tầng Frontend (Rust + Leptos WASM)
│   ├── Cargo.toml              → Dependencies Rust
│   ├── index.html              → Entry HTML (Trunk inject WASM)
│   ├── Trunk.toml              → Cấu hình build tool Trunk
│   ├── tailwind.config.js      → Cấu hình Tailwind CSS
│   └── src/
│       ├── main.rs             → Entry point app (router, context)
│       ├── app.rs              → Component gốc App
│       ├── api.rs              → Client gọi API (tất cả request đến :5000)
│       ├── auth.rs             → AuthContext (JWT session từ localStorage)
│       ├── types.rs            → Struct dữ liệu (Product, Order, User...)
│       ├── pages/              → Các trang (home, products, cart, seller, admin, chat...)
│       └── components/         → Component tái sử dụng (input, loading, error, toast, header)
│
├── docker-compose.yml          ← PostgreSQL 16 container (port 5433)
├── shell.nix                   ← Môi trường dev NixOS (auto cài toolchain)
├── run.sh                      ← Script chạy toàn bộ stack (1 lệnh)
├── seed.sh                     ← Seed dữ liệu mẫu (categories, shops, products)
├── win-run-all.bat             ← Windows: mở backend + frontend (2 cửa sổ)
├── win-db.bat                  ← Windows: chạy Docker DB
├── win-backend.bat             ← Windows: chạy backend
├── win-frontend.bat            ← Windows: chạy frontend
├── win-seed.bat                ← Windows: seed dữ liệu
├── test_phase1_api.sh          → Test Auth (21 checks)
├── test_phase2_api.sh          → Test Shop & Seller (14 checks)
├── test_phase3_api.sh          → Test Product & Category (27 checks)
├── test_phase4_api.sh          → Test Cart & Order (22 checks)
├── test_phase5_api.sh          → Test Review (15 checks)
├── test_phase6_api.sh          → Test Admin Panel (32 checks)
├── test_chat_api.sh            → Test Chat realtime REST + WS (27 checks)
├── test_full_api.sh            → Smoke test E2E toàn luồng (52 checks)
├── test_extra_api.sh           → Test nâng cao (upload, ban, return...) (66 checks)
├── test/
│   └── wsclient/               → Project C# probe test WebSocket
├── README.md                   → Hướng dẫn chính (NixOS)
└── README-Windows.md           → Hướng dẫn chạy trên Windows
```

---

## 🔧 1. BACKEND (`backend/KernelStore.Api/`)

### Controllers/ — API Endpoints
| File | Chức năng |
|------|-----------|
| `AuthController.cs` | Đăng ký, đăng nhập, refresh token, lấy thông tin /me |
| `ShopsController.cs` | Seller: mở shop, xem/sửa shop của mình |
| `AdminShopsController.cs` | Admin: duyệt/từ chối/ban shop |
| `ProductsController.cs` | Seller: CRUD sản phẩm (chỉ của shop mình) |
| `CategoriesController.cs` | Admin: CRUD danh mục toàn sàn |
| `CartController.cs` | Customer: giỏ hàng (get/add/update/delete) |
| `OrdersController.cs` | Đơn hàng: tạo, lịch sử, đổi status |
| `ReviewsController.cs` | Đánh giá: chỉ khi đã nhận hàng |
| `AdminDashboardController.cs` | Thống kê toàn hệ thống |
| `AdminUsersController.cs` | Admin: quản lý ngưới dùng (ban/unban) |
| `AdminOrdersController.cs` | Admin: xem tất cả đơn hệ thống |
| `ChatController.cs` | REST API chat (mở hội thoại, gửi/lấy tin nhắn) |

### Services/ — Logic tái sử dụng
| File | Chức năng |
|------|-----------|
| `TokenService.cs` | Tạo/validate JWT + refresh token (rotation, single-use) |
| `ChatConnectionManager.cs` | Quản lý kết nối WebSocket realtime (Singleton, theo dõi userId, đa tab) |

### Entities/ — Model DB (11 entities)
| File | Mô tả |
|------|-------|
| `ApplicationUser.cs` | Ngưới dùng (kế thừa IdentityUser) |
| `Shop.cs` | Gian hàng |
| `Category.cs` | Danh mục (cây cha-con) |
| `Product.cs` | Sản phẩm |
| `ProductImage.cs` | Ảnh sản phẩm (gallery) |
| `Order.cs` / `OrderDetail.cs` | Đơn hàng & chi tiết đơn |
| `Review.cs` | Đánh giá |
| `WarrantyClaim.cs` | Yêu cầu bảo hành |
| `Conversation.cs` | Hội thoại chat (unique index BuyerId+ShopId) |
| `ChatMessage.cs` | Tin nhắn trong hội thoại |
| `RefreshToken.cs` | Token làm mới (IsUsed, single-use) |

### Data/
| File | Chức năng |
|------|-----------|
| `ApplicationDbContext.cs` | DbContext EF Core: định nghĩa relationships, indexes, constraints |

### Contracts/ — DTO (Data Transfer Object)
| Thư mục | Nội dung |
|---------|----------|
| `Auth/` | RegisterRequest, LoginRequest, AuthResponse... |
| `Shops/` | ShopDto, ShopCreateRequest... |
| `Products/` | ProductDto, ProductCreateRequest... |
| `Categories/` | CategoryDto, CategoryTreeItem... |
| `Cart/` | CartItemDto, CartResponse... |
| `Orders/` | OrderDto, OrderCreateRequest, OrderStatusUpdateRequest... |
| `Reviews/` | ReviewDto, ReviewCreateRequest... |
| `Admin/` | AdminDashboardDto, AdminUserDto... |
| `Chat/` | ConversationDto, ChatMessageDto... |

### Common/
| File | Chức năng |
|------|-----------|
| `ApiResponse.cs` | Wrapper response chuẩn `{success, data, message, errors}` |
| `DatabaseSeeder.cs` | Tạo dữ liệu mẫu (roles, admin, categories, shops, products) — idempotent |
| `ChatEndpoints.cs` | Cấu hình endpoint WebSocket `/ws/chat` |

### Migrations/
| Migration | Mô tả |
|-----------|-------|
| `InitialCreate` | Tạo schema bảng ban đầu |
| `MakeProductCategoryNullable` | Cho phép Product không thuộc Category |
| `AddChat` | Thêm bảng Conversation + ChatMessage |

### Các file cấu hình
| File | Chức năng |
|------|-----------|
| `appsettings.json` | Connection string (PostgreSQL port 5433), JWT secret, CORS origins |
| `Program.cs` | Khởi động app: đăng ký services, middleware, routes, seeder |
| `wwwroot/uploads/` | Thư mục lưu ảnh sản phẩm upload, phục vụ static file tại `/uploads/` |

---

## 🎨 2. FRONTEND (`frontend/src/`)

### File gốc
| File | Chức năng |
|------|-----------|
| `main.rs` | Entry point: mount router, cung cấp ToastContext |
| `app.rs` | Component App: định nghĩa routing, layout chung |
| `api.rs` | Client gọi API: tất cả HTTP request đến `localhost:5000` |
| `auth.rs` | AuthContext: quản lý session JWT từ localStorage, login/logout |
| `types.rs` | Định nghĩa struct dữ liệu: Product, Order, User, Review... |

### pages/ — Các trang (route)
| File | Route | Vai trò | Chức năng |
|------|-------|---------|-----------|
| `home.rs` | `/` | Public | Hero + Featured Products + Categories |
| `products.rs` | `/products` | Public | Danh sách: filter, sort, pagination, query string |
| `product_detail.rs` | `/products/:slug` | Public | Gallery, giá, review, add-to-cart, chat seller |
| `login.rs` | `/auth/login` | Public | Đăng nhập style terminal |
| `register.rs` | `/auth/register` | Public | Đăng ký |
| `cart.rs` | `/cart` | Customer | Bảng ASCII, stepper, tạm tính |
| `checkout.rs` | `/checkout` | Customer | Form địa chỉ, order summary, đặt hàng |
| `orders.rs` | `/orders` | Customer/Seller/Admin | Lịch sử đơn (phân quyền theo role) |
| `order_detail.rs` | `/orders/:id` | Customer/Seller/Admin | Chi tiết đơn + đổi status (Seller/Admin) |
| `seller.rs` | `/seller` | Seller | Dashboard: tabs (dashboard/products/sales/categories/settings) |
| `admin.rs` | `/admin` | Admin | Control panel: tabs (dashboard/shops/categories) |
| `chat.rs` | `/chat` | Customer/Seller | Chat realtime: sidebar + thread + WebSocket |
| `warranty.rs` | `/warranty` | Customer | Gửi & theo dõi yêu cầu bảo hành |

### components/ — Component tái sử dụng
| File | Chức năng |
|------|-----------|
| `input.rs` | Input field style terminal |
| `loading.rs` | Loading typewriter effect (gõ chữ char-by-char, block caret nhấp nháy) |
| `error.rs` | KernelPanic: màn hình lỗi 404/500 kiểu Linux kernel panic |
| `toast.rs` | Toast notification dạng log terminal `[INFO]/[WARN]/[ERROR]/[OK]` |
| `header.rs` | Thanh điều hướng: brand, user/role, link chat/cart/orders |

### File cấu hình build
| File | Chức năng |
|------|-----------|
| `Cargo.toml` | Dependencies Rust: leptos, wasm-bindgen, reqwasm, serde... |
| `index.html` | Entry HTML, Trunk tự động inject WASM bundle |
| `Trunk.toml` | Cấu hình Trunk: build target, port, watch... |
| `tailwind.config.js` | Cấu hình Tailwind CSS: theme, colors, font... |

---

## 🧪 3. TEST

### Shell scripts (curl + jq)
| File | Phạm vi | Checks |
|------|---------|--------|
| `test_phase1_api.sh` | Auth: register/login/refresh/RBAC | 21 |
| `test_phase2_api.sh` | Shop & Seller: mở shop/duyệt/phân quyền | 14 |
| `test_phase3_api.sh` | Product & Category: CRUD, filter, pagination | 27 |
| `test_phase4_api.sh` | Cart & Order: add/update, stock, checkout | 22 |
| `test_phase5_api.sh` | Review: chỉ khi Delivered, chống trùng | 15 |
| `test_phase6_api.sh` | Admin: dashboard, ban/unban, category CRUD | 32 |
| `test_chat_api.sh` | Chat realtime: REST + WebSocket 2 chiều | 27 |
| `test_full_api.sh` | Smoke test E2E toàn bộ luồng nghiệp vụ | 52 |
| `test_extra_api.sh` | Upload ảnh, ban tạm/vĩnh viễn, return flow | 66 |

### WebSocket probe
| Thư mục | Chức năng |
|---------|-----------|
| `test/wsclient/` | Project C# nhỏ, được `test_chat_api.sh` tự build để test WebSocket |

---

## 🐳 4. DEVOPS & CẤU HÌNH (Root level)

| File | Chức năng |
|------|-----------|
| `docker-compose.yml` | Chạy PostgreSQL 16 container, map port `5433:5432` |
| `shell.nix` | Môi trường NixOS: auto cài dotnet 10, Rust, wasm32 target, Trunk, Tailwind, Docker, jq, curl |
| `run.sh` | **Một lệnh chạy cả stack**: Docker → Backend → Frontend (foreground) |
| `seed.sh` | Seed dữ liệu mẫu: 10 categories, 7 shops, 57 products — idempotent |
| `win-run-all.bat` | Windows: mở backend + frontend trong 2 cửa sổ CMD |
| `win-db.bat` | Windows: chạy Docker DB |
| `win-backend.bat` | Windows: chạy backend API |
| `win-frontend.bat` | Windows: chạy frontend Trunk |
| `win-seed.bat` | Windows: seed dữ liệu mẫu |
| `README.md` | Hướng dẫn chi tiết chạy trên NixOS |
| `README-Windows.md` | Hướng dẫn chi tiết chạy trên Windows |

---

## 🔄 Sơ đồ tương tác tổng thể

```
┌─────────────────────────────────────────────────────────────┐
│  BROWSER (User)                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │ localhost:8080  │    │ WebSocket       │                │
│  │ (Leptos WASM)   │◄──►│ /ws/chat        │                │
│  └────────┬────────┘    └─────────────────┘                │
└───────────┼─────────────────────────────────────────────────┘
            │ HTTP REST (fetch)
            ▼
┌─────────────────────────────────────────────────────────────┐
│  BACKEND                                                    │
│  localhost:5000                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Controllers │→ │ Services    │→ │ EF Core (DbContext) │ │
│  │ (Auth,      │  │ (Token,     │  │                     │ │
│  │  Products,  │  │  ChatManager)│  │                     │ │
│  │  Orders...) │  └─────────────┘  └──────────┬──────────┘ │
│  └─────────────┘                              │            │
└───────────────────────────────────────────────┼────────────┘
                                                │ SQL
                                                ▼
                                    ┌─────────────────────┐
                                    │ PostgreSQL 16       │
                                    │ (Docker :5433)      │
                                    │ Users/Shops/Products│
                                    │ Orders/Reviews/Chat │
                                    └─────────────────────┘
```

---

## 💡 Tóm tắt ý nghĩa từng tầng

| Tầng | Thư mục/File chính | Vai trò |
|------|-------------------|---------|
| **Presentation** | `frontend/src/pages/` + `components/` | Giao diện ngưới dùng, routing, gọi API |
| **API Gateway** | `backend/Controllers/` | Tiếp nhận request, phân quyền JWT, điều hướng |
| **Business Logic** | `backend/Services/` + logic trong Controllers | Xử lý nghiệp vụ, bảo mật, validation |
| **Data Access** | `backend/Data/` + `Entities/` | EF Core truy cập DB, định nghĩa schema |
| **Database** | PostgreSQL (Docker) | Lưu trữ persistent data |
| **DevOps** | `docker-compose.yml`, `shell.nix`, `*.sh` | Tự động hóa môi trường & triển khai |
| **Testing** | `test_*.sh`, `test/wsclient/` | Kiểm thử tự động API + WebSocket |

---

*Nguyễn Huệ Thùy Linh · D24CNA12149 · Lớp D24CN03*
