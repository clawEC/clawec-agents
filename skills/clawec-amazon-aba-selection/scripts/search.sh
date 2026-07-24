#!/usr/bin/env bash
set -euo pipefail
MARKETPLACE="US"; DATE=""; DEPARTMENTS=""; SEARCH_MODEL=""; AI="false"; POSITIONAL=()
usage() { echo "用法: search.sh [marketplace] [--date yyyyMM] [--departments CSV] [--search-model N] [--ai]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --date) DATE="${2:?}"; shift 2 ;;
    --departments) DEPARTMENTS="${2:?}"; shift 2 ;;
    --search-model) SEARCH_MODEL="${2:?}"; shift 2 ;;
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
m, date, depts, sm, ai = sys.argv[1:6]
if not date:
    now=datetime.now(); mo=now.month-1 or 12; yr=now.year if now.month>1 else now.year-1; date=f"{yr}{mo:02d}"
body={"marketplace":m or "US","date":date,"aiInterpret":ai=="true"}
if depts.strip(): body["departments"]=[d.strip() for d in depts.split(",") if d.strip()]
if sm.strip(): body["searchModel"]=int(sm)
print(json.dumps(body, ensure_ascii=False))
' "$MARKETPLACE" "$DATE" "$DEPARTMENTS" "$SEARCH_MODEL" "$AI")
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/market_trend/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
