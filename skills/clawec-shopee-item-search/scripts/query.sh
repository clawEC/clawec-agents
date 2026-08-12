#!/usr/bin/env bash
set -euo pipefail

# 用法:
#   query.sh '<json-body>'
#   query.sh @payload.json

INPUT="${1:?用法: query.sh '<json-body>' 或 query.sh @payload.json}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(INPUT="$INPUT" REQUIRED_KEYS='["site", "categoryId"]' python3 <<'PY'
import json, os
raw = os.environ["INPUT"]
required = json.loads(os.environ["REQUIRED_KEYS"])
if raw.startswith("@"):
    with open(raw[1:], encoding="utf-8") as f:
        body = json.load(f)
else:
    body = json.loads(raw)
if not isinstance(body, dict):
    raise SystemExit("JSON body 须为对象")
for k in required:
    if not str(body.get(k, "")).strip():
        raise SystemExit(f"{k} 不能为空")
print(json.dumps(body, ensure_ascii=False))
PY
)

curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
