#!/usr/bin/env bash
set -euo pipefail
TEXT="" VOICE_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --text) TEXT="${2:-}"; shift 2 ;;
    --voice-id) VOICE_ID="${2:-}"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$TEXT" && -n "$VOICE_ID" ]] || { echo "用法: voice_create.sh --text TEXT --voice-id ID" >&2; exit 1; }
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"voiceId":sys.argv[2],"platform":1,"terminal":4,"language":"zh-CN"},ensure_ascii=False))' "$TEXT" "$VOICE_ID")
curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/voice_create" \
  -H "Token: $TOKEN" -H "Content-Type: application/json" -d "$PAYLOAD"
