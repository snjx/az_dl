#!/bin/bash
# ffmpeg でカラーバー動画を生成 (約3MB, 30秒)
#
# 【使い方】
#   bash gen_video.sh
#   出力: sample.mp4（同じディレクトリに生成）
#
# 【オプション解説】
#   -f lavfi
#     入力ソースとして libavfilter（仮想デバイス）を使用する
#
#   -i "testsrc=duration=10:size=1280x720:rate=30"
#     映像ソース: ffmpeg 組み込みのカラーバーテストパターン
#       duration  : 動画の長さ（秒）
#       size      : 解像度（1280x720 = HD）
#       rate      : フレームレート（30fps）
#
#   -i "sine=frequency=440:duration=10"
#     音声ソース: 440Hz のサイン波（ラ音）を生成
#       frequency : 音の周波数（Hz）
#       duration  : 音声の長さ（秒）
#
#   -c:v libx264
#     映像コーデック: H.264 で圧縮
#
#   -preset fast
#     エンコード速度と圧縮率のバランス設定（fast = 速度優先）
#
#   -b:v 600k
#     映像ビットレートを 600kbps に指定（ファイルサイズの調整）
#
#   -c:a aac
#     音声コーデック: AAC で圧縮
#
#   -b:a 64k
#     音声ビットレートを 64kbps に指定
#
#   -pix_fmt yuv420p
#     ピクセルフォーマットを YUV 4:2:0 に変換
#     ブラウザや一般的なプレイヤーとの互換性のために必要
#
#   -y
#     出力ファイルが既に存在する場合、確認なしで上書き

ffmpeg -f lavfi -i "testsrc2=duration=30:size=1280x720:rate=30" \
       -f lavfi -i "sine=frequency=440:duration=30" \
       -c:v libx264 -preset fast -b:v 600k \
       -c:a aac -b:a 64k \
       -pix_fmt yuv420p \
       -y sample.mp4

echo "生成完了: $(du -sh sample.mp4)"
