#!/usr/bin/env bash
set -euo pipefail
KEYWORD=""; REGION="US"; DATE=""; ABA="false"; MINER="true"; TREND="false"; AI="false"; POSITIONAL=()
usage() { echo "用法: search.sh [keyword] [region] [date] [--aba-research] [--keyword-miner] [--keyword-trend] [--no-keyword-miner] [--ai]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --aba-research) ABA="true"; shift ;;
    --keyword-miner) MINER="true"; shift ;;
    --no-keyword-miner) MINER="false"; shift ;;
    --keyword-trend) TREND="true"; shift ;;
    --ai|--ai-interpret) AI="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[[ ${#POSITIONAL[@]} -gt 0 ]] && KEYWORD="${POSITIONAL[0]}"
[[ ${#POSITIONAL[@]} -gt 1 ]] && REGION="${POSITIONAL[1]}"
[[ ${#POSITIONAL[@]} -gt 2 ]] && DATE="${POSITIONAL[2]}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"
PAYLOAD=$(python3 -c '
import json, sys
from datetime import datetime
kw, region, date, aba, miner, trend, ai = sys.argv[1:8]
if not date:
    now=datetime.now(); mo=now.month-1 or 12; yr=now.year if now.month>1 else now.year-1; date=f"{yr}{mo:02d}"
body={"region":region or "US","keyword":kw,"date":date,"abaResearch":aba=="true","keywordMiner":miner=="true","keywordTrend":trend=="true","aiInterpret":ai=="true"}
print(json.dumps(body, ensure_ascii=False))
' "$KEYWORD" "$REGION" "$DATE" "$ABA" "$MINER" "$TREND" "$AI")
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/keyword/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
