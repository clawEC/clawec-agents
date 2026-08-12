#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE="${1:?用法: query.sh <marketplace> <q> [month] [page] [size]}"
Q="${2:?用法: query.sh <marketplace> <q> [month] [page] [size]}"
MONTH="${3:-}"
PAGE="${4:-}"
SIZE="${5:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

_KEYS='["marketplace", "q", "month", "page", "size"]'
_REQUIRED='["marketplace", "q"]'
PAYLOAD=$(KEYS="$_KEYS" REQUIRED="$_REQUIRED" python3 - "${MARKETPLACE}" "${Q}" "${MONTH}" "${PAGE}" "${SIZE}" <<'PY'
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

curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/traffic/source" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
