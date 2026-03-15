# 既存アカウント・ドメインへの追加デプロイ

このプロジェクトは新規アカウントで動作確認したが、実運用では既存のAzureアカウントや
ドメインに相乗りする形で構成するのが望ましい。

---

## パターン1: 既存ストレージアカウントのサブディレクトリに置く

既に静的Webサイト機能が有効なストレージアカウントがある場合、
`$web` コンテナ内のサブディレクトリにファイルを置くだけで動作する。

### 手順

```bash
STORAGE_ACCOUNT="既存のストレージアカウント名"

# index.html を /video/ 以下に配置
az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name '$web' \
  --name "video/index.html" \
  --file ./index.html \
  --content-type "text/html" \
  --overwrite

# sample.mp4 を /video/ 以下に配置
az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name '$web' \
  --name "video/sample.mp4" \
  --file ./sample.mp4 \
  --content-type "video/mp4" \
  --overwrite
```

### アクセスURL

```
https://<storage-account>.z11.web.core.windows.net/video/
```

### 注意事項

- `index.html` 内の `src="sample.mp4"` と `href="sample.mp4"` は相対パスのままでOK
- 既存サイトの `index.html` やルートの構成に影響しない

---

## パターン2: カスタムドメイン（サブドメイン）を使う

Azure Blob Storage の静的Webサイトは **HTTPSカスタムドメインに直接は対応していない**。
カスタムドメインでHTTPSを使うには **Azure CDN** または **Azure Front Door** を経由させる必要がある。

### 構成例

```
https://dl.example.com/  →  Azure CDN  →  Blob Storage ($web)
```

### 手順概要

1. **Azure CDN プロファイルを作成**（既存があればスキップ）
2. **CDN エンドポイントを追加**し、配信元にストレージの静的Webサイト URL を指定
3. **カスタムドメインを追加**（`dl.example.com` など）
4. **DNS に CNAME レコードを追加**（ドメイン管理サービスで設定）
5. **CDN 上でHTTPS（カスタム証明書）を有効化**

```bash
# CDN プロファイル作成（Standard_Microsoft を推奨）
az cdn profile create \
  --name "cdn-video" \
  --resource-group "rg-video-dl" \
  --sku Standard_Microsoft

# CDN エンドポイント作成
az cdn endpoint create \
  --name "video-endpoint" \
  --profile-name "cdn-video" \
  --resource-group "rg-video-dl" \
  --origin "<storage-account>.z11.web.core.windows.net" \
  --origin-host-header "<storage-account>.z11.web.core.windows.net"

# カスタムドメイン追加
az cdn custom-domain create \
  --endpoint-name "video-endpoint" \
  --profile-name "cdn-video" \
  --resource-group "rg-video-dl" \
  --name "dl-example-com" \
  --hostname "dl.example.com"
```

### 注意事項

- DNS の TTL によっては反映に数十分〜数時間かかる
- HTTPS 有効化は CDN 側で行う（証明書は Azure が自動発行）
- Azure CDN Standard_Microsoft は **2027年9月30日に廃止予定**。
  新規構築なら **Azure Front Door** の使用を検討すること

---

## 既存アカウントに対して作業する際の共通注意事項

| 項目 | 注意 |
|---|---|
| 権限 | ストレージアカウントの `Storage Blob Data Contributor` ロールが必要 |
| 静的Webサイト機能 | 既存アカウントで有効化されているか事前に確認する |
| ファイル上書き | `--overwrite` オプションで既存ファイルを上書きするため、本番環境では注意 |
| キャッシュ | CDN を使っている場合、アップロード後にキャッシュのパージが必要な場合がある |
| CORS | 動画を別オリジンから参照する場合は CORS 設定が必要 |

### 権限確認コマンド

```bash
# 自分のアカウントに割り当てられているロールを確認
az role assignment list --assignee <your-email> --output table
```

### CDN キャッシュのパージ

```bash
az cdn endpoint purge \
  --resource-group "rg-video-dl" \
  --profile-name "cdn-video" \
  --name "video-endpoint" \
  --content-paths "/*"
```
