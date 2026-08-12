#!/usr/bin/env bash
set -euo pipefail

SITE="${1:?用法: query.sh <site> [categoryId] [brandName] [sortType] [pageNo] [pageSize]}"
CATEGORYID="${2:-}"
BRANDNAME="${3:-}"
SORTTYPE="${4:-}"
PAGENO="${5:-}"
PAGESIZE="${6:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

_KEYS='["site", "categoryId", "brandName", "sortType", "pageNo", "pageSize"]'
_REQUIRED='["site"]'
PAYLOAD=$(KEYS="$_KEYS" REQUIRED="$_REQUIRED" python3 - "${SITE}" "${CATEGORYID}" "${BRANDNAME}" "${SORTTYPE}" "${PAGENO}" "${PAGESIZE}" <<'PY'
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

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/brand/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
