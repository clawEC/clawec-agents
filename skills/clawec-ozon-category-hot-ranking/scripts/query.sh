#!/usr/bin/env bash
set -euo pipefail

CATEGORY_ID="${1:?用法: query.sh <categoryId> [period] [pageNo] [pageSize] [sortField] [sortDirection] [language] [updatePeriod]}"
PERIOD="${2:-SEVEN_DAY}"
PAGE_NO="${3:-1}"
PAGE_SIZE="${4:-15}"
SORT_FIELD="${5:-GMV}"
SORT_DIRECTION="${6:-DESC}"
LANGUAGE="${7:-CH}"
UPDATE_PERIOD="${8:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
body = {
  "categoryId": int(sys.argv[1]),
  "period": sys.argv[2],
  "pageNo": int(sys.argv[3]),
  "pageSize": int(sys.argv[4]),
  "sortField": sys.argv[5],
  "sortDirection": sys.argv[6],
  "language": sys.argv[7],
}
if len(sys.argv) > 8 and sys.argv[8]:
    body["updatePeriod"] = sys.argv[8]
print(json.dumps(body))
' "$CATEGORY_ID" "$PERIOD" "$PAGE_NO" "$PAGE_SIZE" "$SORT_FIELD" "$SORT_DIRECTION" "$LANGUAGE" "$UPDATE_PERIOD")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/category/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
