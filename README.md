# Immich Windows Startup Tool

WindowsメインPC上の **Docker Desktop + WSL2 + Ubuntu** で動かしているImmichを、BATファイルのダブルクリックで起動・停止するための補助ツールです。

Windows 10／11に標準搭載されている **Windows PowerShell 5.1** で動作します。PowerShell 7の追加インストールは不要です。

## 必要な環境

- Windows 10／11
- Docker Desktop
- WSL2
- Ubuntu
- Windows PowerShell 5.1以降（Windows標準。PowerShell 7は不要）
- 導入済みのImmichと `docker-compose.yml`

## 初期設定

このリポジトリの初期値は、「ほどよくPC生活」のImmich導入記事に合わせています。

```powershell
$DistroName = "Ubuntu"
$ImmichDir  = "~/immich"
$PhotoPath  = "F:\ImmichData\Photos"
$ImmichUrl  = "http://localhost:8080"
```

記事と違う構成で導入している場合は、`src/Start-Immich.ps1` と `src/Stop-Immich.ps1` の設定項目を変更してください。

## 使い方

1. ZIPを解凍する
2. フォルダごと任意の場所へ置く（例：`C:\Immich`）
3. `Immich起動.bat` をダブルクリックする
4. 使用後は `Immich停止.bat` をダブルクリックする

## ファイル構成

```text
Immich起動.bat
Immich停止.bat
README.html
README.md
src/
├─ Start-Immich.ps1
└─ Stop-Immich.ps1
```

## 起動時に行うこと

- Docker Desktopの起動確認
- `F:\ImmichData\Photos` の存在確認
- Ubuntu側からDockerが使えるまで待機
- `~/immich` の `docker-compose.yml` を確認
- `docker compose up -d` を実行
- `http://localhost:8080` が応答するまで待機
- ブラウザを開く

## 重要：rootユーザーでは実行しません

導入記事では、Immichを通常のUbuntuユーザーの `~/immich` に配置しています。

WSLコマンドに `-u root` を付けると、`~/immich` は `/root/immich` を指してしまいます。このツールでは、WSLの既定ユーザーでDockerコマンドを実行します。

## 環境が違う場合

Ubuntu名はPowerShellで確認できます。

```powershell
wsl -l -v
```

例として `Ubuntu-24.04` と表示される場合は、両方のPowerShellスクリプトを次のように変更します。

```powershell
$DistroName = "Ubuntu-24.04"
```

ポートを `2283:2283` のまま使っている場合は、次のように変更します。

```powershell
$ImmichUrl = "http://localhost:2283"
```

## 停止設定

`src/Stop-Immich.ps1` では、停止後の動作を変更できます。

```powershell
$QuitDockerDesktop = $true
$ShutdownWsl = $false
```

Docker DesktopでImmich以外のコンテナも動かしている場合は、`$QuitDockerDesktop = $false` にしてください。

`$ShutdownWsl = $true` にすると、他のWSL環境も含めて停止します。通常は `$false` のままを推奨します。
