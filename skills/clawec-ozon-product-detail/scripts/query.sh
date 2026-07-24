#!/usr/bin/env bash
set -euo pipefail

ITEM_IDS="${1:?用法: query.sh <itemIds> [period] [sortField] [sortDirection] [updatePeriod]}"
PERIOD="${2:-TWENTY_EIGHT_DAY}"
SORT_FIELD="${3:-}"
SORT_DIRECTION="${4:-}"
UPDATE_PERIOD="${5:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
ids = [x.strip() for x in sys.argv[1].split(",") if x.strip()]
if not ids:
    raise SystemExit("itemIds 不能为空")
if len(ids) > 10:
    raise SystemExit("最多 10 个商品 ID，请分批查询")
body = {
  "itemIds": ",".join(ids),
  "period": sys.argv[2],
}
if len(sys.argv) > 3 and sys.argv[3]:
    body["sortField"] = sys.argv[3]
if len(sys.argv) > 4 and sys.argv[4]:
    body["sortDirection"] = sys.argv[4]
if len(sys.argv) > 5 and sys.argv[5]:
    body["updatePeriod"] = sys.argv[5]
print(json.dumps(body))
' "$ITEM_IDS" "$PERIOD" "$SORT_FIELD" "$SORT_DIRECTION" "$UPDATE_PERIOD")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/detail" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
