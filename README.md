# Immich Windows Startup Tool

WindowsメインPC上で、Docker Desktop + WSL2 + Ubuntu 環境のImmichを起動・停止するための補助スクリプトです。

毎回Ubuntuを開いて `cd ~/immich` → `docker compose up -d` と入力する手間を減らし、batファイルのダブルクリックでImmichを起動・停止できるようにすることを目的にしています。

## 注意

使用前に、`src\start-immich.ps1` と `src\stop-immich.ps1` の設定項目を自分の環境に合わせて確認してください。

特に以下の項目は環境によって変更が必要です。

```powershell
$DistroName = "Ubuntu"
$PhotoPath = "F:\Photos"
$ImmichUrl = "http://localhost:8080"
```

## 同梱ファイル

```text
Immich起動.bat
Immich停止.bat
README.html
src/
├─ start-immich.ps1
└─ stop-immich.ps1
```

通常使用するのは、以下の2つだけです。

```text
Immich起動.bat
Immich停止.bat
```

`src` フォルダ内の `.ps1` ファイルは、実際の処理を行うPowerShellスクリプトです。

## 使い方

### Immichを起動する

`Immich起動.bat` をダブルクリックします。

内部では以下の処理を行います。

```text
Docker Desktopの起動確認
写真保存先ドライブの確認
Ubuntu側のDocker接続確認
Immichの起動
Immich Serverのhealthy待ち
ブラウザでImmichを開く
```

起動に成功すると、ブラウザでImmichが開きます。

### Immichを停止する

`Immich停止.bat` をダブルクリックします。

内部では以下の処理を行います。

```text
docker compose down
Docker Desktopの終了
必要に応じてWSL停止
```

初期設定では、Immich停止後にDocker Desktopも終了する設定になっています。

## 必要な環境

このツールは、以下の環境を前提にしています。

```text
Windows
Docker Desktop
WSL2
Ubuntu
PowerShell 7
Immichのdocker-compose.yml一式
```

PowerShell 7が入っているか確認するには、PowerShellで以下を実行します。

```powershell
pwsh -v
```

`PowerShell 7.x.x` のように表示されればOKです。

PowerShell 7が入っていない場合は、先にインストールしてください。

## フォルダ配置

ZIPを解凍したら、フォルダごと以下の場所に配置する想定です。

```text
C:\Immich
```

配置例:

```text
C:\Immich\
├─ Immich起動.bat
├─ Immich停止.bat
├─ README.html
└─ src\
   ├─ start-immich.ps1
   └─ stop-immich.ps1
```

batファイルは、同じフォルダ内の `src` フォルダにあるPowerShellスクリプトを呼び出します。

## start-immich.ps1 の設定項目

`src\start-immich.ps1` の上部にある設定項目です。

```powershell
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
```

### $DistroName

WSLのUbuntu名です。

PowerShellで以下を実行すると確認できます。

```powershell
wsl -l -v
```

表示例:

```text
NAME            STATE           VERSION
* Ubuntu        Running         2
```

この場合は、以下のままでOKです。

```powershell
$DistroName = "Ubuntu"
```

もし表示名が `Ubuntu-24.04` などになっている場合は、スクリプト側も同じ名前に変更してください。

例:

```powershell
$DistroName = "Ubuntu-24.04"
```

### $ImmichDir

Ubuntu内のImmichフォルダです。

この記事の構成では、通常以下のままでOKです。

```powershell
$ImmichDir = "~/immich"
```

もしImmichの `docker-compose.yml` を別の場所に置いている場合は、そのパスに変更してください。

例:

```powershell
$ImmichDir = "/home/ユーザー名/immich"
```

### $PhotoPath

Windows上の写真・動画保存先です。

初期設定では以下にしています。

```powershell
$PhotoPath = "F:\Photos"
```

別の場所に保存している場合は、自分の環境に合わせて変更してください。

例:

```powershell
$PhotoPath = "D:\ImmichPhotos"
```

Windows上の `F:\Photos` は、WSL / Ubuntu上では通常以下のように見えます。

```bash
/mnt/f/Photos
```

Immich側の `.env` や `docker-compose.yml` で指定している保存先とも一致しているか確認してください。

例:

```env
UPLOAD_LOCATION=/mnt/f/Photos
```

### $ImmichUrl

ブラウザで開くImmichのURLです。

docker-compose.ymlで以下のように設定している場合、

```yaml
ports:
  - 8080:2283
```

以下のままでOKです。

```powershell
$ImmichUrl = "http://localhost:8080"
```

ポート番号を変更している場合は、URLも変更してください。

例:

```powershell
$ImmichUrl = "http://localhost:2283"
```

## stop-immich.ps1 の設定項目

`src\stop-immich.ps1` の上部にある設定項目です。

```powershell
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
$ShutdownWsl = $false
```

### $DistroName

WSLのUbuntu名です。

`start-immich.ps1` と同じ値にしてください。

```powershell
$DistroName = "Ubuntu"
```

Ubuntu名が違う場合は、こちらも変更してください。

例:

```powershell
$DistroName = "Ubuntu-24.04"
```

### $ImmichDir

Ubuntu内のImmichフォルダです。

`start-immich.ps1` と同じ値にしてください。

```powershell
$ImmichDir = "~/immich"
```

### $QuitDockerDesktop

Immich停止後にDocker Desktopも終了するかどうかを指定します。

初期設定では、Docker Desktopも終了します。

```powershell
$QuitDockerDesktop = $true
```

