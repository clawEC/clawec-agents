#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> <categoryId> [sortType] [sortOrder] [pageNo] [pageSize] [timest] [filtersJson]}"
CATEGORY_ID="${2:?用法: query.sh <site> <categoryId> [sortType] [sortOrder] [pageNo] [pageSize] [timest] [filtersJson]}"
SORT_TYPE="${3:-1}"
SORT_ORDER="${4:-desc}"
PAGE_NO="${5:-1}"
PAGE_SIZE="${6:-10}"
TIMEST="${7:-}"
FILTERS_JSON="${8:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
body = {
  "site": sys.argv[1],
  "categoryId": int(sys.argv[2]),
  "sortType": int(sys.argv[3]),
  "sortOrder": sys.argv[4],
  "pageNo": int(sys.argv[5]),
  "pageSize": int(sys.argv[6]),
}
if len(sys.argv) > 7 and sys.argv[7]:
    body["timest"] = sys.argv[7]
if len(sys.argv) > 8 and sys.argv[8]:
    extra = json.loads(sys.argv[8])
    if not isinstance(extra, dict):
        raise SystemExit("filtersJson 必须是 JSON 对象")
    body.update(extra)
print(json.dumps(body, ensure_ascii=False))
' "$SITE" "$CATEGORY_ID" "$SORT_TYPE" "$SORT_ORDER" "$PAGE_NO" "$PAGE_SIZE" "$TIMEST" "$FILTERS_JSON")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
