#!/usr/bin/env bash
set -euo pipefail

KEYWORD="${1:?用法: search.sh <keyword> [region]}"
REGION="${2:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
body = {"keyword": sys.argv[1]}
if len(sys.argv) > 2 and sys.argv[2]:
    body["region"] = sys.argv[2]
print(json.dumps(body))
' "$KEYWORD" "$REGION")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee_search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
