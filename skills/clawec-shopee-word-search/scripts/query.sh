#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> [categoryId] [sortType] [pageNo] [pageSize] [timest] [filtersJson]}"
CATEGORY_ID="${2:-}"
SORT_TYPE="${3:-1}"
PAGE_NO="${4:-1}"
PAGE_SIZE="${5:-10}"
TIMEST="${6:-}"
FILTERS_JSON="${7:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
body = {
  "site": sys.argv[1],
  "sortType": int(sys.argv[3]),
  "pageNo": int(sys.argv[4]),
  "pageSize": int(sys.argv[5]),
}
if len(sys.argv) > 2 and sys.argv[2]:
    body["categoryId"] = int(sys.argv[2])
if len(sys.argv) > 6 and sys.argv[6]:
    body["timest"] = sys.argv[6]
if len(sys.argv) > 7 and sys.argv[7]:
    extra = json.loads(sys.argv[7])
    if not isinstance(extra, dict):
        raise SystemExit("filtersJson 必须是 JSON 对象")
    body.update(extra)
print(json.dumps(body, ensure_ascii=False))
' "$SITE" "$CATEGORY_ID" "$SORT_TYPE" "$PAGE_NO" "$PAGE_SIZE" "$TIMEST" "$FILTERS_JSON")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/word/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
