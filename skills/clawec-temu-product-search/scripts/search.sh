#!/usr/bin/env bash
set -euo pipefail

KEYWORD="${1:?用法: search.sh <keyword>}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"keyword": sys.argv[1]}))' "$KEYWORD")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/temu_search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
