#!/usr/bin/env bash
set -euo pipefail

REGION="${1:-}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

_KEYS='["region"]'
_REQUIRED='[]'
PAYLOAD=$(KEYS="$_KEYS" REQUIRED="$_REQUIRED" python3 - "${REGION}" <<'PY'
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

curl -s -X POST "https://www.clawec.com/api/aigc/ec/tiktok/data/market/category_ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
