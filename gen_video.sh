#!/bin/bash
# ffmpeg でカラーバー動画を生成 (約3MB, 10秒)
ffmpeg -f lavfi -i "testsrc=duration=10:size=1280x720:rate=30" \
       -f lavfi -i "sine=frequency=440:duration=10" \
       -c:v libx264 -preset fast -crf 28 \
       -c:a aac -b:a 64k \
       -pix_fmt yuv420p \
       -y sample.mp4

echo "生成完了: $(du -sh sample.mp4)"
