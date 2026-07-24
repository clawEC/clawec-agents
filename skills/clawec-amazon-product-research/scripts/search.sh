#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE="US"
MONTH=""
KEYWORD=""
NODE_PATHS=""
FAST_MODE=""
AI="false"
POSITIONAL=()

usage() {
  cat <<'EOF'
用法: search.sh [marketplace] [选项]
  --month yyyyMM       数据月份，默认上一个月
  --keyword TEXT       关键词
  --node-id-path PATH  类目 nodeIdPath（可多次）
  --fast-mode ID       选品模式
  --ai                 开启 AI 解读
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --month) MONTH="${2:?}"; shift 2 ;;
    --keyword) KEYWORD="${2:?}"; shift 2 ;;
    --node-id-path) NODE_PATHS+="${2:?},"; shift 2 ;;
    --fast-mode) FAST_MODE="${2:?}"; shift 2 ;;
    --ai|--ai-interpret) AI="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[[ ${#POSITIONAL[@]} -gt 0 ]] && MARKETPLACE="${POSITIONAL[0]}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
from datetime import datetime
m, month, kw, paths_raw, fm, ai = sys.argv[1:7]
FAST = {"low_price_long_tail": {"maxUnits": 300, "maxPrice": 30, "maxSellers": 1, "minBsr": 10000, "maxBsr": 50000}, "sales_surge": {"minUnits": 300, "minUnitsCr": 10}, "potential_market": {"maxUnits": 600, "minUnitsCr": 10}, "unmet_market": {"minUnits": 300, "maxRating": 3.7}, "speculative_market": {"minUnits": 600, "minSellers": 3}, "broad_listing": {"minBsrCr": 99, "maxRating": 10, "availableMonth": 3}, "premium_listing": {"minBsrCr": 99, "availableMonth": 3}, "low_price": {"maxPrice": 10}, "beginner": {"minUnits": 300, "minPrice": 15, "maxPrice": 60, "minUnitsCr": 3, "availableMonth": 12}}
if not month:
    now = datetime.now(); mo = now.month-1 or 12; yr = now.year if now.month>1 else now.year-1
    month = f"{yr}{mo:02d}"
body = {"marketplace": m or "US", "month": month, "matchType": 2, "page": 1, "size": 50, "nodeIdPathEqual": False, "aiInterpret": ai=="true"}
if kw.strip(): body["keyword"] = kw.strip()
paths = [p.strip() for p in paths_raw.split(",") if p.strip()]
if paths: body["nodeIdPaths"] = paths
if fm.strip() in FAST: body.update(FAST[fm.strip()])
print(json.dumps(body, ensure_ascii=False))
' "$MARKETPLACE" "$MONTH" "$KEYWORD" "$NODE_PATHS" "$FAST_MODE" "$AI")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/product_research/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
