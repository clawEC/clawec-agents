#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> <itemId> <granularity> <startDate> <endDate> [pageNo] [pageSize]}"
ITEM_ID="${2:?用法: query.sh <site> <itemId> <granularity> <startDate> <endDate> [pageNo] [pageSize]}"
GRANULARITY="${3:?用法: query.sh <site> <itemId> <granularity> <startDate> <endDate> [pageNo] [pageSize]}"
START_DATE="${4:?用法: query.sh <site> <itemId> <granularity> <startDate> <endDate> [pageNo] [pageSize]}"
END_DATE="${5:?用法: query.sh <site> <itemId> <granularity> <startDate> <endDate> [pageNo] [pageSize]}"
PAGE_NO="${6:-1}"
PAGE_SIZE="${7:-10}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
granularity = int(sys.argv[3])
if granularity not in (1, 2, 3):
    raise SystemExit("granularity 必须为 1(自然月)/2(自然季度)/3(年)")
body = {
  "site": sys.argv[1],
  "itemId": int(sys.argv[2]),
  "granularity": granularity,
  "startDate": sys.argv[4],
  "endDate": sys.argv[5],
  "pageNo": int(sys.argv[6]),
  "pageSize": int(sys.argv[7]),
}
print(json.dumps(body, ensure_ascii=False))
' "$SITE" "$ITEM_ID" "$GRANULARITY" "$START_DATE" "$END_DATE" "$PAGE_NO" "$PAGE_SIZE")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
