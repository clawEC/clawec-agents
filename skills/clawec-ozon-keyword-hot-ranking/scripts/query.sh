#!/usr/bin/env bash
set -euo pipefail

PERIOD="${1:?用法: query.sh <period> [pageNo] [pageSize] [sortField] [sortDirection] [updatePeriod] [filtersJson]}"
PAGE_NO="${2:-1}"
PAGE_SIZE="${3:-15}"
SORT_FIELD="${4:-SEARCH_INDEX}"
SORT_DIRECTION="${5:-DESC}"
UPDATE_PERIOD="${6:-}"
FILTERS_JSON="${7:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
body = {
  "period": sys.argv[1],
  "pageNo": int(sys.argv[2]),
  "pageSize": int(sys.argv[3]),
  "sortField": sys.argv[4],
  "sortDirection": sys.argv[5],
}
if len(sys.argv) > 6 and sys.argv[6]:
    body["updatePeriod"] = sys.argv[6]
if len(sys.argv) > 7 and sys.argv[7]:
    extra = json.loads(sys.argv[7])
    if not isinstance(extra, dict):
        raise SystemExit("filtersJson 必须是 JSON 对象")
    body.update(extra)
print(json.dumps(body, ensure_ascii=False))
' "$PERIOD" "$PAGE_NO" "$PAGE_SIZE" "$SORT_FIELD" "$SORT_DIRECTION" "$UPDATE_PERIOD" "$FILTERS_JSON")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/keyword/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
