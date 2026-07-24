#!/usr/bin/env bash
set -euo pipefail
LOG_ID="0" VIDEO_URL="" VIDEO_TEXT="" CLONE_TEXT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --log-id) LOG_ID="${2:-0}"; shift 2 ;;
    --video-url) VIDEO_URL="${2:-}"; shift 2 ;;
    --video-text) VIDEO_TEXT="${2:-}"; shift 2 ;;
    --clone-text) CLONE_TEXT="${2:-}"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$CLONE_TEXT" ]] || { echo "用法: clone_log_save.sh --clone-text TEXT [--log-id N] [--video-url URL] [--video-text TEXT]" >&2; exit 1; }
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"logId":int(sys.argv[1]),"videoUrl":sys.argv[2],"videoText":sys.argv[3],"cloneText":sys.argv[4],"platform":1,"terminal":4,"language":"zh-CN"},ensure_ascii=False))' "$LOG_ID" "$VIDEO_URL" "$VIDEO_TEXT" "$CLONE_TEXT")
curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/video/text/clone/log/save" \
  -H "Token: $TOKEN" -H "Content-Type: application/json" -d "$PAYLOAD"
