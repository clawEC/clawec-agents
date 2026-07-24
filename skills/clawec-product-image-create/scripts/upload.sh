#!/usr/bin/env bash
set -euo pipefail

FILE="${1:?用法: upload.sh <图片路径>}"
TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"

if [[ ! -f "$FILE" ]]; then
  echo "错误: 文件不存在: $FILE" >&2
  exit 1
fi

curl -s -X POST "https://www.clawec.com/api/upload/image" \
  -H "Token: $TOKEN" \
  -F "file=@${FILE}" \
  -F "platform=1" \
  -F "terminal=4" \
  -F "language=zh-CN"