Docker DesktopでImmich以外のコンテナも動かしている場合は、以下に変更してください。

```powershell
$QuitDockerDesktop = $false
```

`$false` にすると、Immich関連コンテナだけを停止し、Docker Desktopは起動したままになります。

### $ShutdownWsl

停止時にWSLもまとめて停止するかどうかを指定します。

初期設定では、WSLは停止しません。

```powershell
$ShutdownWsl = $false
```

WSLも停止したい場合は、以下に変更してください。

```powershell
$ShutdownWsl = $true
```

ただし、これを有効にすると他のWSL作業中のUbuntuも停止します。

Immich専用で使っている場合のみ有効化してください。

## batファイルについて

### Immich起動.bat

`Immich起動.bat` は、PowerShell 7を使って `src\start-immich.ps1` を実行します。

例:

```bat
@echo off
chcp 65001 >nul

pwsh.exe -ExecutionPolicy Bypass -File "%~dp0src\start-immich.ps1"

if errorlevel 1 (
    echo.
    echo エラーが発生しました。内容を確認してください。
    pause
)
```

成功時は自動で閉じ、エラー時だけ画面を残します。

### Immich停止.bat

`Immich停止.bat` は、PowerShell 7を使って `src\stop-immich.ps1` を実行します。

例:

```bat
@echo off
chcp 65001 >nul

pwsh.exe -ExecutionPolicy Bypass -File "%~dp0src\stop-immich.ps1"

if errorlevel 1 (
    echo.
    echo エラーが発生しました。内容を確認してください。
    pause
)
```

成功時は自動で閉じ、エラー時だけ画面を残します。

## 起動時に行う処理

`Immich起動.bat` を実行すると、以下の処理を行います。

```text
1. Docker Desktopが起動しているか確認
2. 起動していなければDocker Desktopを起動
3. 写真保存先ドライブが見えるか確認
4. Ubuntu側からDockerが使えるまで待機
5. docker compose up -d でImmichを起動
6. immich_server が healthy になるまで待機
7. docker compose ps で状態を表示
8. ブラウザでImmichを開く
```

## 停止時に行う処理

`Immich停止.bat` を実行すると、以下の処理を行います。

```text
1. docker compose down でImmich関連コンテナを停止
2. 設定に応じてDocker Desktopを終了
3. 設定に応じてWSLを停止
```

## Docker Desktopを終了したくない場合

Immich以外のDockerコンテナも使っている場合、停止時にDocker Desktopを終了すると他の作業にも影響します。

その場合は、`src\stop-immich.ps1` の以下を変更してください。

```powershell
$QuitDockerDesktop = $false
```

## WSLも停止したい場合

停止時にWSLもまとめて停止したい場合は、`src\stop-immich.ps1` の以下を変更してください。

```powershell
$ShutdownWsl = $true
```

ただし、これを有効にすると他のWSL作業中のUbuntuも停止します。

## トラブル時の確認

### Ubuntu側でDockerが使えない場合

Docker DesktopのWSL Integrationを確認してください。

```text
Docker Desktop
Settings
Resources
WSL Integration
Ubuntu を ON
Apply & Restart
```

その後、PowerShellで以下を実行してWSLを再起動します。

```powershell
wsl --shutdown
```

再度Docker Desktopを起動し、Ubuntu側でDockerが使えるか確認してください。

```bash
docker ps
```

### Ubuntu名が違う場合

PowerShellで以下を実行してください。

```powershell
wsl -l -v
```

表示されたUbuntu名に合わせて、以下を変更してください。

```powershell
$DistroName = "Ubuntu"
```

### 写真保存先が見つからない場合

`src\start-immich.ps1` の `$PhotoPath` が自分の環境と合っているか確認してください。

```powershell
$PhotoPath = "F:\Photos"
```

写真保存先のドライブが認識されているかも確認してください。

### Immichが起動しない場合

Ubuntuで以下を実行して状態を確認してください。

```bash
cd ~/immich
docker compose ps
docker compose logs --tail=120 immich-server
docker compose logs --tail=120 database
```

### PowerShell 7が見つからない場合

PowerShellで以下を実行してください。

```powershell
pwsh -v
```

`pwsh` が見つからない場合は、PowerShell 7がインストールされていません。

PowerShell 7をインストールしてから再度実行してください。

## このツールの想定用途

このツールは、常時稼働サーバーではなく、WindowsメインPCで必要な時だけImmichを使う環境向けです。

専用サーバーで常時稼働させる場合は、Dockerの自動起動やsystemd管理の方が向いている場合があります。

## 注意事項

このツールはDocker Desktop自体を操作します。

Docker DesktopでImmich以外のコンテナも動かしている場合は、停止スクリプトの設定に注意してください。

```powershell
$QuitDockerDesktop = $false
```

に変更することで、Docker Desktop自体は終了せず、Immich関連コンテナのみ停止できます。

## 免責事項

このツールの使用によって発生したトラブル、データ損失、環境破損、その他いかなる損害についても、作者は責任を負いません。

自己責任でご利用ください。

## 著作権

このツールの著作権は作者に帰属します。

個人利用の範囲での利用・編集は自由ですが、無断での再配布・転載・商用利用はご遠慮ください。

## 再配布について

改変版の再配布や転載はご遠慮ください。

共有する場合は、配布元の記事またはGitHubリポジトリへのリンクを使用してください。

## 連絡先

問題報告や質問は、配布記事内のコメント欄、メール、またはGitHubリポジトリのIssueからお願いします。
