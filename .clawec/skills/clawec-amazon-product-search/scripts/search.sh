#!/usr/bin/env bash
set -euo pipefail

KEYWORD="${1:?用法: search.sh <keyword> [region]}"
REGION="${2:-NA}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"keyword": sys.argv[1], "region": sys.argv[2]}))' "$KEYWORD" "$REGION")

curl -s -X POST "https://www.clawec.com/api/aigc/tool/amazon_product_search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
