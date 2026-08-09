# KernelStore — Hướng dẫn chạy trên Windows

Hướng dẫn này thay thế phần "Chạy trên NixOS" trong [README.md](./README.md) cho môi trường **Windows 10/11**. Trên Windows không dùng `nix-shell` — bạn cài trực tiếp các toolchain rồi chạy từng service.

Tổng quan 3 tiến trình cần bật:

| Service    | Công nghệ                       | URL                     |
|------------|---------------------------------|-------------------------|
| Database   | PostgreSQL 16 (Docker Desktop)  | `localhost:5432`        |
| Backend    | ASP.NET Core 10 Web API         | `http://localhost:5000` |
| Frontend   | Rust + Leptos + Trunk           | `http://localhost:8080` |

---

## 0. Cài đặt công cụ (một lần)

Khuyến nghị dùng **winget** (có sẵn trên Windows 10/11) để cài nhanh. Mở **PowerShell** rồi chạy:

```powershell
# .NET SDK 10 (backend)
winget install Microsoft.DotNet.SDK.10

# Rust toolchain (frontend)
winget install Rustlang.Rustup

# Docker Desktop (PostgreSQL) — hoặc bỏ qua nếu tự cài Postgres, xem mục cuối
winget install Docker.DockerDesktop

# jq — chỉ cần nếu muốn chạy script test *.sh
winget install jqlang.jq
```

> Nếu không có winget: tải thủ công .NET SDK 10 (dotnet.microsoft.com), Rustup (rustup.rs), Docker Desktop (docker.com).

**Sau khi cài xong, đóng và mở lại PowerShell** để `PATH` cập nhật, rồi thiết lập Rust cho frontend:

```powershell
rustup default stable
rustup target add wasm32-unknown-unknown   # build WASM cho Leptos
cargo install trunk                        # dev server + bundler
```

> `cargo install trunk` biên dịch từ source nên hơi lâu (vài phút). Trên Windows, Rust cần **Visual Studio Build Tools** (C++ build tools) để có linker. Nếu `cargo` báo lỗi `link.exe not found`, cài: `winget install Microsoft.VisualStudio.2022.BuildTools` rồi trong Visual Studio Installer chọn workload **"Desktop development with C++"**.

Kiểm tra:

```powershell
dotnet --version      # 10.x
rustc --version
trunk --version
docker --version
```

---

## 1. Database (PostgreSQL 16)

Bật **Docker Desktop** trước (đợi icon chuyển sang trạng thái *Running*), rồi tại thư mục gốc dự án:

```powershell
cd C:\path\to\KernelStore
docker compose up -d      # postgres:16 tại localhost:5432 (db/user/pass: kernelstore/admin/admin123)
docker compose ps         # kiểm tra cột STATUS = healthy
```

`docker-compose.yml` dùng chung file với Linux — không cần chỉnh sửa.

---

## 2. Backend (ASP.NET Core 10 API)

Mở **PowerShell mới**, tại thư mục gốc dự án:

```powershell
dotnet run --project backend\KernelStore.Api --urls http://localhost:5000
```

- Khi start, seeder tự `Migrate` DB + tạo roles `Customer/Seller/Admin` + tài khoản admin.
- Cứ để cửa sổ này chạy. Dừng bằng `Ctrl + C`.

---

## 3. Seed dữ liệu mẫu (tuỳ chọn)

`seed.sh` là script bash nên trên Windows chạy trực tiếp lệnh `dotnet` (không dùng `.sh`). Mở PowerShell mới ở thư mục gốc:

```powershell
dotnet run --project backend\KernelStore.Api --no-launch-profile seed
```

Tạo 5 danh mục, 2 shop (Approved) + 8 sản phẩm. Idempotent — chạy lại sẽ báo `already present`.

---

## 4. Frontend (Leptos + Trunk)

Mở **PowerShell thứ 3**, vào thư mục `frontend`:

```powershell
cd C:\path\to\KernelStore\frontend
trunk serve --port 8080      # build WASM + tailwind, hot-reload
```

Mở trình duyệt tại **`http://localhost:8080`**.

---

## Tài khoản mặc định

| Vai trò   | Email               | Mật khẩu       | Nguồn            |
|-----------|---------------------|----------------|------------------|
| Admin     | `admin@ks.com`      | `Admin@12345`  | seed tự động     |
| Seller    | `seller1@demo.ks`   | `Seller@12345` | seed (mục 3)     |
| Seller    | `seller2@demo.ks`   | `Seller@12345` | seed (mục 3)     |
| Customer  | tự đăng ký ở `/auth/register` | —    | —                |

---

## Chạy test (tuỳ chọn)

Các file `test_phase*_api.sh` là script bash. Trên Windows cần **Git Bash** (đi kèm khi cài Git) hoặc **WSL** để chạy, và cần `jq` + `curl` trong PATH. API phải đang chạy trên `:5000`.

Trong **Git Bash**:

```bash
./test_phase4_api.sh     # Cart & Checkout   (22 checks)
./test_phase5_api.sh     # Review & Rating   (15 checks)
./test_phase6_api.sh     # Admin Panel       (32 checks)
```

> Không có Git Bash/WSL thì bỏ qua các test này — chúng không bắt buộc để chạy ứng dụng.

---

## Build một lần (không chạy dev server)

```powershell
dotnet build backend\KernelStore.Api      # backend
cd frontend; trunk build                  # frontend → frontend\dist\
```

---

## Xử lý sự cố (Windows)

- **`link.exe`/`cc` không tìm thấy khi build frontend** → thiếu C++ Build Tools. Cài Visual Studio Build Tools + workload "Desktop development with C++" (xem mục 0).
- **`dotnet`/`trunk`/`cargo` không nhận lệnh** → chưa mở lại terminal sau khi cài, hoặc chưa có trong PATH. Đóng/mở lại PowerShell.
- **`error: target 'wasm32-unknown-unknown' not found`** → chạy `rustup target add wasm32-unknown-unknown`.
- **`Cannot connect to the Docker daemon`** → chưa bật Docker Desktop, hoặc nó chưa khởi động xong (đợi icon *Running*).
- **Backend không nối được DB** → kiểm tra `docker compose ps` (postgres healthy) và connection string trong `backend\KernelStore.Api\appsettings.json` (`Host=localhost;Port=5432;...`).
- **CORS bị chặn** → frontend phải chạy đúng `http://localhost:8080` (khai báo trong `Cors:AllowedOrigins`).
- **Port đã bị chiếm (5000/5432/8080)** → đổi cổng ở lệnh tương ứng, hoặc tìm tiến trình đang giữ: `netstat -ano | findstr :5000`.

---

## Postgres không dùng Docker

Nếu không muốn cài Docker Desktop, cài PostgreSQL 16 native:

```powershell
winget install PostgreSQL.PostgreSQL.16
```

Sau khi cài, tạo database + user khớp với connection string (dùng `psql`, thay `<pg-superuser>` thường là `postgres`):

```powershell
psql -U postgres -c "CREATE USER admin WITH PASSWORD 'admin123' SUPERUSER;"
psql -U postgres -c "CREATE DATABASE kernelstore OWNER admin;"
```

Đảm bảo service PostgreSQL đang lắng nghe ở `localhost:5432` (mặc định). Sau đó tiếp tục từ **mục 2** như bình thường.
