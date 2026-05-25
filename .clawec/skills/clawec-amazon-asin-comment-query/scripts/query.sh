#!/usr/bin/env bash
set -euo pipefail

ARG1="${1:?用法: query.sh <url|asin> [region]}"
REGION="${2:-NA}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

if [[ "$ARG1" == http* ]]; then
  PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"url": sys.argv[1]}))' "$ARG1")
else
  PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"asin": sys.argv[1], "region": sys.argv[2]}))' "$ARG1" "$REGION")
fi

curl -s -X POST "https://www.clawec.com/api/aigc/tool/amazon_asin_comment_query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
