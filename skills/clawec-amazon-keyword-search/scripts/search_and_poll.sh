#!/usr/bin/env bash
set -euo pipefail

POLL_INTERVAL="${KS_POLL_INTERVAL:-4}"
MAX_ATTEMPTS="${KS_POLL_MAX:-60}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
search_and_poll.sh [keyword] [region] [date] [--aba-research] [--keyword-miner] [--keyword-trend] [--ai]

环境变量:
  KS_POLL_INTERVAL  轮询间隔秒数，默认 4
  KS_POLL_MAX       最大轮询次数，默认 60
EOF
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

python3 - "$POLL_INTERVAL" "$MAX_ATTEMPTS" "$SCRIPT_DIR" "$@" <<'PY'
import json
import os
import subprocess
import sys
import time
from datetime import datetime

poll_interval = max(1, int(sys.argv[1] or "4"))
max_attempts = max(1, int(sys.argv[2] or "60"))
script_dir = sys.argv[3]
args = sys.argv[4:]

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

def default_month():
    now = datetime.now()
    m = now.month - 1 or 12
    y = now.year if now.month > 1 else now.year - 1
    return f"{y}{m:02d}"

def parse_bool_flag(args, name, default=False):
    val = default
    i = 0
    while i < len(args):
        if args[i] == name:
            val = True
            args.pop(i)
        elif args[i] == f"--no-{name.lstrip('-')}":
            val = False
            args.pop(i)
        else:
            i += 1
    return val, args

def pop_opt(args, flag):
    if flag in args:
        idx = args.index(flag)
        if idx + 1 < len(args):
            val = args[idx + 1]
            del args[idx:idx + 2]
            return val
    return None

args = list(sys.argv[4:])
keyword = args.pop(0) if args and not args[0].startswith("-") else ""
region = args.pop(0) if args and not args[0].startswith("-") else "US"
date = args.pop(0) if args and not args[0].startswith("-") else default_month()
ai = "--ai" in args
cmd = [search_sh, keyword, region, date] + [a for a in args if a.startswith("--")]
unwrap_data(run_json(cmd))
target = {"region": region, "keyword": keyword.strip(), "date": date, "aiInterpret": ai}
log_id = None
for _ in range(10):
    for item in (unwrap_data(run_json([logs_sh,"1","20"])).get("items") or []):
        p = item.get("param") or {}
        if (p.get("keyword") or "").strip() == keyword.strip() and (p.get("region") or "US") == region and str(p.get("date") or "") == date:
            log_id = item.get("id"); break
    if log_id: break
    time.sleep(min(poll_interval,3))
if not log_id:
    print(json.dumps({"status":"error","message":"未找到历史记录"}, ensure_ascii=False, indent=2)); sys.exit(1)
detail = None
for _ in range(max_attempts):
    detail = unwrap_data(run_json([detail_sh, str(log_id)]))
    if not ai or detail.get("aiStatus") in ("success","fail"): break
    time.sleep(poll_interval)
print(json.dumps({"status":"ok","logId":log_id,"param":detail.get("param"),"items":detail.get("items",[]),"keywordMinerItems":detail.get("keywordMinerItems"),"keywordTrendItems":detail.get("keywordTrendItems"),"aiStatus":detail.get("aiStatus"),"aiAnalysis":detail.get("aiAnalysis")}, ensure_ascii=False, indent=2))

PY
