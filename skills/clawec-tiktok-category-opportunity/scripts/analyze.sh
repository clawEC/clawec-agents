#!/usr/bin/env bash
set -euo pipefail

KEYWORD="${1:?用法: analyze.sh <keyword> [region] [table]}"
REGION="${2:-ID}"
TABLE="${3:-0}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({
  "keyword": sys.argv[1],
  "target_platform": "tiktok",
  "region": sys.argv[2],
  "table": int(sys.argv[3]),
}))' "$KEYWORD" "$REGION" "$TABLE")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/product_search_v2" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
