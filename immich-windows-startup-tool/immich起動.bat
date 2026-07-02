@echo off
chcp 65001 >nul

pwsh.exe -ExecutionPolicy Bypass -File "%~dp0src\Start-Immich.ps1"

if errorlevel 1 (
    echo.
    echo エラーが発生しました。内容を確認してください。
    pause
)