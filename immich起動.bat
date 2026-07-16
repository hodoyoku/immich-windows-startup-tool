@echo off
chcp 65001 >nul
pwsh.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0src\Start-Immich.ps1"
set "exitCode=%ERRORLEVEL%"
echo.
if not "%exitCode%"=="0" echo [ERROR] Immichの起動に失敗しました。
pause
exit /b %exitCode%
