# Immich 停止スクリプト
# PowerShell 7 での実行を想定しています。

$ErrorActionPreference = "Stop"

# ===== 設定項目（導入記事の初期値） =====
$DistroName = "Ubuntu"
$ImmichDir  = "~/immich"

# Immich停止後にDocker Desktopも終了する場合は $true
$QuitDockerDesktop = $true

# 他のWSL環境もまとめて停止するため、通常は $false 推奨
$ShutdownWsl = $false
# ========================================

Write-Host "Immich を停止します..."

# 起動時と同じく、通常のUbuntuユーザーで実行します。
& wsl.exe -d $DistroName -- bash -lc "cd $ImmichDir && docker compose down"
if ($LASTEXITCODE -ne 0) {
    throw "docker compose down に失敗しました。WSL名とImmichフォルダを確認してください。"
}

Write-Host "Immich関連コンテナを停止しました。"

if ($QuitDockerDesktop) {
    Write-Host "Docker Desktop を終了します..."
    $dockerDesktopProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
    if ($dockerDesktopProcess) {
        $dockerDesktopProcess | Stop-Process
    } else {
        Write-Host "Docker Desktop はすでに終了しています。"
    }
}

if ($ShutdownWsl) {
    Write-Host "WSLを停止します..."
    & wsl.exe --shutdown
    if ($LASTEXITCODE -ne 0) {
        throw "wsl --shutdown に失敗しました。"
    }
}

Write-Host ""
Write-Host "Immich 停止完了。"
