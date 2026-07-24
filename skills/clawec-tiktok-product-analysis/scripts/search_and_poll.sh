#!/usr/bin/env bash
set -euo pipefail

PRODUCT=""
REGION="US"
AI_INTERPRET="false"
POLL_INTERVAL="${TPA_POLL_INTERVAL:-4}"
MAX_ATTEMPTS="${TPA_POLL_MAX:-60}"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ai|--ai-interpret)
      AI_INTERPRET="true"
      shift
      ;;
    -h|--help)
      cat <<'EOF'
用法: search_and_poll.sh <product> [region] [--ai]

提交 TikTok 商品分析，定位历史记录，拉取详情；若 --ai 则轮询 AI 解读直到完成或超时。

环境变量:
  TPA_POLL_INTERVAL  轮询间隔秒数，默认 4
  TPA_POLL_MAX       最大轮询次数，默认 60
EOF
      exit 0
      ;;
    --)
      shift
      POSITIONAL+=("$@")
      break
      ;;
    -*)
      echo "未知参数: $1" >&2
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ ${#POSITIONAL[@]} -gt 0 ]]; then PRODUCT="${POSITIONAL[0]}"; fi
if [[ ${#POSITIONAL[@]} -gt 1 ]]; then REGION="${POSITIONAL[1]}"; fi

if [[ -z "$PRODUCT" ]]; then
  echo "用法: search_and_poll.sh <product> [region] [--ai]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

python3 - "$PRODUCT" "$REGION" "$AI_INTERPRET" "$POLL_INTERVAL" "$MAX_ATTEMPTS" "$SCRIPT_DIR" <<'PY'
import json
import os
import subprocess
import sys
import time

product, region, ai_raw, poll_interval_raw, max_attempts_raw, script_dir = sys.argv[1:7]
ai_interpret = ai_raw.lower() == "true"
poll_interval = max(1, int(poll_interval_raw or "4"))
max_attempts = max(1, int(max_attempts_raw or "60"))

target = {
    "product": product.strip(),
    "region": (region or "US").strip(),
    "aiInterpret": ai_interpret,
}

env = os.environ.copy()
search_sh = os.path.join(script_dir, "search.sh")
logs_sh = os.path.join(script_dir, "logs.sh")
detail_sh = os.path.join(script_dir, "log_detail.sh")

def run_json(cmd):
    proc = subprocess.run(cmd, capture_output=True, text=True, env=env)
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or proc.stdout.strip() or "command failed")
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"invalid json: {proc.stdout[:500]}") from exc

def envelope_ok(payload):
    if not isinstance(payload, dict):
        return False
    code = payload.get("code")
    if code is not None:
        try:
            if int(code) not in (200, 0):
                return False
        except (TypeError, ValueError):
            return False
    status = payload.get("status")
    if status is not None and int(status) != 1:
        if not (status == 0 and code is None):
            return False
    return True

def unwrap_data(payload):
    if not envelope_ok(payload):
        msg = payload.get("msg") or payload.get("message") or payload.get("errorMsg") or "request failed"
        raise RuntimeError(str(msg))
    return payload.get("data", payload)

def param_matches(param):
    if not isinstance(param, dict):
        return False
    if (param.get("product") or "").strip() != target["product"]:
        return False
    if (param.get("region") or "US").strip() != target["region"]:
        return False
    if bool(param.get("aiInterpret")) != target["aiInterpret"]:
        return False
    return True

search_args = [search_sh, target["product"], target["region"]]
if ai_interpret:
    search_args.append("--ai")

search_resp = run_json(search_args)
search_data = unwrap_data(search_resp)

log_id = None
for _ in range(10):
    logs_resp = run_json([logs_sh, "1", "20"])
    logs_data = unwrap_data(logs_resp)
    items = logs_data.get("items") if isinstance(logs_data, dict) else None
    if not isinstance(items, list):
        items = []
    for item in items:
        if param_matches(item.get("param") or {}):
            log_id = item.get("id")
            break
    if log_id is not None:
        break
    time.sleep(min(poll_interval, 3))

if log_id is None:
    result = {
        "status": "error",
        "message": "未在历史记录中找到本次分析，请稍后重试 logs + log_detail",
        "search": search_data,
        "param": target,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    sys.exit(1)

detail = None
for attempt in range(1, max_attempts + 1):
    detail_resp = run_json([detail_sh, str(log_id)])
    detail = unwrap_data(detail_resp)
    if not ai_interpret:
        break
    ai_status = detail.get("aiStatus")
    if ai_status in ("success", "fail"):
        break
    if attempt >= max_attempts:
        break
    time.sleep(poll_interval)

result = {
    "status": "ok",
    "logId": log_id,
    "param": detail.get("param") if isinstance(detail, dict) else None,
    "time": detail.get("time") if isinstance(detail, dict) else None,
    "data": detail.get("data") if isinstance(detail, dict) else None,
    "aiStatus": detail.get("aiStatus") if isinstance(detail, dict) else None,
    "aiAnalysis": detail.get("aiAnalysis") if isinstance(detail, dict) else None,
}

if ai_interpret and result.get("aiStatus") == "appending":
    result["status"] = "timeout"
    result["message"] = "AI 解读仍在进行中，请稍后使用 log_detail.sh 重查"

print(json.dumps(result, ensure_ascii=False, indent=2))
PY
