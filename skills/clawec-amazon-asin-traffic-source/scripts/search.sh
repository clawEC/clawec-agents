#!/usr/bin/env bash
set -euo pipefail
MARKETPLACE="US"; ASIN=""; MONTH=""; TS="true"; TLS="false"; TK="false"; KO="false"; AI="false"; POSITIONAL=()
usage() { echo "用法: search.sh [marketplace] --asin ASIN --month yyyyMM [--traffic-source] [--traffic-listing-stat] [--traffic-keyword] [--keyword-order] [--ai]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --asin) ASIN="${2:?}"; shift 2 ;;
    --month) MONTH="${2:?}"; shift 2 ;;
    --traffic-source) TS="true"; shift ;;
    --traffic-listing-stat) TLS="true"; shift ;;
    --traffic-keyword) TK="true"; shift ;;
    --keyword-order) KO="true"; shift ;;
    --ai|--ai-interpret) AI="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[[ ${#POSITIONAL[@]} -gt 0 ]] && MARKETPLACE="${POSITIONAL[0]}"
[[ -z "$ASIN" || -z "$MONTH" ]] && { echo "需要 --asin 和 --month" >&2; exit 1; }
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"
PAYLOAD=$(python3 -c '
import json, sys
m, asin, month, ts, tls, tk, ko, ai = sys.argv[1:9]
body={"marketplace":m or "US","asin":asin.strip().upper(),"month":month,"trafficSource":ts=="true","trafficListingStat":tls=="true","trafficKeyword":tk=="true","keywordOrder":ko=="true","aiInterpret":ai=="true"}
print(json.dumps(body, ensure_ascii=False))
' "$MARKETPLACE" "$ASIN" "$MONTH" "$TS" "$TLS" "$TK" "$KO" "$AI")
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/traffic_source/search" -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$PAYLOAD"
