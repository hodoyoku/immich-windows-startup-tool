# Immich 起動スクリプト
# PowerShell 7 での実行を想定しています。

$ErrorActionPreference = "Stop"

# ===== 設定項目（導入記事の初期値） =====
$DistroName = "Ubuntu"
$ImmichDir  = "~/immich"
$PhotoPath  = "F:\ImmichData\Photos"
$ImmichUrl  = "http://localhost:8080"
# ========================================

$DockerWaitSeconds = 180
$ImmichWaitSeconds = 300

Write-Host "Immich 起動準備を開始します..."

# 導入記事では通常のUbuntuユーザーのホームに ~/immich を作成します。
# -u root を付けると ~/immich が /root/immich を指してしまうため、
# WSLの既定ユーザーでコマンドを実行します。
Write-Host "WSLディストリビューションを確認しています..."
& wsl.exe -d $DistroName -- bash -lc "exit 0"
if ($LASTEXITCODE -ne 0) {
    throw "WSLディストリビューション '$DistroName' を起動できません。PowerShellで 'wsl -l -v' を実行し、名前を確認してください。"
}

Write-Host "写真フォルダを確認しています..."
if (-not (Test-Path -LiteralPath $PhotoPath -PathType Container)) {
    throw "写真フォルダ '$PhotoPath' が見つかりません。Fドライブとフォルダ構成を確認してください。"
}
Write-Host "写真フォルダの確認OK。"

$dockerDesktop = Join-Path $Env:ProgramFiles "Docker\Docker\Docker Desktop.exe"
if (-not (Test-Path -LiteralPath $dockerDesktop -PathType Leaf)) {
    throw "Docker Desktop.exe が見つかりません。Docker Desktopのインストール先を確認してください。"
}

if (-not (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Desktop を起動します..."
    Start-Process -FilePath $dockerDesktop
} else {
    Write-Host "Docker Desktop は起動済みです。"
}

Write-Host "Ubuntu側からDockerが使えるまで待っています..."
$dockerReady = $false
$dockerTryCount = [Math]::Ceiling($DockerWaitSeconds / 2)

for ($i = 0; $i -lt $dockerTryCount; $i++) {
    & wsl.exe -d $DistroName -- bash -lc "docker info >/dev/null 2>&1"
    if ($LASTEXITCODE -eq 0) {
        $dockerReady = $true
        break
    }
    Start-Sleep -Seconds 2
}

if (-not $dockerReady) {
    throw "Ubuntu側からDockerに接続できません。Docker DesktopのWSL Integrationで '$DistroName' が有効か確認してください。"
}
Write-Host "Ubuntu側のDocker接続OK。"

Write-Host "Immichフォルダとdocker-compose.ymlを確認しています..."
& wsl.exe -d $DistroName -- bash -lc "test -d $ImmichDir && test -f $ImmichDir/docker-compose.yml"
if ($LASTEXITCODE -ne 0) {
    throw "Ubuntu側の '$ImmichDir' または docker-compose.yml が見つかりません。導入記事と同じ場所に配置されているか確認してください。"
}

Write-Host "Immich を起動します..."
& wsl.exe -d $DistroName -- bash -lc "cd $ImmichDir && docker compose up -d"
if ($LASTEXITCODE -ne 0) {
    throw "docker compose up -d に失敗しました。Ubuntuで 'cd $ImmichDir && docker compose logs --tail=120' を実行して確認してください。"
}

Write-Host "ImmichのWeb画面が応答するまで待っています..."
$immichReady = $false
$immichTryCount = [Math]::Ceiling($ImmichWaitSeconds / 2)

for ($i = 0; $i -lt $immichTryCount; $i++) {
    try {
        $response = Invoke-WebRequest -Uri $ImmichUrl -Method Get -TimeoutSec 5 -SkipHttpErrorCheck
        if ($response.StatusCode -lt 500) {
            $immichReady = $true
            break
        }
    } catch {
        # 起動途中は接続できないため、そのまま再試行します。
    }
    Start-Sleep -Seconds 2
}

& wsl.exe -d $DistroName -- bash -lc "cd $ImmichDir && docker compose ps"

if (-not $immichReady) {
    throw "ImmichのWeb画面が '$ImmichUrl' で応答しませんでした。ポート設定とdocker composeの状態を確認してください。"
}

Write-Host ""
Write-Host "Immich 起動完了。"
Write-Host "ブラウザで $ImmichUrl を開きます。"
Start-Process $ImmichUrl
