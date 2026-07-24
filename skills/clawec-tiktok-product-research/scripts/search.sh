#!/usr/bin/env bash
set -euo pipefail

CATEGORY=""
REGION="US"
DAYS="7"
AI_INTERPRET="false"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ai|--ai-interpret)
      AI_INTERPRET="true"
      shift
      ;;
    -h|--help)
      cat <<'EOF'
用法: search.sh <category> [region] [days] [--ai]

  category  品类关键词或名称（必填）
  region    市场代码，默认 US
  days      分析周期天数，默认 7
  --ai      开启 AI 解读
EOF
      exit 0
      ;;
    --)
      shift
      POSITIONAL+=("$@")
      break
      ;;
    -*)
      echo "未知参数: $1" >&2
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ ${#POSITIONAL[@]} -gt 0 ]]; then CATEGORY="${POSITIONAL[0]}"; fi
if [[ ${#POSITIONAL[@]} -gt 1 ]]; then REGION="${POSITIONAL[1]}"; fi
if [[ ${#POSITIONAL[@]} -gt 2 ]]; then DAYS="${POSITIONAL[2]}"; fi

if [[ -z "$CATEGORY" ]]; then
  echo "用法: search.sh <category> [region] [days] [--ai]" >&2
  exit 1
fi

API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
category, region, days_raw, ai = sys.argv[1:5]
days = int(days_raw) if days_raw else 7
body = {
    "region": region or "US",
    "category": category,
    "days": days,
    "aiInterpret": ai.lower() == "true",
}
print(json.dumps(body, ensure_ascii=False))
' "$CATEGORY" "$REGION" "$DAYS" "$AI_INTERPRET")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/tiktok/product_opportunity/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
