#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> <itemIds> <type> [timest]}"
ITEM_IDS="${2:?用法: query.sh <site> <itemIds> <type> [timest]}"
TYPE="${3:?用法: query.sh <site> <itemIds> <type> [timest]}"
TIMEST="${4:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
ids = [x.strip() for x in sys.argv[2].split(",") if x.strip()]
if not ids:
    raise SystemExit("itemIds 不能为空")
if len(ids) > 10:
    raise SystemExit("最多 10 个商品 ID，请分批查询")
typ = int(sys.argv[3])
if typ not in (1, 2):
    raise SystemExit("type 必须为 1(引流词) 或 2(同类目热词)")
body = {
  "site": sys.argv[1],
  "itemIds": ",".join(ids),
  "type": typ,
}
if len(sys.argv) > 4 and sys.argv[4]:
    body["timest"] = sys.argv[4]
print(json.dumps(body, ensure_ascii=False))
' "$SITE" "$ITEM_IDS" "$TYPE" "$TIMEST")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/hotword" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
