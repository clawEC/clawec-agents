#!/usr/bin/env bash
set -euo pipefail

LOG_ID="${1:?用法: log_detail.sh <log_id>}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

curl -s -G "https://www.clawec.com/api/aigc/ec/amazon/keyword_research/search/log/detail" \
  -H "Authorization: Bearer $API_KEY" \
  --data-urlencode "id=${LOG_ID}"
