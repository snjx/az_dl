# Azure 動画ダウンロードサイト

Azure Blob Storage の静的Webサイト機能を使って、動画の視聴＋ダウンロードができる1枚HTMLをホスティングする。

## ファイル構成

```
az_dl/
├── index.html    # 動画プレイヤー＋ダウンロードボタン
├── sample.mp4    # サンプル動画（カラーバー、約2.5MB・30秒）
├── deploy.sh     # Azureデプロイスクリプト
└── gen_video.sh  # サンプル動画の再生成スクリプト
```

## 前提条件

- [Azure CLI](https://learn.microsoft.com/ja-jp/cli/azure/install-azure-cli) がインストールされていること
- Azureサブスクリプションがあること

```bash
# Azure CLI インストール（macOS）
brew install azure-cli
```

## デプロイ手順

### 1. Azureにログイン

```bash
az login
```

### 2. Microsoft.Storage プロバイダーを登録

初回のみ必要。

```bash
az provider register --namespace Microsoft.Storage
```

登録完了を確認してから次へ進む（1〜2分かかる場合あり）:

```bash
az provider show --namespace Microsoft.Storage --query "registrationState"
# "Registered" と表示されればOK
```

### 3. デプロイ実行

```bash
bash deploy.sh
```

スクリプトが以下を自動で行う:

1. リソースグループ `rg-video-dl` を作成（リージョン: Japan East）
2. ストレージアカウントを作成
3. 静的Webサイト機能を有効化
4. `index.html` と `sample.mp4` をアップロード
5. 公開URLを表示

> **注意**: `deploy.sh` はストレージアカウント名を実行のたびにランダム生成する。
> `(SubscriptionNotFound)` エラーが出た場合はプロバイダー登録が未完了の可能性があるため、
> 手順2の確認後に再実行する。

### 4. 表示されたURLをブラウザで開く

```
https://<storage-account>.z11.web.core.windows.net/
```

動画プレイヤーとダウンロードボタンが表示される。

## 動画の差し替え

`sample.mp4` を任意の動画ファイルに置き換えてから再アップロードする。

```bash
az storage blob upload \
  --account-name <ストレージアカウント名> \
  --container-name '$web' \
  --name sample.mp4 \
  --file ./sample.mp4 \
  --content-type video/mp4 \
  --overwrite
```

## サンプル動画の再生成

ffmpeg が必要。

```bash
# ffmpeg インストール（macOS）
brew install ffmpeg

# 動画生成（カラーバー、30秒、約2.5MB）
bash gen_video.sh
```

## リソースの削除

```bash
az group delete --name rg-video-dl --yes --no-wait
```

## コスト目安

Azure Blob Storage（LRS、Japan East）の場合:

| 項目 | 目安 |
|---|---|
| ストレージ | ～0.1円/月（数MBのファイル） |
| 転送量 | 5GB/月まで無料、以降 ～11円/GB |