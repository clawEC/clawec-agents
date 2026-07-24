#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> <categoryId> <sortField> <period> [borderType] [pageNo] [pageSize] [date]}"
CATEGORY_ID="${2:?用法: query.sh <site> <categoryId> <sortField> <period> [borderType] [pageNo] [pageSize] [date]}"
SORT_FIELD="${3:?用法: query.sh <site> <categoryId> <sortField> <period> [borderType] [pageNo] [pageSize] [date]}"
PERIOD="${4:?用法: query.sh <site> <categoryId> <sortField> <period> [borderType] [pageNo] [pageSize] [date]}"
BORDER_TYPE="${5:-0}"
PAGE_NO="${6:-1}"
PAGE_SIZE="${7:-10}"
DATE="${8:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
body = {
  "site": sys.argv[1],
  "categoryId": int(sys.argv[2]),
  "sortField": int(sys.argv[3]),
  "period": int(sys.argv[4]),
  "borderType": int(sys.argv[5]),
  "pageNo": int(sys.argv[6]),
  "pageSize": int(sys.argv[7]),
}
if len(sys.argv) > 8 and sys.argv[8]:
    body["date"] = sys.argv[8]
print(json.dumps(body, ensure_ascii=False))
' "$SITE" "$CATEGORY_ID" "$SORT_FIELD" "$PERIOD" "$BORDER_TYPE" "$PAGE_NO" "$PAGE_SIZE" "$DATE")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/word/ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
