#!/usr/bin/env bash
set -euo pipefail

ITEM_IDS="${1:?用法: query.sh <itemIds> [keywordType] [pageNo] [pageSize] [sortField] [sortDirection] [keyword]}"
KEYWORD_TYPE="${2:-ALL}"
PAGE_NO="${3:-1}"
PAGE_SIZE="${4:-15}"
SORT_FIELD="${5:-SEARCH_INDEX}"
SORT_DIRECTION="${6:-DESC}"
KEYWORD="${7:-}"
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
  "keywordType": sys.argv[2],
  "pageNo": int(sys.argv[3]),
  "pageSize": int(sys.argv[4]),
  "sortField": sys.argv[5],
  "sortDirection": sys.argv[6],
}
if len(sys.argv) > 7 and sys.argv[7]:
    body["keyword"] = sys.argv[7]
print(json.dumps(body, ensure_ascii=False))
' "$ITEM_IDS" "$KEYWORD_TYPE" "$PAGE_NO" "$PAGE_SIZE" "$SORT_FIELD" "$SORT_DIRECTION" "$KEYWORD")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/traffic-keywords" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
