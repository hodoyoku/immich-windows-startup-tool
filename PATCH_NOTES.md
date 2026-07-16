# 修正内容

- `$PhotoPath` を `F:\ImmichData\Photos` に変更
- `$DistroName = "Ubuntu"`、`$ImmichDir = "~/immich"`、`$ImmichUrl = "http://localhost:8080"` を導入記事の初期値として明記
- WSLコマンドから `-u root` を外し、導入記事で作成した通常ユーザー側の `~/immich` を参照するよう修正
- 起動完了判定を固定コンテナ名ではなくWeb画面の応答確認に変更
- BATとPowerShellの二重 `pause` を解消
- README.htmlとREADME.mdの設定内容を導入記事に統一
- BATの呼び出し先を `pwsh.exe` からWindows標準の `powershell.exe` に変更
- `Invoke-WebRequest` のPowerShell 7専用オプションを削除し、PowerShell 5.1対応の `-UseBasicParsing` に変更
- PowerShell 7の追加インストールを不要化
- READMEの必要環境をWindows PowerShell 5.1以降へ更新
