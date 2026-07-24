#!/usr/bin/env bash
set -euo pipefail
MARKETPLACE="US"; ASIN=""; MONTH=""; DETAIL="true"; TREND="false"; PRED="false"; AI="false"; POSITIONAL=()
usage() { echo "用法: search.sh [marketplace] --asin ASIN [--month yyyyMM] [--asin-detail] [--sales-trend] [--sales-prediction] [--no-asin-detail] [--ai]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --asin) ASIN="${2:?}"; shift 2 ;;
    --month) MONTH="${2:?}"; shift 2 ;;
    --asin-detail) DETAIL="true"; shift ;;
    --no-asin-detail) DETAIL="false"; shift ;;
    --sales-trend) TREND="true"; shift ;;
    --sales-prediction) PRED="true"; shift ;;
    --ai|--ai-interpret) AI="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[[ ${#POSITIONAL[@]} -gt 0 ]] && MARKETPLACE="${POSITIONAL[0]}"
[[ -z "$ASIN" ]] && { echo "需要 --asin" >&2; exit 1; }
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"
PAYLOAD=$(python3 -c '
import json, sys
from datetime import datetime
m, asin, month, detail, trend, pred, ai = sys.argv[1:8]
body={"marketplace":m or "US","asin":asin.strip().upper(),"asinDetail":detail=="true","salesTrend":trend=="true","salesPrediction":pred=="true","aiInterpret":ai=="true"}
if month.strip(): body["month"]=month.strip()
elif True:
    now=datetime.now(); mo=now.month-1 or 12; yr=now.year if now.month>1 else now.year-1; body["month"]=f"{yr}{mo:02d}"
print(json.dumps(body, ensure_ascii=False))
' "$MARKETPLACE" "$ASIN" "$MONTH" "$DETAIL" "$TREND" "$PRED" "$AI")
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/asin_advantage/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
