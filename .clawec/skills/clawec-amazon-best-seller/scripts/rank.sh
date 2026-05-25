#!/usr/bin/env bash
set -euo pipefail

CAT="${1:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"cat": sys.argv[1]}))' "$CAT")

curl -s -X POST "https://www.clawec.com/api/aigc/tool/amazon_best_seller" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
