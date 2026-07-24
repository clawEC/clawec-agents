#!/usr/bin/env bash
set -euo pipefail

START="${1:-1}"
SIZE="${2:-20}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

curl -s -G "https://www.clawec.com/api/aigc/ec/amazon/competitor/search/logs" \
  -H "Authorization: Bearer $API_KEY" \
  --data-urlencode "start=${START}" \
  --data-urlencode "size=${SIZE}"
