# ============================================================
# Immich 起動スクリプト
# Windows + Docker Desktop + WSL2(Ubuntu) 環境向け
#
# このスクリプトで行うこと:
# 1. Docker Desktop の起動確認
# 2. 写真保存先ドライブの確認
# 3. Ubuntu側からDockerが使えるか確認
# 4. Immichを起動
# 5. Immich Serverがhealthyになるまで待機
# 6. ブラウザでImmichを開く
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

# 写真・動画の保存先
# 自分の環境に合わせて変更してください
$PhotoPath = "F:\Photos"

# Immichを開くURL
# docker-compose.ymlで 8080:2283 にしている場合はこのままでOK
$ImmichUrl = "http://localhost:8080"

# ============================================================
# 起動処理開始
# ============================================================

Write-Host "Immich 起動準備を開始します..."

# Docker Desktop の実行ファイルパス
$dockerDesktop = "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"

# Docker Desktop がインストールされているか確認
if (-not (Test-Path $dockerDesktop)) {
    throw "Docker Desktop.exe が見つかりません。インストール場所を確認してください。"
}

# Docker Desktop が起動していなければ起動する
if (-not (Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Desktop を起動します..."
    Start-Process $dockerDesktop
} else {
    Write-Host "Docker Desktop は起動済みです。"
}

# 写真保存先ドライブを確認
Write-Host "写真保存先を確認しています..."

if (-not (Test-Path $PhotoPath)) {
    throw "$PhotoPath が見つかりません。保存先ドライブが認識されているか確認してください。"
}

Write-Host "写真保存先の確認OK。"

# Ubuntu側からDockerが使えるようになるまで待機
Write-Host "Ubuntu側のDocker接続を待っています..."

$wslDockerReady = $false

for ($i = 0; $i -lt 90; $i++) {
    wsl -d $DistroName -u root -- bash -lc "docker ps >/dev/null 2>&1"

    if ($LASTEXITCODE -eq 0) {
        $wslDockerReady = $true
        break
    }

    Start-Sleep -Seconds 2
}

# Dockerに接続できなかった場合はエラー
if (-not $wslDockerReady) {
    throw "Ubuntu側からDockerに接続できません。Docker DesktopのWSL Integrationを確認してください。"
}

Write-Host "Ubuntu側のDocker接続OK。"

# Immichを起動
Write-Host "Immich を起動します..."

wsl -d $DistroName -u root -- bash -lc "cd $ImmichDir && docker compose up -d"

# Immich Server が healthy になるまで待機
Write-Host "Immich Server が healthy になるまで待っています..."

$immichReady = $false

for ($i = 0; $i -lt 90; $i++) {
    wsl -d $DistroName -u root -- bash -lc "docker inspect -f '{{.State.Health.Status}}' immich_server 2>/dev/null | grep -q healthy"

    if ($LASTEXITCODE -eq 0) {
        $immichReady = $true
        break
    }

    Start-Sleep -Seconds 2
}

# 現在のコンテナ状態を表示
wsl -d $DistroName -u root -- bash -lc "cd $ImmichDir && docker compose ps"

# healthyにならなかった場合はエラー
if (-not $immichReady) {
    throw "Immich Server が healthy になりませんでした。docker compose logs を確認してください。"
}

# 起動完了
Write-Host ""
Write-Host "Immich 起動完了。"
Write-Host "ブラウザで $ImmichUrl を開きます。"

# ブラウザでImmichを開く
Start-Process $ImmichUrl

exit 0