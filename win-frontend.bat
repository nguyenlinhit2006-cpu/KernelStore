@echo off
chcp 65001 >nul
cd /d "%~dp0frontend"
echo === KernelStore: Frontend (Leptos + Trunk) -^> http://localhost:8080 ===
echo (De cua so nay chay. Dung bang Ctrl + C.)
echo.
trunk serve --port 8080
pause
