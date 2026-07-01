#!/bin/bash
# 检测UP主「_向阳阳阳阳」的新视频
# 用法: bash check_new_videos.sh

BILIBILI_UID=3706966528494365
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
REFERER='https://www.bilibili.com'

echo "=== 检测 _向阳阳阳阳 的新视频 ==="
echo ""

result=$(curl -s --max-time 15 \
  "https://api.bilibili.com/x/space/arc/search?mid=$BILIBILI_UID&ps=30&pn=1&order=pubdate" \
  -H "User-Agent: $UA" -H "Referer: $REFERER" 2>/dev/null)

code=$(echo "$result" | python3 -c "import json,sys; print(json.load(sys.stdin).get('code',999))" 2>/dev/null)

if [ "$code" != "0" ]; then
  echo "API请求失败（code: $code），可能被风控"
  echo "请手动访问: https://space.bilibili.com/$BILIBILI_UID/video"
  exit 1
fi

echo "$result" | python3 -c "
import json, sys
from datetime import datetime

data = json.load(sys.stdin)
vlist = data.get('data', {}).get('list', {}).get('vlist', [])

for v in vlist:
    bvid = v.get('bvid', '')
    title = v.get('title', '')
    created = v.get('created', 0)
    length = v.get('length', '')
    date_str = datetime.fromtimestamp(created).strftime('%m-%d')
    print(f'  {date_str} | {bvid} | {length} | {title}')
" 2>/dev/null

echo ""
echo "将以上列表与已有方法论对比，找出未处理的视频。"
