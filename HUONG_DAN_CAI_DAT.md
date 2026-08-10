# Hướng dẫn cài đặt Database — KernelStore

Database dùng **PostgreSQL 16**. File `database.sql` chứa toàn bộ cấu trúc bảng và dữ liệu.
Có 2 cách phục hồi (restore) database từ file này. Chọn **một** cách phù hợp.

Thông tin kết nối mặc định của đồ án:

| Thông số        | Giá trị       |
|-----------------|---------------|
| Database name   | `kernelstore` |
| Username        | `admin`       |
| Password        | `admin123`    |
| Host / Port     | `localhost` / `5433` |

> Lưu ý port: đồ án map cổng **5433** trên máy → 5432 trong container (xem `docker-compose.yml`),
> và backend kết nối tới `Port=5433`. Nếu bạn dùng PostgreSQL cài trực tiếp (Cách 2) chạy ở cổng
> mặc định `5432`, hãy sửa `Port=5433` thành `Port=5432` trong `appsettings.json`.

---

## Cách 1 — Dùng Docker (giống môi trường phát triển)

Yêu cầu: đã cài **Docker Desktop**.

```bash
# 1. Khởi tạo và chạy Postgres trong container
docker run --name kernelstore-postgres \
  -e POSTGRES_DB=kernelstore \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin123 \
  -p 5433:5432 -d postgres:16-alpine

# 2. Chờ vài giây cho container khởi động, rồi nạp dữ liệu từ file .sql
docker exec -i kernelstore-postgres psql -U admin -d kernelstore < database.sql
```

> Windows (PowerShell): thay `< database.sql` bằng `-c "$(Get-Content database.sql -Raw)"`
> hoặc chạy: `Get-Content database.sql | docker exec -i kernelstore-postgres psql -U admin -d kernelstore`

---

## Cách 2 — Dùng PostgreSQL cài trực tiếp trên máy (KHÔNG cần Docker)

Yêu cầu: đã cài **PostgreSQL 16** (kèm công cụ `psql`).

```bash
# 1. Tạo user và database (chạy bằng tài khoản postgres)
psql -U postgres -c "CREATE USER admin WITH PASSWORD 'admin123';"
psql -U postgres -c "CREATE DATABASE kernelstore OWNER admin;"

# 2. Nạp dữ liệu từ file .sql
psql -U admin -d kernelstore -f database.sql
```

Hoặc dùng **pgAdmin** (giao diện đồ họa):
1. Tạo database tên `kernelstore`.
2. Chuột phải database → **Restore** (hoặc **Query Tool** → mở `database.sql` → Run).

---

## Kiểm tra sau khi cài

```bash
psql -U admin -d kernelstore -c "\dt"
```

Kết quả phải thấy các bảng: `Products`, `Categories`, `Shops`, `Orders`, `AspNetUsers`, ...
(tổng cộng 19 bảng). Nếu thấy đủ bảng và có dữ liệu là đã cài thành công.

---

## Kết nối từ backend

Chuỗi kết nối (connection string) trong `backend/KernelStore.Api/appsettings.json`:

```
Host=localhost;Port=5433;Database=kernelstore;Username=admin;Password=admin123
```
