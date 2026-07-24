#!/usr/bin/env bash
set -euo pipefail
FILE="${1:?用法: upload_file.sh <文件路径>}"
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"
[[ -f "$FILE" ]] || { echo "文件不存在: $FILE" >&2; exit 1; }
curl -s -X POST "https://www.clawec.com/api/upload/file" \
  -H "Token: $TOKEN" -F "file=@${FILE}" -F "platform=1" -F "terminal=4" -F "language=zh-CN"
