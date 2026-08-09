@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo === KernelStore: Seed du lieu mau ===
echo (Can Postgres dang chay. Idempotent - chay lai se bao "already present".)
echo.
dotnet run --project backend\KernelStore.Api --no-launch-profile seed
echo.
echo Da seed: 5 danh muc, 2 shop (Approved), 8 san pham.
pause
