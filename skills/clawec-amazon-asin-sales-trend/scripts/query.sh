#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE="${1:?用法: query.sh <marketplace> <asin>}"
ASIN="${2:?用法: query.sh <marketplace> <asin>}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

_KEYS='["marketplace", "asin"]'
_REQUIRED='["marketplace", "asin"]'
PAYLOAD=$(KEYS="$_KEYS" REQUIRED="$_REQUIRED" python3 - "${MARKETPLACE}" "${ASIN}" <<'PY'
import json, os, sys
keys = json.loads(os.environ["KEYS"])
required = set(json.loads(os.environ["REQUIRED"]))
vals = sys.argv[1:]
body = {}
date_keys = {"month", "date", "historyDate", "availableMonth"}
for k, v in zip(keys, vals):
    v = (v or "").strip()
    if not v:
        if k in required:
            raise SystemExit(f"{k} 不能为空")
        continue
    if k == "marketplace":
        v = v.upper()
    if k in date_keys and (len(v) != 6 or not v.isdigit()):
        raise SystemExit(f"{k} 格式须为 yyyyMM，例如 202507")
    body[k] = v
print(json.dumps(body, ensure_ascii=False))
PY
)

curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/asin/sales_trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
