#!/usr/bin/env bash
set -euo pipefail

TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"

curl -s -G "https://www.clawec.com/api/aigc/ec_product_media/platform_options" \
  -H "Token: $TOKEN" \
  --data-urlencode "platform=1" \
  --data-urlencode "terminal=4" \
  --data-urlencode "language=zh-CN"
