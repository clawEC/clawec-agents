#!/usr/bin/env bash
set -euo pipefail

CATEGORYID="${1:?用法: query.sh <categoryId> [pageNo] [pageSize] [language] [period] [updatePeriod] [sortField] [sortDirection]}"
PAGENO="${2:-}"
PAGESIZE="${3:-}"
LANGUAGE="${4:-}"
PERIOD="${5:-}"
UPDATEPERIOD="${6:-}"
SORTFIELD="${7:-}"
SORTDIRECTION="${8:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

_KEYS='["categoryId", "pageNo", "pageSize", "language", "period", "updatePeriod", "sortField", "sortDirection"]'
_REQUIRED='["categoryId"]'
PAYLOAD=$(KEYS="$_KEYS" REQUIRED="$_REQUIRED" python3 - "${CATEGORYID}" "${PAGENO}" "${PAGESIZE}" "${LANGUAGE}" "${PERIOD}" "${UPDATEPERIOD}" "${SORTFIELD}" "${SORTDIRECTION}" <<'PY'
import json, os, sys
keys = json.loads(os.environ["KEYS"])
required = set(json.loads(os.environ["REQUIRED"]))
vals = sys.argv[1:]
body = {}
for k, v in zip(keys, vals):
    v = (v or "").strip()
    if not v:
        if k in required:
            raise SystemExit(f"{k} 不能为空")
        continue
    body[k] = v
print(json.dumps(body, ensure_ascii=False))
PY
)

curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/category/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
