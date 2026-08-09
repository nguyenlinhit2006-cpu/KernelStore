@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo === KernelStore: Backend API -^> http://localhost:5000 ===
echo (De cua so nay chay. Dung bang Ctrl + C.)
echo.
dotnet run --project backend\KernelStore.Api --urls http://localhost:5000
pause
