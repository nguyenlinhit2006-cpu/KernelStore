# KernelStore

Sàn thương mại điện tử đa nhà cung cấp (Multi-vendor E-commerce Marketplace).

## Tech Stack

- **Frontend:** Rust + Leptos (CSR) + Trunk + Tailwind CSS — `http://localhost:8080`
- **Backend:** ASP.NET Core 10 Web API + EF Core + PostgreSQL 16 — `http://localhost:5000`
- **Database:** PostgreSQL 16 (Docker Compose) — host `localhost:5433` → container `5432`

## Cấu trúc

```
KernelStore/
├── backend/           → ASP.NET 10 Web API
│   └── KernelStore.Api/
│       ├── Controllers/   → Auth, Shops, AdminShops, Products, Categories,
│       │                    Cart, Orders, Reviews, AdminDashboard/Users/Orders, Chat
│       ├── Services/      → TokenService (JWT), ChatConnectionManager (WebSocket)
│       ├── Entities/      → ApplicationUser, Shop, Category, Product, Order, ...
│       ├── Data/          → ApplicationDbContext
│       ├── Contracts/     → DTO (Auth/Shops/Products/Categories/Cart/Orders/Reviews/Admin/Chat)
│       ├── Common/        → ApiResponse, DatabaseSeeder (+ demo data), ChatEndpoints (WS)
│       └── Migrations/
├── frontend/          → Rust + Leptos (Trunk)
│   └── src/
│       ├── api.rs     → API client (auth/shops/products/cart/orders/reviews/admin/chat)
│       ├── auth.rs    → AuthContext (localStorage session)
│       ├── pages/     → home, products, product_detail, login, register,
│       │                cart, checkout, orders, seller, admin, chat
│       └── components/ → input, loading (typewriter), error (kernel panic), toast
├── shell.nix          → dev environment (NixOS)
├── docker-compose.yml
├── run.sh             → NixOS: dựng cả stack DB+backend+frontend (1 lệnh)
├── seed.sh            → seed dữ liệu mẫu (1 lệnh)
├── win-run-all.bat    → Windows: bật DB + mở backend & frontend (2 cửa sổ)
├── win-db.bat / win-backend.bat / win-frontend.bat / win-seed.bat → Windows: từng service
├── test_phase{1,2,3,4,5,6}_api.sh → API tests theo phase (curl + jq)
├── test_chat_api.sh   → Chat realtime tests (REST + WebSocket, 27 checks)
├── test/wsclient/     → C# probe WebSocket (test_chat_api.sh tự build)
├── test_full_api.sh    → smoke test end-to-end mọi vai trò (52 checks)
├── test_extra_api.sh   → các chức năng còn lại (66 checks)
├── README.md          → hướng dẫn chính (NixOS)
└── README-Windows.md  → hướng dẫn chạy trên Windows (+ file .bat)
```

## Chạy nhanh (TL;DR)

Cần **3 thành phần chạy cùng lúc**, đúng thứ tự: **Database → Backend → Frontend**. Thiếu backend là frontend sẽ báo `NetworkError when attempting to fetch resource` khi đăng ký/đăng nhập.

**Cách nhanh nhất — một lệnh:**

```sh
# NixOS/Linux  → dựng cả stack (DB + backend + frontend), Ctrl+C để tắt
nix-shell --run ./run.sh
```

```bat
:: Windows  → double-click win-run-all.bat (mở backend + frontend trong 2 cửa sổ)
win-run-all.bat
```

**Hoặc chạy tay từng terminal:**

```sh
# Terminal 1 — Database (Postgres 16)
docker compose up -d

# Terminal 2 — Backend API  → http://localhost:5000
nix-shell --run "dotnet run --project backend/KernelStore.Api --urls http://localhost:5000"

# Terminal 3 — Frontend       → http://localhost:8080
nix-shell --run "cd frontend && trunk serve --port 8080"
```

Trên Windows, thay 3 lệnh trên bằng: `win-db.bat` → `win-backend.bat` → `win-frontend.bat` (xem [README-Windows.md](./README-Windows.md)).

Mở trình duyệt tại **`http://localhost:8080`**. Đợi backend in ra `Now listening on: http://localhost:5000` **trước khi** thao tác đăng ký/đăng nhập.

> Seed dữ liệu mẫu (tuỳ chọn): dừng backend, chạy `./seed.sh`, rồi bật lại backend.

Chi tiết từng bước + xử lý sự cố ở phần dưới.

---

## Chạy trên NixOS (chi tiết)

Toàn bộ toolchain (dotnet 10, rust + wasm target, trunk, tailwind, docker-compose, postgresql client, jq, curl) đã khai báo trong `shell.nix` — **không cài gì global**, chỉ cần `nix-shell`.

### 0. Yêu cầu hệ thống (một lần, trong `configuration.nix`)

Docker daemon phải bật ở cấp hệ thống (nix-shell chỉ cấp *client* `docker`/`docker-compose`, không chạy daemon):

```nix
# /etc/nixos/configuration.nix
virtualisation.docker.enable = true;
users.users.<bạn>.extraGroups = [ "docker" ];
```

