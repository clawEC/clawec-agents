#!/usr/bin/env bash
set -euo pipefail
MODEL="" RATIO="" SIZE="" LENGTH=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="${2:-}"; shift 2 ;;
    --ratio) RATIO="${2:-}"; shift 2 ;;
    --size) SIZE="${2:-}"; shift 2 ;;
    --length) LENGTH="${2:-}"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$MODEL" && -n "$RATIO" && -n "$SIZE" ]] || {
  echo "用法: point_calculate.sh --model ID --ratio ID --size ID [--length N]" >&2; exit 1; }
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys; m,r,s,l=sys.argv[1:5]; b={"prompt":".","create_mode":1,"model":m,"ratio":r,"size":s,"platform":1,"terminal":4,"language":"zh-CN"};
ln=l.strip();
if ln: b["length"]=int(ln); print(json.dumps(b))' "$MODEL" "$RATIO" "$SIZE" "$LENGTH")
curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/video/point_calculate" \
  -H "Token: $TOKEN" -H "Content-Type: application/json" -d "$PAYLOAD"
