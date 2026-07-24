#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> <shopIds> [timest]}"
SHOP_IDS="${2:?用法: query.sh <site> <shopIds> [timest]}"
TIMEST="${3:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
ids = [x.strip() for x in sys.argv[2].split(",") if x.strip()]
if not ids:
    raise SystemExit("shopIds 不能为空")
if len(ids) > 10:
    raise SystemExit("最多 10 个店铺 ID，请分批查询")
body = {
  "site": sys.argv[1],
  "shopIds": ",".join(ids),
}
if len(sys.argv) > 3 and sys.argv[3]:
    body["timest"] = sys.argv[3]
print(json.dumps(body, ensure_ascii=False))
' "$SITE" "$SHOP_IDS" "$TIMEST")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/shop/detail" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
