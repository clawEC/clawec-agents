#!/usr/bin/env bash
set -euo pipefail
START="${1:-1}" SIZE="${2:-5}"
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
curl -s -G "https://www.clawec.com/api/aigc/ec_media/video/info/extract/logs" \
  -H "Token: $TOKEN" \
  --data-urlencode "start=${START}" --data-urlencode "size=${SIZE}" \
  --data-urlencode "platform=1" --data-urlencode "terminal=4" --data-urlencode "language=zh-CN"
