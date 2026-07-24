#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> <shopId> <granularity> <startDate> <endDate> [catId] [pageNo] [pageSize]}"
SHOP_ID="${2:?用法: query.sh <site> <shopId> <granularity> <startDate> <endDate> [catId] [pageNo] [pageSize]}"
GRANULARITY="${3:?用法: query.sh <site> <shopId> <granularity> <startDate> <endDate> [catId] [pageNo] [pageSize]}"
START_DATE="${4:?用法: query.sh <site> <shopId> <granularity> <startDate> <endDate> [catId] [pageNo] [pageSize]}"
END_DATE="${5:?用法: query.sh <site> <shopId> <granularity> <startDate> <endDate> [catId] [pageNo] [pageSize]}"
CAT_ID="${6:-}"
PAGE_NO="${7:-1}"
PAGE_SIZE="${8:-10}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
granularity = int(sys.argv[3])
if granularity not in (1, 2, 3):
    raise SystemExit("granularity 必须为 1(自然月)/2(自然季度)/3(年)")
body = {
  "site": sys.argv[1],
  "shopId": int(sys.argv[2]),
  "granularity": granularity,
  "startDate": sys.argv[4],
  "endDate": sys.argv[5],
  "pageNo": int(sys.argv[7]),
  "pageSize": int(sys.argv[8]),
}
if len(sys.argv) > 6 and sys.argv[6]:
    body["catId"] = int(sys.argv[6])
print(json.dumps(body, ensure_ascii=False))
' "$SITE" "$SHOP_ID" "$GRANULARITY" "$START_DATE" "$END_DATE" "$CAT_ID" "$PAGE_NO" "$PAGE_SIZE")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/shop/trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
