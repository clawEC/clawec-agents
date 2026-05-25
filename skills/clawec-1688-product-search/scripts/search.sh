#!/usr/bin/env bash
set -euo pipefail

KEYWORD="${1:?用法: search.sh <keyword> [page] [table]}"
PAGE="${2:-1}"
TABLE="${3:-0}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

curl -s -G "https://www.clawec.com/api/aigc/tool/1688_product_search_lite" \
  --data-urlencode "keyword=$KEYWORD" \
  --data-urlencode "page=$PAGE" \
  --data-urlencode "table=$TABLE" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY"
