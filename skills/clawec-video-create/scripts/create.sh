#!/usr/bin/env bash
set -euo pipefail
MODE="" PROMPT="" MODEL="" RATIO="" SIZE="" LENGTH="" ATTACHES="[]"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="${2:-}"; shift 2 ;;
    --prompt) PROMPT="${2:-}"; shift 2 ;;
    --model) MODEL="${2:-}"; shift 2 ;;
    --ratio) RATIO="${2:-}"; shift 2 ;;
    --size) SIZE="${2:-}"; shift 2 ;;
    --length) LENGTH="${2:-}"; shift 2 ;;
    --attaches) ATTACHES="${2:-[]}"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$MODE" && -n "$PROMPT" && -n "$MODEL" && -n "$RATIO" && -n "$SIZE" ]] || {
  echo "用法: create.sh --mode N --prompt TEXT --model ID --ratio ID --size ID [--length N] [--attaches JSON]" >&2; exit 1; }
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys
mode,prompt,model,ratio,size,length,attaches_raw=sys.argv[1:8]
b={"create_mode":int(mode),"prompt":prompt,"model":model,"ratio":ratio,"size":size,"platform":1,"terminal":4,"language":"zh-CN"}
ln=length.strip()
if ln: b["length"]=int(ln)
att=json.loads(attaches_raw)
if att: b["attaches"]=att
print(json.dumps(b,ensure_ascii=False))' "$MODE" "$PROMPT" "$MODEL" "$RATIO" "$SIZE" "$LENGTH" "$ATTACHES")
curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/video/create" \
  -H "Token: $TOKEN" -H "Content-Type: application/json" -d "$PAYLOAD"
