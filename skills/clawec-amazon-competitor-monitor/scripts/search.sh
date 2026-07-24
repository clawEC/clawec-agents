#!/usr/bin/env bash
set -euo pipefail
MARKETPLACE="US"; MONTH=""; BRAND=""; SELLER=""; ASINS=""; KEYWORD=""; AI="false"; POSITIONAL=()
usage() { echo "用法: search.sh [marketplace] [--month yyyyMM] [--brand NAME] [--seller NAME] [--asins A,B] [--keyword TEXT] [--ai]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --month) MONTH="${2:?}"; shift 2 ;;
    --brand) BRAND="${2:?}"; shift 2 ;;
    --seller|--seller-name) SELLER="${2:?}"; shift 2 ;;
    --asins) ASINS="${2:?}"; shift 2 ;;
    --keyword) KEYWORD="${2:?}"; shift 2 ;;
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
m, month, brand, seller, asins_raw, kw, ai = sys.argv[1:8]
if not month:
    now=datetime.now(); mo=now.month-1 or 12; yr=now.year if now.month>1 else now.year-1; month=f"{yr}{mo:02d}"
body={"marketplace":m or "US","month":month,"aiInterpret":ai=="true"}
if brand.strip(): body["brand"]=brand.strip()
if seller.strip(): body["sellerName"]=seller.strip()
if asins_raw.strip():
    a=[x.strip().upper() for x in asins_raw.replace("\n",",").split(",") if x.strip()][:40]
    if a: body["asins"]=a
if kw.strip(): body["keyword"]=kw.strip()
print(json.dumps(body, ensure_ascii=False))
' "$MARKETPLACE" "$MONTH" "$BRAND" "$SELLER" "$ASINS" "$KEYWORD" "$AI")
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/competitor/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
