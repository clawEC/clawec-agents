#!/usr/bin/env bash
set -euo pipefail
TEXT="" PROMPT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --text) TEXT="${2:-}"; shift 2 ;;
    --prompt) PROMPT="${2:-}"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$TEXT" ]] || { echo "用法: clone.sh --text 原文案 [--prompt 仿写指令]" >&2; exit 1; }
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys; t,p=sys.argv[1],sys.argv[2]; b={"text":t,"platform":1,"terminal":4,"language":"zh-CN"};
if p.strip(): b["prompt"]=p.strip(); print(json.dumps(b,ensure_ascii=False))' "$TEXT" "$PROMPT")
curl -sN -X POST "https://www.clawec.com/api/aigc/ec_media/video/text/clone" \
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
    elif not buf.endswith(chunk):
        max_i = min(len(buf), len(chunk))
        overlap = 0
        for i in range(max_i, 0, -1):
            if buf[-i:] == chunk[:i]:
                overlap = i
                break
        buf += chunk[overlap:]
print(buf)
'
