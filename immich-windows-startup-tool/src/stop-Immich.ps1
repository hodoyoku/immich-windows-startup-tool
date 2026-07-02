# ============================================================
# Immich 停止スクリプト
# Windows + Docker Desktop + WSL2(Ubuntu) 環境向け
#
# このスクリプトで行うこと:
# 1. Immich関連コンテナを停止
# 2. Docker Desktopを終了
#
# 推奨:
# ・PowerShell 7 で実行
# ・文字コードは UTF-8 with BOM で保存
# ============================================================

$ErrorActionPreference = "Stop"

# ============================================================
# 設定項目
# 環境に合わせて必要ならここだけ変更してください
# ============================================================

# WSLのUbuntu名
# 確認コマンド: wsl -l -v
$DistroName = "Ubuntu"

# Ubuntu内のImmichフォルダ
# 通常は ~/immich のままでOK
$ImmichDir = "~/immich"

# Immich停止後にDocker Desktopも終了するか
# true  = Docker Desktopも終了する
# false = Immichだけ停止する
$QuitDockerDesktop = $true

# Docker Desktop終了後にWSLも停止するか
# true  = wsl --shutdown も実行する
# false = WSLはそのまま
#
# 注意:
# trueにすると他のWSL作業中のUbuntuも止まります。
# Immich専用で使っている場合だけtrue推奨。
$ShutdownWsl = $false

# ============================================================
# 停止処理開始
# ============================================================

Write-Host "Immich を停止します..."

# Immich関連コンテナを停止
wsl -d $DistroName -u root -- bash -lc "cd $ImmichDir && docker compose down"

Write-Host ""
Write-Host "Immich 停止完了。"

# Docker Desktopも終了する設定の場合
if ($QuitDockerDesktop) {
    Write-Host ""
    Write-Host "Docker Desktop を終了します..."

    # Docker Desktop本体を終了
    taskkill /IM "Docker Desktop.exe" /F /T 2>$null

    Start-Sleep -Seconds 3

    # Docker Desktopのバックエンドも終了
    # タスクトレイに残る場合はここまで止める
    taskkill /IM "com.docker.backend.exe" /F /T 2>$null
    taskkill /IM "com.docker.proxy.exe" /F /T 2>$null
    taskkill /IM "com.docker.wsl-distro-proxy.exe" /F /T 2>$null

    Write-Host "Docker Desktop 終了処理完了。"
}

# WSLも停止する設定の場合
if ($ShutdownWsl) {
    Write-Host ""
    Write-Host "WSL を停止します..."

    wsl --shutdown

    Write-Host "WSL 停止完了。"
}

Write-Host ""
Write-Host "すべての停止処理が完了しました。"

exit 0