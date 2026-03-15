# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

Azure Blob Storage の静的Webサイト機能を使って、動画の視聴＋ダウンロードページをホスティングするプロジェクト。サーバー不要で `index.html` と `sample.mp4` を `$web` コンテナに置くだけで動作する。

## デプロイ

```bash
# 前提: az login 済み、Microsoft.Storage プロバイダー登録済み
bash deploy.sh
```

`deploy.sh` はストレージアカウント名をランダム生成するため、実行のたびに新しいアカウントが作られる。既存アカウントに再アップロードしたい場合は `az storage blob upload` を直接実行する。

## サンプル動画の再生成

```bash
# 前提: ffmpeg インストール済み (brew install ffmpeg)
bash gen_video.sh
```

## リソース削除

```bash
az group delete --name rg-video-dl --yes --no-wait
```

## Azure 構成

- **リソースグループ**: `rg-video-dl`（Japan East）
- **ストレージ**: Standard_LRS / StorageV2、静的Webサイト有効
- **公開コンテナ**: `$web`（index.html, sample.mp4 を配置）
