#!/usr/bin/env bash
set -euo pipefail
AVATAR_ID="" MODEL="" RATIO="" SIZE="" PROMPT="" IMAGES="[]"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --avatar-id) AVATAR_ID="${2:-}"; shift 2 ;;
    --model) MODEL="${2:-}"; shift 2 ;;
    --ratio) RATIO="${2:-}"; shift 2 ;;
    --size) SIZE="${2:-}"; shift 2 ;;
    --prompt) PROMPT="${2:-}"; shift 2 ;;
    --images) IMAGES="${2:-[]}"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$AVATAR_ID" && -n "$MODEL" && -n "$RATIO" && -n "$SIZE" ]] || {
  echo "用法: image_create.sh --avatar-id ID --model ID --ratio ID --size ID [--prompt TEXT] [--images JSON]" >&2; exit 1; }
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys
a,m,r,s,p,img=sys.argv[1:7]
b={"avatarId":a,"model":m,"ratio":r,"size":s,"platform":1,"terminal":4,"language":"zh-CN"}
if p.strip(): b["prompt"]=p.strip()
images=json.loads(img)
if images: b["images"]=images
print(json.dumps(b,ensure_ascii=False))' "$AVATAR_ID" "$MODEL" "$RATIO" "$SIZE" "$PROMPT" "$IMAGES")
curl -s -X POST "https://www.clawec.com/api/aigc/ec_product_video/image/create" \
  -H "Token: $TOKEN" -H "Content-Type: application/json" -d "$PAYLOAD"
