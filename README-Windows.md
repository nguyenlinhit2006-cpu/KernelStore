# KernelStore — Hướng dẫn chạy trên Windows

Hướng dẫn cho môi trường **Windows 10/11** (thay cho phần "Chạy trên NixOS" trong [README.md](./README.md)). Trên Windows không dùng `nix-shell` — bạn cài trực tiếp toolchain rồi chạy từng service.

Ứng dụng cần **3 tiến trình chạy cùng lúc**, đúng thứ tự **Database → Backend → Frontend**:

| Service    | Công nghệ                       | URL                     |
|------------|---------------------------------|-------------------------|
| Database   | PostgreSQL 16                   | `localhost:5433`        |
| Backend    | ASP.NET Core 10 Web API         | `http://localhost:5000` |
| Frontend   | Rust + Leptos + Trunk           | `http://localhost:8080` |

> ⚠️ **Cổng Postgres là `5433`** (khớp connection string `Port=5433` trong `backend\KernelStore.Api\appsettings.json`). Đừng nhầm sang `5432`.

---

## 📑 Mục lục

1. [Cài đặt công cụ (một lần)](#-bước-0--cài-đặt-công-cụ-một-lần)
2. [Bước 1 — Database: chọn **Phương án A (Docker)** hoặc **Phương án B (PostgreSQL native)**](#-bước-1--database-chọn-1-trong-2-phương-án)
   - [Phương án A — Docker Desktop (khuyến nghị)](#phương-án-a--docker-desktop-khuyến-nghị)
   - [Phương án B — PostgreSQL native (không cần Docker)](#phương-án-b--postgresql-native-không-cần-docker)
3. [Bước 2 — Backend](#-bước-2--backend-aspnet-core-10-api)
4. [Bước 3 — Seed dữ liệu mẫu (tuỳ chọn)](#-bước-3--seed-dữ-liệu-mẫu-tuỳ-chọn)
5. [Bước 4 — Frontend](#-bước-4--frontend-leptos--trunk)
6. [Tài khoản mặc định](#-tài-khoản-mặc-định) · [Chạy test](#-chạy-test-tuỳ-chọn) · [Xử lý sự cố](#-xử-lý-sự-cố-windows)

---

## 🔧 Bước 0 — Cài đặt công cụ (một lần)

Khuyến nghị dùng **winget** (có sẵn trên Windows 10/11). Mở **PowerShell** rồi chạy phần bắt buộc:

```powershell
# BẮT BUỘC cho mọi phương án
winget install Microsoft.DotNet.SDK.10     # .NET SDK 10  (backend)
winget install Rustlang.Rustup             # Rust toolchain (frontend)
```

Rồi cài **DB engine tuỳ phương án bạn chọn ở Bước 1**:

```powershell
# Nếu chọn Phương án A (Docker):
winget install Docker.DockerDesktop

# Nếu chọn Phương án B (PostgreSQL native):
winget install PostgreSQL.PostgreSQL.16
```

**Sau khi cài xong, đóng và mở lại PowerShell** (để `PATH` cập nhật), rồi thiết lập Rust cho frontend:

```powershell
rustup default stable
rustup target add wasm32-unknown-unknown   # build WASM cho Leptos
cargo install trunk                        # dev server + bundler
```

Cuối cùng kiểm tra (mỗi lệnh phải in ra version):

```powershell
dotnet --version      # 10.x
rustc --version
trunk --version
```

> `cargo install trunk` biên dịch từ source nên hơi lâu (vài phút). Rust trên Windows cần **Visual Studio Build Tools** (C++) để có linker. Nếu `cargo` báo `link.exe not found`: `winget install Microsoft.VisualStudio.2022.BuildTools`, rồi trong Visual Studio Installer chọn workload **"Desktop development with C++"**.

<details>
<summary><b>📥 Nguồn cài đặt chính thức (bấm để mở)</b></summary>

Chỉ tải từ nhà phát hành **chính thức** — `winget install <ID>` lấy đúng từ các nguồn này. (ID đã đối chiếu với kho `winget-pkgs` của Microsoft.)

| Công cụ | winget ID | Trang tải chính thức | Dùng cho |
|---|---|---|---|
| .NET SDK 10 | `Microsoft.DotNet.SDK.10` | https://dotnet.microsoft.com/download/dotnet/10.0 | Backend (bắt buộc) |
| Rust (rustup) | `Rustlang.Rustup` | https://rustup.rs | Frontend (bắt buộc) |
| Trunk | *(qua `cargo install trunk`)* | https://trunkrs.dev | Frontend (bắt buộc) |
| Docker Desktop | `Docker.DockerDesktop` | https://www.docker.com/products/docker-desktop/ | **Phương án A** |
| PostgreSQL 16 | `PostgreSQL.PostgreSQL.16` | https://www.postgresql.org/download/windows/ | **Phương án B** |
| VS Build Tools 2022 | `Microsoft.VisualStudio.2022.BuildTools` | https://visualstudio.microsoft.com/downloads/ → *Build Tools* | Khi thiếu `link.exe` |
| Git for Windows | `Git.Git` | https://git-scm.com/download/win | Chạy test `.sh` (tuỳ chọn) |
| jq | `jqlang.jq` | https://jqlang.github.io/jq/download/ | Chạy test `.sh` (tuỳ chọn) |

> ⚠️ Chỉ dùng đúng các domain trên, tránh trang mirror bên thứ ba. Kiểm tra ID trước khi cài: `winget show <ID>`.

</details>

---

## 🗄️ Bước 1 — Database (chọn 1 trong 2 phương án)

Hai phương án **cho ra database y hệt nhau** — cùng db `kernelstore`, user `admin`, mật khẩu `admin123`, cùng cổng `5433`, cùng dữ liệu seed. Backend & Frontend (Bước 2–4) **giống nhau**, không phụ thuộc bạn chọn cách nào.

| | **Phương án A — Docker** | **Phương án B — PostgreSQL native** |
|---|---|---|
| Cần cài | Docker Desktop | PostgreSQL 16 |
| Ưu điểm | Có sẵn file `.bat` chạy tự động cả stack; không đụng cấu hình | Không cần Docker, nhẹ máy |
| Phù hợp | Muốn nhanh, ít thao tác | Máy đã có/không muốn cài Docker |

Chọn **một** trong hai phần dưới đây rồi làm theo, xong thì sang **Bước 2**.

---

### Phương án A — Docker Desktop (khuyến nghị)

> Yêu cầu: đã `winget install Docker.DockerDesktop`, và **bật Docker Desktop** (đợi icon *Running*).

#### ⭐ Cách A1 — Tự động cả stack bằng `win-run-all.bat` (nhanh nhất)

File `win-run-all.bat` (ở thư mục gốc) làm **toàn bộ**: bật DB → đợi healthy → chạy Backend → chạy Frontend → **tự mở trình duyệt**. Chỉ chạy 1 file là xong, **không cần làm Bước 2–4**.

**Cách chạy — chọn 1:**
- **Double-click** `win-run-all.bat` trong File Explorer, hoặc
- Trong PowerShell:
  ```powershell
  cd C:\path\to\KernelStore
  .\win-run-all.bat
  ```

**Màn hình sẽ lần lượt hiện:**

```text
[1/5] Database (Docker)...              → bật Postgres
[2/5] Doi PostgreSQL san sang...        → đợi DB healthy
[3/5] Backend -> :5000                  → mở CỬA SỔ MỚI chạy backend
[4/5] Doi Backend san sang...           → đợi backend build + lắng nghe :5000
[5/5] Frontend -> :8080                 → mở CỬA SỔ MỚI chạy frontend
Doi Frontend build xong...              → đợi trunk biên dịch WASM
Mo trinh duyet...                       → TỰ mở http://localhost:8080
```

- Kết quả: **3 cửa sổ** (điều phối + Backend + Frontend) + trình duyệt tự bật.
- **Lần đầu chờ lâu** (vài chục giây → vài phút) do phải build backend + biên dịch WASM — script đứng đợi là **bình thường**, không phải treo. Các lần sau nhanh hơn nhiều.
- Trình duyệt lỗi `localhost`? Mở thủ công **`http://127.0.0.1:8080/`**.
- **Tắt:** đóng/`Ctrl + C` 2 cửa sổ Backend & Frontend. DB vẫn chạy nền → `docker compose down` để tắt hẳn.

> Cảnh báo "Windows protected your PC" khi double-click → bấm **More info → Run anyway** (file `.bat` nội bộ dự án).

#### Cách A2 — Thủ công (hiểu từng bước)

```powershell
cd C:\path\to\KernelStore
docker compose up -d      # postgres:16 tại localhost:5433 (db/user/pass: kernelstore/admin/admin123)
docker compose ps         # đợi cột STATUS = healthy
```

`docker-compose.yml` dùng chung với Linux — **không cần chỉnh sửa**. Dữ liệu lưu ở volume `postgres_data`; muốn xoá sạch làm lại: `docker compose down -v`.

Xong DB → sang **[Bước 2](#-bước-2--backend-aspnet-core-10-api)**.

#### (Tuỳ chọn) Nạp sẵn dữ liệu mẫu từ `database.sql`

File `database.sql` là bản dump **đã seed sẵn** (10 danh mục, 7 shop, 57 sản phẩm, admin + 7 seller), đồng bộ schema hiện tại. Nạp thẳng vào container (thay cho Bước 3):

```powershell
type database.sql | docker exec -i kernelstore-postgres psql -U admin -d kernelstore
```

File có `DROP ... IF EXISTS` ở đầu nên ghi đè an toàn.

#### Các file `.bat` lẻ (Phương án A)

| File | Việc |
|------|------|
| `win-run-all.bat` | Tự động cả stack (như Cách A1). |
| `win-db.bat`       | Chỉ bật Database (Docker). |
| `win-backend.bat`  | Chỉ chạy Backend (`:5000`). |
| `win-frontend.bat` | Chỉ chạy Frontend (`:8080`). |
| `win-seed.bat`     | Seed dữ liệu mẫu. |

> `win-backend.bat` / `win-frontend.bat` / `win-seed.bat` chỉ gọi `dotnet`/`trunk` nên **dùng được cho cả Phương án B**; riêng `win-db.bat` / `win-run-all.bat` là Docker.

---

### Phương án B — PostgreSQL native (không cần Docker)

> Yêu cầu: đã `winget install PostgreSQL.PostgreSQL.16`.

#### B1. Cho Postgres nghe đúng cổng `5433`

Trình cài hỏi mật khẩu superuser `postgres` — nhớ mật khẩu này. Sau khi cài, `psql` nằm ở `C:\Program Files\PostgreSQL\16\bin`; nếu `psql` không nhận lệnh, thêm thư mục đó vào `PATH` rồi mở lại PowerShell.

Bản native mặc định nghe `5432`, còn dự án dùng `5433`. Cho khớp mà **không phải sửa code**:

```powershell
# sửa dòng  port = 5432  ->  port = 5433
notepad "C:\Program Files\PostgreSQL\16\data\postgresql.conf"

# restart service để áp dụng
Restart-Service postgresql-x64-16
```

> Không muốn đổi cổng Postgres? Thay vào đó sửa `Port=5433` → `Port=5432` trong `backend\KernelStore.Api\appsettings.json`. Chỉ chọn **một** — cổng Postgres và connection string phải trùng nhau.

#### B2. Tạo user + database

```powershell
# -p 5433 vì đã cho Postgres nghe 5433 ở B1 (bỏ -p nếu bạn giữ 5432)
psql -U postgres -p 5433 -c "CREATE USER admin WITH PASSWORD 'admin123' SUPERUSER;"
psql -U postgres -p 5433 -c "CREATE DATABASE kernelstore OWNER admin;"
```

Kiểm tra kết nối (phải in ra `1`):

```powershell
psql "host=localhost port=5433 dbname=kernelstore user=admin password=admin123" -tc "SELECT 1;"
```

#### B3. Đưa dữ liệu vào — chọn 1 trong 2

- **Cách 1 — để backend tự tạo schema + seed:** bỏ trống DB, sang thẳng Bước 2 (backend tự migrate + tạo admin) rồi Bước 3 (seed). Đơn giản nhất.
- **Cách 2 — nạp sẵn `database.sql`** (có ngay admin + 7 seller + 57 sản phẩm):
  ```powershell
  psql -U admin -p 5433 -d kernelstore -f database.sql
  ```

Xong DB → sang **[Bước 2](#-bước-2--backend-aspnet-core-10-api)**.

> **Reset sạch DB (native):** `psql -U postgres -p 5433 -c "DROP DATABASE kernelstore;"` rồi làm lại B2 + B3.

---

## ⚙️ Bước 2 — Backend (ASP.NET Core 10 API)

> Đã làm ở Cách A1 (`win-run-all.bat`)? Backend đã chạy rồi — bỏ qua bước này.

Mở **PowerShell mới** tại thư mục gốc:

```powershell
dotnet run --project backend\KernelStore.Api --urls http://localhost:5000
```

- Khi start, seeder tự `Migrate` DB (chạy mọi migration, gồm `AddWarranty`) + tạo roles `Customer/Seller/Admin` + tài khoản admin.
- Để cửa sổ này chạy (dừng bằng `Ctrl + C`). Đợi log **`Now listening on: http://localhost:5000`** trước khi thao tác frontend.
- Kiểm tra nhanh (PowerShell khác): `curl http://localhost:5000/api/categories` phải trả JSON.

---

## 🌱 Bước 3 — Seed dữ liệu mẫu (tuỳ chọn)

> Bỏ qua nếu đã nạp `database.sql` (A2 / B3-Cách 2).

Mở PowerShell mới ở thư mục gốc:

```powershell
dotnet run --project backend\KernelStore.Api --no-launch-profile seed
```

Hoặc double-click **`win-seed.bat`**. Tạo **10 danh mục, 7 shop (Approved) + 57 sản phẩm** (kèm ảnh). Idempotent — chạy lại báo `already present — skipping`.

Ngoài nhóm điện tử cơ bản, catalog demo còn trải theo chuyên ngành CNTT:

| Chuyên ngành | Shop | Ví dụ sản phẩm |
|---|---|---|
| IoT & Embedded | IoT Depot | Raspberry Pi 5, ESP32, Arduino R4, LoRa Gateway |
| AI & Machine Learning | Neural Forge | RTX 4090, Jetson Orin, Google Coral, A100 80GB |
| Cybersecurity | SecOps Armory | YubiKey 5, Flipper Zero, WiFi Pineapple, Proxmark3 |
| SysAdmin & DevOps | OpsCenter | UniFi Dream Machine, 1U Server, Synology NAS |
| Developer Tools | DevTools Hub | Keychron Q1, màn 4K, Stream Deck, license JetBrains |

> Ảnh sản phẩm ở `backend\KernelStore.Api\wwwroot\uploads\`, phục vụ tại `http://localhost:5000/uploads/<slug>.jpg`.

---

## 🖥️ Bước 4 — Frontend (Leptos + Trunk)

> Đã làm ở Cách A1 (`win-run-all.bat`)? Frontend đã chạy rồi — bỏ qua bước này.

Mở **PowerShell mới**, vào thư mục `frontend`:

```powershell
cd C:\path\to\KernelStore\frontend
trunk serve --port 8080      # build WASM + tailwind, hot-reload
```

Mở trình duyệt tại **`http://localhost:8080`**. Lần build đầu tải crate + biên dịch WASM nên hơi lâu.

> `localhost:8080` không mở được (thường do `localhost` trỏ IPv6 `::1` còn trunk nghe IPv4)? Thử **`http://127.0.0.1:8080/`** — CORS đã cho phép cả origin này. Muốn trunk nghe mọi địa chỉ: `trunk serve --address 0.0.0.0 --port 8080`.

---

## 👤 Tài khoản mặc định

Admin có sẵn ngay khi backend start. 7 seller chỉ có sau khi **seed** (Bước 3) hoặc **nạp `database.sql`**. Mật khẩu seller đều là `Seller@12345`.

| Vai trò   | Email               | Mật khẩu       | Shop            |
|-----------|---------------------|----------------|-----------------|
| Admin     | `admin@ks.com`      | `Admin@12345`  | — (tự động)     |
| Seller    | `seller1@demo.ks`   | `Seller@12345` | TechWorld Store |
| Seller    | `seller2@demo.ks`   | `Seller@12345` | GadgetHub       |
| Seller    | `iot@demo.ks`       | `Seller@12345` | IoT Depot       |
| Seller    | `ai@demo.ks`        | `Seller@12345` | Neural Forge    |
| Seller    | `security@demo.ks`  | `Seller@12345` | SecOps Armory   |
| Seller    | `sysadmin@demo.ks`  | `Seller@12345` | OpsCenter       |
| Seller    | `developer@demo.ks` | `Seller@12345` | DevTools Hub    |
| Customer  | tự đăng ký ở `/auth/register` | —    | —               |

---

## ✅ Chạy test (tuỳ chọn)

Các file `test_*.sh` là script bash. Cần **Git Bash** (đi kèm Git) hoặc **WSL**, có `jq` + `curl` trong PATH, và API đang chạy ở `:5000`. Trong **Git Bash**:

```bash
./test_phase1_api.sh     # Auth               (21 checks)
./test_phase2_api.sh     # Shop & Seller      (14 checks)
./test_phase3_api.sh     # Product & Category (27 checks)
./test_phase4_api.sh     # Cart & Checkout    (22 checks)
./test_phase5_api.sh     # Review & Rating    (15 checks)
./test_phase6_api.sh     # Admin Panel        (32 checks)
./test_chat_api.sh       # Chat realtime      (27 checks)
./test_full_api.sh       # End-to-end         (52 checks)
./test_extra_api.sh      # Các chức năng còn lại (66 checks)
```

> Không có Git Bash/WSL thì bỏ qua — test không bắt buộc để chạy ứng dụng.

### Build một lần (không chạy dev server)

```powershell
dotnet build backend\KernelStore.Api      # backend
cd frontend; trunk build                  # frontend → frontend\dist\
```

---

## 🩺 Xử lý sự cố (Windows)

- **`NetworkError when attempting to fetch resource` khi đăng ký/đăng nhập** → **backend chưa chạy** ở `:5000`. Chạy lại Bước 2 và đợi log `Now listening on: http://localhost:5000`. Kiểm tra: `curl http://localhost:5000/api/categories` phải trả JSON.
- **`link.exe`/`cc` không tìm thấy khi build frontend** → thiếu C++ Build Tools (xem Bước 0).
- **`dotnet`/`trunk`/`cargo` không nhận lệnh** → chưa mở lại terminal sau khi cài. Đóng/mở lại PowerShell.
- **`error: target 'wasm32-unknown-unknown' not found`** → chạy `rustup target add wasm32-unknown-unknown`.
- **`Cannot connect to the Docker daemon`** (Phương án A) → chưa bật Docker Desktop hoặc chưa *Running*.
- **Backend không nối được DB** → kiểm tra DB đang chạy và connection string trong `appsettings.json` là `Host=localhost;Port=5433;...`. Nếu bạn đổi cổng, sửa `Port=` cho khớp.
- **`localhost:8080` không mở được** → thử **`http://127.0.0.1:8080/`** (localhost trỏ IPv6 còn trunk nghe IPv4). Cả hai origin đều được CORS cho phép.
- **CORS bị chặn** → frontend phải chạy đúng `http://localhost:8080` hoặc `http://127.0.0.1:8080`.
- **Port bị chiếm (5000/5433/8080)** → đổi cổng ở lệnh tương ứng, hoặc tìm tiến trình: `netstat -ano | findstr :5000`.
- **Reset sạch DB** → Docker: `docker compose down -v` rồi `up -d`; native: `DROP DATABASE kernelstore;` rồi tạo lại. Sau đó seed lại hoặc nạp `database.sql`.
