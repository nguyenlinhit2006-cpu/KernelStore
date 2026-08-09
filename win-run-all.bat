@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ================================================
echo   KernelStore - khoi dong toan bo (Windows)
echo ================================================

echo.
echo [1/4] Database (Docker)...
docker compose up -d
if errorlevel 1 (
  echo.
  echo [LOI] Docker khong chay. Hay bat Docker Desktop roi thu lai.
  pause
  exit /b 1
)

echo.
echo [2/4] Doi PostgreSQL san sang...
:waitdb
docker compose exec -T postgres pg_isready -U admin -d kernelstore >nul 2>&1
if errorlevel 1 (
  timeout /t 2 >nul
  goto waitdb
)
echo       Postgres healthy.

echo.
echo [3/4] Backend -^> http://localhost:5000 (cua so moi)
start "KernelStore Backend" cmd /k "cd /d "%~dp0" ^&^& dotnet run --project backend\KernelStore.Api --urls http://localhost:5000"

echo.
echo [4/4] Frontend -^> http://localhost:8080 (cua so moi)
start "KernelStore Frontend" cmd /k "cd /d "%~dp0frontend" ^&^& trunk serve --port 8080"

echo.
echo ================================================
echo   Da mo 2 cua so: Backend + Frontend.
echo   Doi backend in "Now listening on: http://localhost:5000"
echo   roi mo trinh duyet tai http://localhost:8080
echo ================================================
echo.
echo (Tuy chon) Seed du lieu mau: chay win-seed.bat sau khi backend da san sang.
pause
