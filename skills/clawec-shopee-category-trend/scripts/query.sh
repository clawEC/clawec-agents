#!/usr/bin/env bash
set -euo pipefail

SITES="${1:?用法: query.sh <sites> <catId> <granularity> <startDate> <endDate> [productType] [location]}"
CAT_ID="${2:?用法: query.sh <sites> <catId> <granularity> <startDate> <endDate> [productType] [location]}"
GRANULARITY="${3:?用法: query.sh <sites> <catId> <granularity> <startDate> <endDate> [productType] [location]}"
START_DATE="${4:?用法: query.sh <sites> <catId> <granularity> <startDate> <endDate> [productType] [location]}"
END_DATE="${5:?用法: query.sh <sites> <catId> <granularity> <startDate> <endDate> [productType] [location]}"
PRODUCT_TYPE="${6:-0}"
LOCATION="${7:-0}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
sites = [x.strip() for x in sys.argv[1].split(",") if x.strip()]
if not sites:
    raise SystemExit("sites 不能为空")
granularity = int(sys.argv[3])
if granularity not in (1, 2, 3):
    raise SystemExit("granularity 必须为 1(自然月)/2(自然季度)/3(年)")
body = {
  "sites": sites,
  "catId": int(sys.argv[2]),
  "granularity": granularity,
  "startDate": sys.argv[4],
  "endDate": sys.argv[5],
  "productType": int(sys.argv[6]),
  "location": int(sys.argv[7]),
}
print(json.dumps(body, ensure_ascii=False))
' "$SITES" "$CAT_ID" "$GRANULARITY" "$START_DATE" "$END_DATE" "$PRODUCT_TYPE" "$LOCATION")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/category/trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
