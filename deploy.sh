#!/bin/bash
set -e

# ===== 設定 =====
RESOURCE_GROUP="rg-video-dl"
LOCATION="japaneast"
STORAGE_ACCOUNT="stvideodl$(head -c4 /dev/urandom | xxd -p)"  # ユニーク名 (3〜24文字、英数字のみ)
# ================

echo "=== Azure 静的Webサイトのデプロイ ==="
echo "リソースグループ: $RESOURCE_GROUP"
echo "ストレージアカウント: $STORAGE_ACCOUNT"
echo ""

# 1. リソースグループ作成
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

# 2. ストレージアカウント作成
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access true

# 3. 静的Webサイト機能を有効化
az storage blob service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --static-website \
  --index-document index.html \
  --404-document index.html

# 4. ファイルをアップロード
az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "\$web" \
  --name "index.html" \
  --file "./index.html" \
  --content-type "text/html" \
  --overwrite

az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "\$web" \
  --name "sample.mp4" \
  --file "./sample.mp4" \
  --content-type "video/mp4" \
  --overwrite

# 5. URLを表示
URL=$(az storage account show \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --query "primaryEndpoints.web" \
  --output tsv)

echo ""
echo "=== デプロイ完了 ==="
echo "URL: $URL"
echo ""
echo "削除する場合:"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
