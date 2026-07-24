#!/usr/bin/env bash
set -euo pipefail
MARKETPLACE="US"; NODE=""; MONTH=""; MS="true"; PC="false"; BC="false"; SC="false"; AI="false"; POSITIONAL=()
usage() { echo "用法: search.sh [marketplace] --node-id-path PATH [--month yyyyMM] [--market-statistics|--product-concentration|--brand-concentration|--seller-concentration] [--ai]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --node-id-path) NODE="${2:?}"; shift 2 ;;
    --month) MONTH="${2:?}"; shift 2 ;;
    --market-statistics) MS="true"; shift ;;
    --product-concentration) PC="true"; shift ;;
    --brand-concentration) BC="true"; shift ;;
    --seller-concentration) SC="true"; shift ;;
    --ai|--ai-interpret) AI="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[[ ${#POSITIONAL[@]} -gt 0 ]] && MARKETPLACE="${POSITIONAL[0]}"
[[ -z "$NODE" ]] && { echo "缺少 --node-id-path" >&2; exit 1; }
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"
PAYLOAD=$(python3 -c '
import json, sys
from datetime import datetime
m, node, month, ms, pc, bc, sc, ai = sys.argv[1:9]
if not month:
    now=datetime.now(); mo=now.month-1 or 12; yr=now.year if now.month>1 else now.year-1; month=f"{yr}{mo:02d}"
body={"marketplace":m or "US","nodeIdPath":node,"month":month,"marketStatistics":ms=="true","productConcentration":pc=="true","brandConcentration":bc=="true","sellerConcentration":sc=="true","aiInterpret":ai=="true"}
print(json.dumps(body, ensure_ascii=False))
' "$MARKETPLACE" "$NODE" "$MONTH" "$MS" "$PC" "$BC" "$SC" "$AI")
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/category_research/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
