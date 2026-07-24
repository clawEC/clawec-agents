#!/usr/bin/env bash
set -euo pipefail

PRODUCT=""
REGION="US"
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
用法: search.sh <product> [region] [--ai]

  product  商品 ID 或 TikTok Shop 商品链接（必填）
  region   市场代码，默认 US
  --ai     开启 AI 解读
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

if [[ ${#POSITIONAL[@]} -gt 0 ]]; then PRODUCT="${POSITIONAL[0]}"; fi
if [[ ${#POSITIONAL[@]} -gt 1 ]]; then REGION="${POSITIONAL[1]}"; fi

if [[ -z "$PRODUCT" ]]; then
  echo "用法: search.sh <product> [region] [--ai]" >&2
  exit 1
fi

API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(python3 -c '
import json, sys
product, region, ai = sys.argv[1:4]
body = {
    "product": product,
    "region": region or "US",
    "aiInterpret": ai.lower() == "true",
}
print(json.dumps(body, ensure_ascii=False))
' "$PRODUCT" "$REGION" "$AI_INTERPRET")

curl -s -X POST "https://www.clawec.com/api/aigc/ec/tiktok/product_analysis/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
