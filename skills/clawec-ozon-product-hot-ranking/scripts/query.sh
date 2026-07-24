#!/usr/bin/env bash
set -euo pipefail

LEVEL1_CATEGORY_ID="${1:?用法: query.sh <level1CategoryId> [period] [pageNo] [pageSize] [sortField] [sortDirection] [updatePeriod] [filtersJson]}"
PERIOD="${2:-SEVEN_DAY}"
PAGE_NO="${3:-1}"
PAGE_SIZE="${4:-15}"
SORT_FIELD="${5:-SALES}"
SORT_DIRECTION="${6:-DESC}"
UPDATE_PERIOD="${7:-}"
FILTERS_JSON="${8:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
body = {
  "level1CategoryId": int(sys.argv[1]),
  "period": sys.argv[2],
  "pageNo": int(sys.argv[3]),
  "pageSize": int(sys.argv[4]),
  "sortField": sys.argv[5],
  "sortDirection": sys.argv[6],
}
if len(sys.argv) > 7 and sys.argv[7]:
    body["updatePeriod"] = sys.argv[7]
if len(sys.argv) > 8 and sys.argv[8]:
    extra = json.loads(sys.argv[8])
    if not isinstance(extra, dict):
        raise SystemExit("filtersJson 必须是 JSON 对象")
    body.update(extra)
print(json.dumps(body))
' "$LEVEL1_CATEGORY_ID" "$PERIOD" "$PAGE_NO" "$PAGE_SIZE" "$SORT_FIELD" "$SORT_DIRECTION" "$UPDATE_PERIOD" "$FILTERS_JSON")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
