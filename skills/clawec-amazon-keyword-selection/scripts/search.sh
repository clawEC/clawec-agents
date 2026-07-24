#!/usr/bin/env bash
set -euo pipefail
REGION="US"; MONTH=""; DEPARTMENTS=""; KEYWORD=""; AI="false"; POSITIONAL=()
usage() { echo "用法: search.sh [region] [--month yyyyMM] [--departments CSV] [--keyword TEXT] [--ai]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --month) MONTH="${2:?}"; shift 2 ;;
    --departments) DEPARTMENTS="${2:?}"; shift 2 ;;
    --keyword) KEYWORD="${2:?}"; shift 2 ;;
    --ai|--ai-interpret) AI="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[[ ${#POSITIONAL[@]} -gt 0 ]] && REGION="${POSITIONAL[0]}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"
PAYLOAD=$(python3 -c '
import json, sys
from datetime import datetime
region, month, depts, kw, ai = sys.argv[1:6]
if not month:
    now=datetime.now(); mo=now.month-1 or 12; yr=now.year if now.month>1 else now.year-1; month=f"{yr}{mo:02d}"
body={"region":region or "US","month":month,"aiInterpret":ai=="true"}
if depts.strip(): body["departments"]=[d.strip() for d in depts.split(",") if d.strip()]
if kw.strip(): body["keyword"]=kw.strip()
print(json.dumps(body, ensure_ascii=False))
' "$REGION" "$MONTH" "$DEPARTMENTS" "$KEYWORD" "$AI")
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/keyword_research/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
