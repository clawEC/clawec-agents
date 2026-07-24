#!/usr/bin/env bash
set -euo pipefail
TEXT="${1:?用法: douyin_extract.sh <抖音分享文案>}"
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"platform":1,"terminal":4,"language":"zh-CN"},ensure_ascii=False))' "$TEXT")
curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/douyin_video_url_extract" \
  -H "Token: $TOKEN" -H "Content-Type: application/json" -d "$PAYLOAD"