Rồi `sudo nixos-rebuild switch` và đăng nhập lại (để vào group `docker`). Nếu không dùng Docker, xem [Postgres không cần Docker](#postgres-không-dùng-docker) bên dưới.

### 1. Vào dev shell

```sh
cd KernelStore
nix-shell          # tải nixpkgs lần đầu hơi lâu; in ra version dotnet/rust/trunk
```

`shellHook` tự thêm target `wasm32-unknown-unknown` nếu thiếu. **Mọi lệnh bên dưới chạy bên trong `nix-shell`** (hoặc dùng `nix-shell --run "<lệnh>"`).

### 2. Database (PostgreSQL 16)

```sh
docker compose up -d          # postgres:16 tại localhost:5433 (db/user/pass: kernelstore/admin/admin123)
docker compose ps             # kiểm tra healthy
```

### 3. Backend (ASP.NET Core 10 API)

```sh
dotnet run --project backend/KernelStore.Api --urls http://localhost:5000
```

- Khi start, seeder tự `Migrate` DB + tạo roles `Customer/Seller/Admin` + tài khoản admin.
- Migrations: `InitialCreate` + `MakeProductCategoryNullable` + `AddChat` (chat realtime).

### 4. Seed dữ liệu mẫu (tuỳ chọn, 1 lệnh)

```sh
./seed.sh                      # = dotnet run --project backend/KernelStore.Api seed
```

Tạo **10 danh mục, 7 shop (Approved) + 57 sản phẩm** (kèm ảnh minh hoạ). Idempotent — chạy lại sẽ bổ sung phần còn thiếu / báo `already present`.

Ngoài nhóm điện tử cơ bản (laptop/phone/tablet/phụ kiện), catalog demo còn trải theo các chuyên ngành CNTT:

| Chuyên ngành | Shop | Ví dụ sản phẩm |
|---|---|---|
| IoT & Embedded | IoT Depot | Raspberry Pi 5, ESP32, Arduino R4, LoRa Gateway, Zigbee Hub |
| AI & Machine Learning | Neural Forge | RTX 4090, Jetson Orin, Google Coral, A100 80GB |
| Cybersecurity | SecOps Armory | YubiKey 5, Flipper Zero, WiFi Pineapple, Proxmark3 |
| SysAdmin & DevOps | OpsCenter | UniFi Dream Machine, 1U Server, Synology NAS, UPS rack |
| Developer Tools | DevTools Hub | Keychron Q1, màn 4K, Stream Deck, license JetBrains/Copilot |

> Ảnh sản phẩm nằm ở `backend/KernelStore.Api/wwwroot/uploads/` và phục vụ tại `http://localhost:5000/uploads/<slug>.jpg`. Trang chủ có mục **"Shop by specialization"** dẫn thẳng tới catalog đã lọc theo từng chuyên ngành.

### 5. Frontend (Leptos + Trunk)

Mở terminal thứ 2 (cũng `nix-shell`):

```sh
cd frontend
trunk serve --port 8080        # build WASM + tailwind, hot-reload
```

Mở **`http://localhost:8080`**.

### Chạy lại nhanh (một lệnh)

Thay cho các bước 2–5 ở trên, dùng script `run.sh` để dựng cả stack trong **một terminal**:

```sh
nix-shell --run ./run.sh
```

Script tự: `docker compose up -d` → đợi Postgres healthy → chạy backend nền (log ở `/tmp/kernelstore-backend.log`) → đợi `:5000` phản hồi → chạy frontend foreground. Nhấn **Ctrl+C** để dừng frontend và tự tắt backend (Postgres vẫn chạy; `docker compose down` để tắt hẳn). Seed dữ liệu mẫu vẫn dùng `nix-shell --run ./seed.sh` ở terminal khác khi backend đã sẵn sàng.

### Tài khoản mặc định

| Vai trò   | Email               | Mật khẩu       | Nguồn            |
|-----------|---------------------|----------------|------------------|
| Admin     | `admin@ks.com`      | `Admin@12345`  | seed tự động     |
| Seller    | `seller1@demo.ks`   | `Seller@12345` | `./seed.sh` — TechWorld Store |
| Seller    | `seller2@demo.ks`   | `Seller@12345` | `./seed.sh` — GadgetHub |
| Seller    | `iot@demo.ks`       | `Seller@12345` | `./seed.sh` — IoT Depot |
| Seller    | `ai@demo.ks`        | `Seller@12345` | `./seed.sh` — Neural Forge |
| Seller    | `security@demo.ks`  | `Seller@12345` | `./seed.sh` — SecOps Armory |
| Seller    | `sysadmin@demo.ks`  | `Seller@12345` | `./seed.sh` — OpsCenter |
| Seller    | `developer@demo.ks` | `Seller@12345` | `./seed.sh` — DevTools Hub |
| Customer  | tự đăng ký ở `/auth/register` | —    | —                |

### Chạy test (API còn sống trên :5000)

```sh
nix-shell --run ./test_phase1_api.sh     # Auth               (21 checks)
nix-shell --run ./test_phase2_api.sh     # Shop & Seller      (14 checks)
nix-shell --run ./test_phase3_api.sh     # Product & Category (27 checks)
nix-shell --run ./test_phase4_api.sh     # Cart & Checkout   (22 checks)
nix-shell --run ./test_phase5_api.sh     # Review & Rating   (15 checks)
nix-shell --run ./test_phase6_api.sh     # Admin Panel       (32 checks)
nix-shell --run ./test_chat_api.sh       # Chat realtime     (27 checks, tự build wsclient)
nix-shell --run ./test_full_api.sh       # End-to-end mọi vai trò (52 checks)
nix-shell --run ./test_extra_api.sh      # Các chức năng còn lại  (66 checks)
```

### Kết quả test gần nhất (2026-08-09)

Toàn bộ chức năng hiện có đã được chạy lại (Postgres + backend `:5000`) và đều PASS — **276/276 checks trên 9 bộ test**:

| Bộ test | Kết quả | Phạm vi |
|---------|---------|---------|
| `test_phase1_api.sh` | ✅ 21/21 PASS | Auth: register/login/sai mật khẩu→401/me/refresh + rotation (reuse→401), RBAC token |
| `test_phase2_api.sh` | ✅ 14/14 PASS | Shop & Seller: mở shop→Pending→admin approve→Approved, cập nhật shop, phân quyền |
| `test_phase3_api.sh` | ✅ 27/27 PASS | Product & Category: CRUD, cross-seller 404, phân trang, ẩn sản phẩm inactive |
| `test_phase4_api.sh` | ✅ 22/22 PASS | Cart & Checkout: add/update, vượt stock→lỗi, tạo đơn trừ stock, seller đổi status |
| `test_phase5_api.sh` | ✅ 15/15 PASS | Review: chưa nhận hàng→403, mua→ship→confirm→Delivered mới review, average, chống trùng |
| `test_phase6_api.sh` | ✅ 32/32 PASS | Admin: dashboard (8 bucket status), ban/unban user, category CRUD + chặn xóa có con |
| `test_full_api.sh` | ✅ 52/52 PASS | AUTH, browse công khai (categories/products/detail/featured/reviews/404), CART, ORDER (tạo/lịch sử/cancel), SELLER (shop→pending→approve, products CRUD, dashboard doanh thu, sales), ADMIN (duyệt shop, dashboard), vòng đời buy→Shipped→confirm→Delivered→review, RBAC/security |
| `test_chat_api.sh` | ✅ 27/27 PASS | Auth 401 (REST+WS), mở hội thoại/idempotent/chặn shop mình/404, message rỗng/>2000→400, non-participant→403, unread, **realtime WS** push 2 chiều |
| `test_extra_api.sh` | ✅ 66/66 PASS | Category CRUD (tạo con/đổi tên/chặn xóa gốc có con/404), shop settings + slug conflict, **Customer→Seller** (register Customer → mở shop nâng role Seller sau refresh → Pending → approve → Approved), **guard sản phẩm** (Pending/Banned không tạo/sửa được → 400; Approved tạo được), **ban tạm thời** (Banned → sản phẩm ẩn public 404/0, isActive=false; unban → hiện lại), **ban vĩnh viễn** (xóa cứng không đơn / xóa mềm `Deleted` có đơn + giữ lịch sử đơn + tên sản phẩm), admin user ban/unban (+ ban tự thân→400, bị ban→login 401), order cancel khôi phục stock, return flow (ship→confirm→ReturnRequested→approve→Returned), product delete, refresh-token rotation (reuse→401), **upload ảnh sản phẩm** (jpg/png/svg: thiếu auth→401, sai định dạng→400, upload→URL, file phục vụ 200 + header nosniff, seller tạo/sửa gắn ảnh → buyer thấy ảnh đúng) |

> Lần verify này đã đồng bộ 2 bộ test phase cũ với hành vi backend hiện tại (không phải lỗi chức năng): `test_phase5_api.sh` — hàm `buy()` giờ đẩy đơn qua Confirmed→Processing→Shipped rồi `confirm-received`→Delivered vì review chỉ được phép sau khi khách đã nhận hàng; `test_phase6_api.sh` — dashboard trả **8 bucket** trạng thái đơn (enum `OrderStatus` đã thêm `Cancelled`/`ReturnRequested`/`Returned` từ luồng cancel/return), sửa assertion 6→8.

> Ghi chú lịch sử (lần verify trước): đã phát hiện + sửa 1 lỗ hổng — seller có shop **Pending/Banned vẫn tạo/sửa được sản phẩm** (guard `GetOwnShopIdAsync` không check trạng thái shop). Đã thêm check `shop.Status == Approved` cho `Create`/`Update`/`Delete` sản phẩm (`ProductsController.cs`); `GET /products/my` giữ nguyên để seller vẫn xem được sản phẩm của mình (kể cả khi bị ban).

> Ghi chú: các test UI qua Selenium (`test_*_ui.py`) và test Python khác nêu ở mục [Test](#test) nằm ngoài repo này (chạy môi trường có browser automation), nên không được chạy lại trong lần verify này.

### Build một lần (không chạy dev server)

```sh
dotnet build backend/KernelStore.Api                       # backend
nix-shell --run "cd frontend && trunk build"               # frontend → frontend/dist/
```

### Xử lý sự cố (NixOS)

- **`NetworkError when attempting to fetch resource` khi đăng ký/đăng nhập** → **backend chưa chạy** (hoặc không nghe ở `http://localhost:5000`). Frontend gọi API tại `localhost:5000`; nếu không có gì lắng nghe, trình duyệt báo NetworkError. Bật Terminal 2 (`dotnet run ... --urls http://localhost:5000`) và đợi log `Now listening on: http://localhost:5000`. Kiểm tra nhanh: `curl http://localhost:5000/api/categories` phải trả JSON (không phải `Connection refused`).
- **`linker 'cc' not found` khi build frontend** → bạn đang chạy `cargo`/`trunk` *ngoài* `nix-shell`. Vào `nix-shell` trước (stdenv cấp trình biên dịch C cho build-script proc-macro).
- **`Cannot connect to the Docker daemon`** → chưa bật `virtualisation.docker.enable` hoặc chưa vào group `docker` (đăng xuất/đăng nhập lại).
- **`wasm32-unknown-unknown` không có** → thoát và vào lại `nix-shell` (shellHook tự `rustup target add`), hoặc chạy tay `rustup target add wasm32-unknown-unknown`.
- **Backend không nối được DB** → kiểm tra `docker compose ps` (postgres healthy) và connection string trong `backend/KernelStore.Api/appsettings.json` (`Host=localhost;Port=5433;...`).
- **CORS bị chặn** → frontend phải chạy đúng `http://localhost:8080` (khai báo trong `Cors:AllowedOrigins`).

### Postgres không dùng Docker

`shell.nix` có sẵn `postgresql_16`. Có thể chạy Postgres cục bộ thay cho Docker:

```sh
initdb -D .pgdata
pg_ctl -D .pgdata -o "-p 5433" -l .pgdata/log start
createuser -p 5433 -s admin
psql -p 5433 -d postgres -c "ALTER USER admin PASSWORD 'admin123';"
createdb -p 5433 -O admin kernelstore
```

> Cổng `5433` khớp connection string trong `appsettings.json`. Nếu chạy Postgres cục bộ ở cổng khác thì sửa `Port=` trong `appsettings.json` cho khớp.

## API endpoints

| Method | Path                       | Auth   | Mô tả                     |
|--------|----------------------------|--------|---------------------------|
| POST   | /api/auth/register         | No     | Đăng ký (Customer)        |
| POST   | /api/auth/login            | No     | Đăng nhập → JWT           |
| POST   | /api/auth/refresh          | No     | Refresh token (rotation)  |
| GET    | /api/auth/me               | Bearer | Thông tin user + roles    |
| POST   | /api/shops                 | Bearer | Đăng ký mở shop (Pending) |
| GET    | /api/shops/me              | Bearer | Shop của tôi              |
| PUT    | /api/shops/me              | Bearer | Cập nhật thông tin shop   |
| GET    | /api/admin/shops           | Admin  | Danh sách shop (?status=) |
| POST   | /api/admin/shops/{id}/approve | Admin | Duyệt shop → role Seller |
| POST   | /api/admin/shops/{id}/reject  | Admin | Từ chối shop             |
| POST   | /api/products                 | Seller | Tạo sản phẩm của shop mình |
| GET    | /api/products/my              | Seller | Danh sách sản phẩm của shop |
| PUT    | /api/products/{id}            | Seller | Cập nhật sản phẩm (chỉ của shop mình) |
| DELETE | /api/products/{id}            | Seller | Xóa sản phẩm (chỉ của shop mình)    |
| GET    | /api/categories               | No     | Danh mục dạng tree                  |
| GET    | /api/categories/{slug}        | No     | Chi tiết danh mục                   |
| POST   | /api/categories               | Admin  | Tạo danh mục                        |
| PUT    | /api/categories/{id}          | Admin  | Cập nhật danh mục                   |
| DELETE | /api/categories/{id}          | Admin  | Xóa danh mục (chặn khi có con/SP)   |
| GET    | /api/chat/conversations       | Bearer | Danh sách hội thoại (unread count)  |
| POST   | /api/chat/conversations       | Bearer | Khách mở hội thoại với shop         |
| GET    | /api/chat/conversations/{id}/messages | Bearer | Lịch sử tin nhắn (đánh dấu đã đọc) |
| POST   | /api/chat/conversations/{id}/messages | Bearer | Gửi tin nhắn (push realtime)        |
| WS     | /ws/chat?access_token=JWT     | Bearer | WebSocket nhận tin realtime         |

Response format: `{ "success": bool, "data": ..., "message": string, "errors": [] }`

## Tiến độ

### Phase 0 — Nền tảng
- [x] 0.1 Cấu trúc dự án + README
- [x] 0.2 Docker Compose + PostgreSQL 16
- [x] 0.3 ASP.NET Core 10 API
- [x] 0.4 Rust + Leptos + Tailwind frontend
- [x] 0.5 CORS
- [x] 0.6 Kết nối frontend ↔ backend

### Phase 1 — Authentication
- [x] 1.1 EF Core + PostgreSQL + Identity (11 entities)
- [x] 1.2 Migration InitialCreate
- [x] 1.3 JWT Service (access 30p + refresh 7d, rotation)
- [x] 1.4 AuthController (register/login/refresh/me) + seeder roles
- [x] 1.5 UI Login + Register (terminal-style)
- [x] 1.6 Kết nối UI → API, lưu session localStorage, header hiển thị user + logout
- [x] 1.7 Protected routes (redirect `/auth/login` khi chưa đăng nhập)

### Phase 2 — Shop & Seller System
- [x] 2.1 Backend: register shop (Pending), /api/shops/me, admin list/approve/reject + seed admin
- [x] 2.2 UI: seller dashboard, tạo shop (auto-slug), hiển thị trạng thái Pending/Approved/Rejected
- [x] 2.3 Admin UI: `/admin` moderation (filter All/Pending/Approved/Rejected, approve→Seller, reject), chỉ Admin truy cập
- [x] 2.4 Seller: quản lý sản phẩm (CRUD) — tạo/list/xóa trong `/seller`, auto-slug, role-safety (mỗi seller chỉ chạm được sản phẩm của shop mình)
- [x] 2.5 Seller Dashboard layout — sidebar terminal menu (`~ menu`: dashboard/products/settings), item active `>`, products disabled khi shop chưa approved
- [x] 2.6 Shop Settings — form chỉnh sửa name/slug/description (PUT /api/shops/me), slug uniqueness, validation, flash message, dashboard cập nhật ngay

### Phase 3 — Product & Category
- [x] 3.1 API CRUD Category (Admin) — POST/PUT/DELETE admin-only, GET list tree public, GET by slug, parent-child, block delete khi có children/products
- [x] 3.2 API CRUD Product (Seller) hoàn thiện — validate CategoryId tồn tại, gallery ProductImage (list URL, ảnh chính, replace khi update), DTO thêm categoryName + images, seller-scoped
- [x] 3.3 API List Products public — GET /api/products (AllowAnonymous) filter category (slug/GUID, gồm cả children), shop, minPrice/maxPrice (theo SalePrice??Price), search name/description, sort price_asc/desc/name/newest, pagination PagedResult (page/pageSize clamp 1-50); GET /api/products/featured?take=; DTO thêm shopName
- [x] 3.4 API Get Product Detail — GET /api/products/{slug|id} (AllowAnonymous, active-only), reviews kèm reviewer name (newest first), averageRating/reviewCount, shop summary (name/slug/desc/logo/productCount), 404 khi không tồn tại hoặc inactive
- [x] 3.5 Rust: Trang chủ (Hero + Featured Products) — hero CTA, grid featured (GET /products/featured), skeleton loading, sale badge
- [x] 3.6 Rust: Trang danh sách sản phẩm `/products` (public) — filter sidebar (search, price range, sort, cây danh mục đệ quy), grid responsive 1/2/3 cột, phân trang prev/next; toàn bộ filter/sort/page đồng bộ qua query-string URL (chia sẻ/deep-link được), empty/loading/error states kiểu terminal
- [x] 3.7 Rust: Trang chi tiết sản phẩm `/products/{slug}` (public) — gallery (ảnh chính + thumbnail chọn), giá/sale, tồn kho, sku, link shop (`?shop=`), average rating dạng sao + danh sách review (tên/sao/comment/ngày), shop summary card, add-to-cart placeholder (Phase 4), 404 kiểu kernel-panic khi slug không tồn tại/inactive
- [x] 3.8 Rust: Seller — Quản lý sản phẩm (list/add/edit/delete) trong `/seller` → products — form add & edit dùng chung (prefill khi edit), thêm sale price, chọn category (dropdown cây danh mục thụt lề), image URLs (mỗi dòng 1 URL), toggle isActive (edit); edit inline theo từng row; auto-slug khi add, giữ slug khi edit

### Phase 4 — Cart & Order
- [x] 4.1 API Cart (Get/Add/Update/Delete) — `/api/cart` yêu cầu login; GET trả giỏ kèm product (unitPrice = SalePrice??Price, ảnh chính, shopName), totalItems + subtotal; POST add (dồn số lượng nếu đã có, validate active + tồn kho), PUT `{productId}` set số lượng (≤0 → xóa, validate tồn kho), DELETE `{productId}` xóa item
- [x] 4.2 API Order — `POST /api/orders` tạo đơn từ giỏ + địa chỉ giao (inline); validate giỏ không rỗng + sản phẩm active + đủ tồn kho (trả list lỗi nếu thiếu); chốt giá SalePrice??Price tại thời điểm đặt, sinh OrderCode `KS-yyyyMMdd-XXXX` (unique), trừ tồn kho, xóa giỏ — tất cả trong 1 transaction; trả OrderDto (items + address + tổng tiền)
- [x] 4.3 API Order History — `GET /api/orders` phân quyền theo role: Customer xem đơn của mình / Seller xem đơn chứa sản phẩm shop mình (lọc items + tổng theo shop, không gồm ship) / Admin xem tất cả; `GET /api/orders/{id}` chi tiết (owner/admin xem full, seller chỉ phần shop mình, còn lại 403), 404 khi không tồn tại
- [x] 4.4 Rust: Giỏ hàng `/cart` (protected) — bảng ASCII style (ảnh/tên/giá·sale·shop, stepper −/qty/+, line total, xóa `x`), summary items + subtotal + nút checkout; stepper gọi PUT (0 = xóa), disable khi busy/at-max; empty state; add-to-cart thật ở product detail (POST /cart, chưa login → redirect login), link `cart` trên header
- [x] 4.5 Rust: Checkout `/checkout` (protected) — form địa chỉ giao (name/phone/street/ward/district/city/note, prefill tên từ user, validate required client-side), order summary (từng dòng + items + shipping $0 + total), POST /orders → panel xác nhận (order code/status/total/ship-to) + link order history/products; empty cart → chặn checkout
- [x] 4.6 Rust: Order history + detail (protected) — `/orders` list card (order code, ngày, status màu theo trạng thái, số item, total) → link chi tiết; `/orders/{id}` bảng items (ảnh/tên link/giá·shop, qty, total), ship-to (address + note), tổng (items/shipping/total), 404/no-access panel; empty state; link `orders` trên header
- [x] 4.7 API Update order status — `PUT /api/orders/{id}/status` (role Seller/Admin); validate status enum (case-insensitive), Admin đổi mọi đơn / Seller chỉ đơn chứa sản phẩm shop mình (else 403), chặn đổi khi đơn đã Delivered/Cancelled, trả OrderDto (seller nhận view lọc theo shop), 404 khi không tồn tại
- [x] 4.8 Rust: UI đổi trạng thái đơn (Seller/Admin) — panel `# manage status` ở `/orders/{id}` (chỉ role Seller/Admin), select 6 trạng thái + nút update → PUT status, cập nhật ngay order signal; ẩn control + báo "finalized" khi đơn Delivered/Cancelled

### Phase 5 — Review & Rating
- [x] 5.1 API Create Review — `POST /api/reviews` (login); chỉ đánh giá khi **đã mua** (có OrderDetail trong đơn của user, status ≠ Cancelled) → else 403; validate rating 1-5 + comment ≤1000; chặn đánh giá trùng (1 review/user/product), 404 khi product không tồn tại; trả ReviewDto kèm tên người đánh giá
- [x] 5.2 API Get Reviews by Product — `GET /api/reviews?productId=` (public); trả list review (kèm tên reviewer, newest-first) + averageRating (làm tròn 2 số) + reviewCount; 400 khi thiếu productId
- [x] 5.3 Rust: Reviews ở product detail — section `# reviews` load riêng qua `GET /api/reviews?productId=` (component reactive, reload được cho 5.4); summary card avg lớn + sao + rating distribution 5★→1★ dạng progress bar ASCII `[#### ]`, list review (tên/sao/comment/ngày), empty state
- [x] 5.4 Rust: Form đánh giá — ở `/orders/{id}` khi đơn **Delivered** + role Customer, mỗi sản phẩm có form inline: star picker ★ (1-5, click chọn), textarea comment, submit → POST /api/reviews; success → "✓ thanks" (ẩn form), lỗi (chưa mua/đã đánh giá) hiển thị inline; Seller/Admin thấy panel status thay vì form

### Phase 6 — Admin Panel
- [x] 6.1 API Admin Dashboard — `GET /api/admin/dashboard` (Admin-only); thống kê tổng user, shop (+ pending/approved), product (+ active), order, doanh thu (tổng đơn ≠ Cancelled), phân bố đơn theo trạng thái (đủ 6 mức kèm 0)
- [x] 6.2 API Admin quản lý user — `GET /api/admin/users` (filter search/role/isActive), `POST /api/admin/users/{id}/ban` (set IsActive=false + thu hồi refresh token → không login được), `POST .../unban`; chặn ban chính mình + ban Admin, 404 khi không tồn tại (Admin-only)
- [x] 6.3 API Admin quản lý đơn hệ thống — `GET /api/admin/orders` (Admin-only) filter status + search theo orderCode, phân trang PagedResult (page/pageSize clamp 1-50), trả AdminOrderDto (kèm khách hàng: id/tên/email, itemCount, total); đổi trạng thái dùng lại `PUT /api/orders/{id}/status` (4.7 cho Admin), chi tiết dùng `GET /api/orders/{id}`
- [x] 6.4 Rust: Admin Dashboard — `/admin` chuyển thành control panel có tab (dashboard/shops); tab dashboard gọi `GET /api/admin/dashboard`: stat cards (users/shops/products/orders) + revenue, "# system monitor" bars ASCII `[#### ]` (shops approved/pending, products live) kèm %, "# orders by status" bars scale theo max; shop moderation cũ tách thành component trong tab shops
- [x] 6.5 Rust: Admin duyệt shop — tab `shops` mặc định filter **Pending** (list chờ duyệt), approve/reject với flash `[OK] approved '<shop>' — owner is now Seller` / rejected, dòng đếm `// showing N shop(s)`, filter All/Pending/Approved/Rejected, list tự refresh sau thao tác
- [x] 6.6 Rust: Admin quản lý danh mục — tab `categories`: cây danh mục thụt lề (name / slug / product count), form create+edit dùng chung (auto-slug khi nhập name, chọn parent dropdown cây — loại chính nó khi edit), delete (chặn khi có children/products → hiện lỗi từ API), flash create/update/delete, list tự refresh

### Phase 7 — Polish & Optimization
- [x] 7.1 Rust: Loading states — component `Loading` (typewriter effect: text hiện dần char-by-char, lặp, kèm block caret nhấp nháy) dùng CSS `term-typing` (`--tw`/`--steps` theo độ dài text); áp dụng cho mọi loading chính (products/product detail/reviews/cart/checkout/orders/seller/admin + "checking session")
- [x] 7.2 Rust: Error handling — component `KernelPanic` (panel style kernel panic: `--- KERNEL PANIC: <code> ---` + fake stack trace + nút recovery) dùng chung cho **404** (router fallback route-not-found, product/order not-found) và **500** (lỗi server/network khi load product/order); nhận code/title/detail/back link tùy biến
- [x] 7.3 Rust: Toast notifications — `ToastContext` global (provide ở App) + `ToastHost` (góc dưới-phải, stack, tự ẩn sau 4s, nút x) hiển thị dạng log terminal `[INFO]/[WARN]/[ERROR]/[OK]` màu theo cấp; hook vào add-to-cart, cart update/remove, checkout order placed, review submit, seller/admin đổi trạng thái đơn
- [x] 7.4 Rust: Responsive — header wrap + ẩn `user (role)` trên mobile (brand link về home); seller dashboard stack (sidebar `flex-col sm:flex-row`, menu ngang trên mobile); admin system-monitor/orders-by-status `overflow-x-auto`; các grid product/checkout/order/dashboard đã stack sẵn (`grid-cols-1 sm:/lg:`); style terminal giữ nguyên trên mọi breakpoint
- [x] 7.5 Seed data — `DatabaseSeeder.SeedDemoDataAsync` + chạy 1 lệnh `./seed.sh` (hoặc `dotnet run --project backend/KernelStore.Api seed`): tạo 5 categories (cây Electronics→Laptops/Phones + Accessories + Home), 2 seller + shop Approved, 8 products (kèm ảnh placeholder, giá/sale/stock); idempotent (get-or-create + completion marker → chạy lại là "already present — skipping", chạy sau khi reset là tạo lại đầy đủ)
- [x] 7.6 README hướng dẫn cài đặt chi tiết — mục "Chạy trên NixOS": yêu cầu `virtualisation.docker.enable`, vào `nix-shell` (tự thêm wasm target), các bước DB/backend/seed/frontend, bảng tài khoản mặc định, cách chạy test, build một lần, xử lý sự cố NixOS (cc not found / docker daemon / wasm target / CORS), phương án Postgres không dùng Docker

### Phase 8 — Chat realtime (Customer ↔ Seller)
- [x] 8.1 Backend: Entities `Conversation` (duy nhất theo cặp Buyer+Shop) + `ChatMessage` + migration `AddChat`; DbContext config (unique index BuyerId+ShopId, maxLength 2000, FK restrict/cascade)
- [x] 8.2 API Chat — `GET/POST /api/chat/conversations` (list kèm lastMessage + unreadCount; mở hội thoại idempotent, chặn chat shop của chính mình 400, shop không tồn tại 404), `GET .../messages` (lịch sử + tự đánh dấu đã đọc, 403 nếu không phải participant), `POST .../messages` (validate rỗng 400 / >2000 400, lưu DB + cập nhật LastMessageAt)
- [x] 8.3 WebSocket realtime — `/ws/chat?access_token=JWT` (validate token thủ công, 401 nếu thiếu/sai), `ChatConnectionManager` (Singleton, theo dõi kết nối theo userId, đa tab); server push JSON camelCase tới người nhận ngay khi có tin gửi qua REST
- [x] 8.4 Rust: Page `/chat` (protected) — sidebar list hội thoại (tên phía đối thoại, last message, unread `(n)`, active highlight), thread chat dạng bubble (mine phải / theirs trái, timestamp), input + Enter/`$ gửi`, auto-scroll bottom, `?c=<id>` mở thẳng hội thoại; WebSocket lắng nghe realtime (nhận tin → append nếu đang xem + reload list), tự đóng socket khi unmount/logout
- [x] 8.5 Rust: Product detail — nút `chat with seller` (login bắt buộc → redirect), `start_conversation` rồi nhảy `/chat?c=<id>`; toast lỗi khi thất bại; header có link `chat`
- [x] 8.6 Tests — `test_chat_api.sh` (27 checks): auth 401 (REST + WS token thiếu/sai), mở hội thoại/idempotent/chặn shop mình/404, list 2 phía, message rỗng + >2000 → 400, non-participant → 403, unread đúng + giảm khi đọc, **realtime WS**: seller push→buyer & buyer push→seller đều nhận được; `test_full_api.sh` regression 52 checks PASS

## Test

E2E via Selenium (headless Firefox):
- `test_auth_ui.py` — login/register/logout/session restore (11 checks)
- `test_protected.py` — protected routes redirect (8 checks)
- `test_seller_ui.py` — tạo shop UI + auto-slug + trạng thái Pending (8 checks)
- `test_admin_ui.py` — admin login, chặn non-admin, filter, approve/reject (15 checks)
- `test_seller_products_ui.py` — panel sản phẩm, tạo/list/xóa, auto-slug, phân quyền (12 checks)
- `test_seller_dashboard_ui.py` — sidebar `~ menu`, đổi section dashboard/products/settings, products disabled khi Pending, dashboard mặc định (13 checks)
- `test_seller_settings_ui.py` — prefill form, lưu thay đổi + flash, dashboard cập nhật, pending seller edit, validation (6 checks)

Test API (Python, không cần Selenium):
- `test_shops_api.py` — register shop, /me, admin approve/reject (14 checks)
- `test_products_api.py` — CRUD sản phẩm theo seller, cross-seller 404, role-safety (19 checks)
- `test_shop_update_api.py` — PUT /shops/me, slug uniqueness, 404 no-shop, validation (9 checks)
- `test_categories_api.py` — CRUD category, tree, parent-child, role-safety admin, block delete (21 checks)
- `test_products_api_v32.py` — product + category validate, gallery images (primary/order/replace/clear), DTO categoryName (14 checks)
- `test_products_list_api.py` — list public active-only, filter category/shop/price/search, sort, pagination, featured, ẩn inactive (22 checks)
- `test_products_detail_api.py` — detail by slug/guid, reviews kèm tên + thứ tự newest-first + averageRating, shop summary, 404 unknown/inactive, route-safety (18 checks)
- `test_phase4_api.sh` — Phase 4 (curl + jq, chạy trong nix-shell): add-to-cart cập nhật, vượt stock báo lỗi, tạo đơn trừ stock + tạo Order/OrderDetails, đơn trống báo lỗi, tổng tiền = items + ship, seller đổi status → customer thấy + customer bị 403 (22 checks)
- `test_phase5_api.sh` — Phase 5 (curl + jq, chạy trong nix-shell): chưa mua → 403, đã mua → đánh giá 1-5 + comment, chặn đánh giá trùng, rating 6 → 400, averageRating đúng ((4+2)/2=3), list newest-first, GET thiếu productId → 400, product không tồn tại → 404 (15 checks)
- `test_phase6_api.sh` — Phase 6 (curl + jq, chạy trong nix-shell): dashboard stats (users/shops/pending/6 status buckets/revenue), non-admin → 403, duyệt shop → Approved + owner thành Seller, ban → không login (401) → unban → login lại (200), chặn ban chính mình + 404, admin orders (paginate/search/filter), category CRUD + chặn xóa khi có children, non-admin tạo category → 403 (32 checks)
- `test_chat_api.sh` — Chat realtime (curl + jq + `test/wsclient` C# probe, chạy trong nix-shell): conversations list/idempotent/chặn shop mình→400/unknown→404, message rỗng + >2000→400, non-participant→403, unread count + giảm khi đọc, **WebSocket realtime** đẩy tin 2 chiều (seller↔buyer) + WS token thiếu/sai→reject (27 checks)
- `test_extra_api.sh` — Các chức năng còn lại (curl + jq, chạy trong nix-shell): category CRUD (tạo con/đổi tên/chặn xóa gốc có con/xóa con/404), non-admin tạo category→403, shop settings + slug conflict→400, **promotion Customer→Seller**: register → role Customer, mở shop → role Seller (sau refresh), shop vẫn Pending → admin approve → Approved; **guard sản phẩm theo trạng thái shop**: Pending/Banned không tạo (400) + Banned không sửa (400), Approved tạo được (200); **ban tạm thời** (`/ban`→Banned): sản phẩm ẩn khỏi public (detail→404, `products?shop=`→0, isActive=false) rồi `/unban`→Approved hiện lại; **ban vĩnh viễn** (`DELETE`): không đơn→xóa cứng, có đơn→xóa mềm status `Deleted` + ẩn sản phẩm + **giữ nguyên lịch sử đơn** (buyer vẫn xem được, tên sản phẩm giữ); admin user ban (bị ban→login 401)/unban/ban tự thân→400/unknown→404; order cancel→Cancelled + khôi phục stock về đúng số cũ; return flow (seller ship→buyer confirm→ReturnRequested→seller approve→Returned); product delete (seller role sau refresh→tạo→xóa→hết trong danh sách); refresh-token reuse→401; **upload ảnh sản phẩm** (POST `/uploads/image` jpg/png/svg: thiếu auth→401, ext lạ→400, trả URL tuyệt đối, GET file→200 + `X-Content-Type-Options: nosniff`, seller tạo sản phẩm gắn ảnh→buyer xem detail thấy ảnh, seller sửa đổi ảnh→buyer thấy ảnh mới) (66 checks)
- `test_full_api.sh` — Smoke test end-to-end mọi vai trò (curl + jq, chạy trong nix-shell): auth (register/login/sai mật khẩu→401/me/refresh), browse công khai (categories/products/detail/featured/reviews/404), cart (add/update/delete), order (giỏ trống→400/tạo/lịch sử/xem), review trước khi nhận→403; seller: mở shop → tự nâng role Seller (sau refresh), tạo sản phẩm khi Pending→400, admin duyệt shop→Approved, tạo/sửa sản phẩm + dashboard doanh thu + mục sales; vòng đời buy→Shipped→khách xác nhận nhận hàng→Delivered→đánh giá (review trùng→400, seller không tự đặt Delivered→400); RBAC (customer chặn khỏi admin/seller, không token→401, không đổi status đơn, seller không duyệt shop). Trả exit code 0 nếu all pass (52 checks)

## Ghi chú kỹ thuật

- Chạy toolchain trên NixOS: `nix-shell shell.nix --run '<command>'`
- `dotnet-ef` cần `DOTNET_ROOT` + `PATH` setup trong shell.nix
- JWT: HS256, secret trong `appsettings.json`, access 30 phút, refresh 7 ngày (single-use rotation)
- Refresh token đánh dấu `IsUsed=true` sau mỗi lần dùng (reuse bị từ chối)
- Chat realtime: REST để ghi/lấy tin (`/api/chat/*`), WebSocket `/ws/chat` chỉ đẩy tin tới người nhận (token truyền qua query `access_token`); `ChatConnectionManager` in-memory — chỉ dành cho 1 server instance
