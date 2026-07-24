#!/usr/bin/env bash
set -euo pipefail
PROMPT="" VIDEOS="[]"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt) PROMPT="${2:-}"; shift 2 ;;
    --videos) VIDEOS="${2:-[]}"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$PROMPT" ]] || { echo "用法: extract.sh --prompt TEXT --videos JSON数组" >&2; exit 1; }
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"videos":json.loads(sys.argv[2]),"platform":1,"terminal":4,"language":"zh-CN"},ensure_ascii=False))' "$PROMPT" "$VIDEOS")
curl -sN -X POST "https://www.clawec.com/api/aigc/ec_media/video/info/extract" \
  -H "Token: $TOKEN" -H "Content-Type: application/json" -H "Time-Zone: Asia/Shanghai" \
  -d "$PAYLOAD" | python3 -c '
import sys
buf = ""
for raw in sys.stdin:
    line = raw.rstrip("\r\n")
    if not line.startswith("data:"):
        continue
    chunk = line[5:].lstrip().replace("\\x0A", "\n")
    if not chunk:
        continue
    if chunk.startswith(buf):
        buf = chunk
    elif buf.endswith(chunk):
        pass
    else:
        max_i = min(len(buf), len(chunk))
        overlap = 0
        for i in range(max_i, 0, -1):
            if buf[-i:] == chunk[:i]:
                overlap = i
                break
        buf += chunk[overlap:]
print(buf)
'
