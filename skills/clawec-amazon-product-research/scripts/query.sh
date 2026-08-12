#!/usr/bin/env bash
set -euo pipefail

# 用法:
#   query.sh '<json-body>'
#   query.sh @payload.json
# JSON 中至少包含 marketplace

INPUT="${1:?用法: query.sh '<json-body>' 或 query.sh @payload.json}"
API_KEY="${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_API_KEY}"

PAYLOAD=$(INPUT="$INPUT" python3 <<'PY'
import json, os
raw = os.environ["INPUT"]
if raw.startswith("@"):
    with open(raw[1:], encoding="utf-8") as f:
        body = json.load(f)
else:
    body = json.loads(raw)
if not str(body.get("marketplace", "")).strip():
    raise SystemExit("marketplace 不能为空")
body["marketplace"] = str(body["marketplace"]).strip().upper()
print(json.dumps(body, ensure_ascii=False))
PY
)

curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/product/research" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$PAYLOAD"
