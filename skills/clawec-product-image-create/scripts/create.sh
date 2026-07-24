#!/usr/bin/env bash
set -euo pipefail

PROMPT=""
MODEL=""
RATIO=""
SIZE=""
IMAGES="[]"
TARGET_PLATFORM=""
REGION=""
SCENE="cover"

usage() {
  cat <<'EOF'
用法: create.sh --target-platform <平台code> [选项]

必填:
  --target-platform CODE   目标平台 code（来自 platform_options）

可选:
  --prompt TEXT            提示词（与 --images 至少填一项）
  --scene SCENE            图片场景: cover | cover_other | detail（默认 cover）
  --region CODE            目标市场 code
  --model ID               模型 ID
  --ratio ID               比例 ID
  --size ID                分辨率 ID
  --images JSON            参考图 URL 数组

示例:
  create.sh --target-platform amazon --scene cover --region US \
    --prompt "白底主图，无线耳机"
  create.sh --target-platform shopee --scene cover_other \
    --images '["https://cdn.example.com/ref.jpg"]'
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt) PROMPT="${2:-}"; shift 2 ;;
    --model) MODEL="${2:-}"; shift 2 ;;
    --ratio) RATIO="${2:-}"; shift 2 ;;
    --size) SIZE="${2:-}"; shift 2 ;;
    --images) IMAGES="${2:-[]}"; shift 2 ;;
    --target-platform) TARGET_PLATFORM="${2:-}"; shift 2 ;;
    --region) REGION="${2:-}"; shift 2 ;;
    --scene) SCENE="${2:-cover}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "未知参数: $1" >&2; usage ;;
  esac
done

[[ -n "$TARGET_PLATFORM" ]] || usage

TOKEN="${CLAWEC_TOKEN:-${CLAWEC_API_KEY:?请设置环境变量 CLAWEC_TOKEN 或 CLAWEC_API_KEY}}"

PAYLOAD=$(python3 -c '
import json, sys
prompt, model, ratio, size, images_raw, target_platform, region, scene = sys.argv[1:9]
body = {
    "target_platform": target_platform,
    "image_scene": scene or "cover",
    "platform": 1,
    "terminal": 4,
    "language": "zh-CN",
}
if prompt:
    body["prompt"] = prompt
if model:
    body["model"] = model
if ratio:
    body["ratio"] = ratio
if size:
    body["size"] = size
if region:
    body["region"] = region
images = json.loads(images_raw)
if images:
    body["images"] = images
if not body.get("prompt") and not body.get("images"):
    raise SystemExit("错误: --prompt 与 --images 至少填一项")
print(json.dumps(body, ensure_ascii=False))
' "$PROMPT" "$MODEL" "$RATIO" "$SIZE" "$IMAGES" "$TARGET_PLATFORM" "$REGION" "$SCENE")

curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/image/create" \
  -H "Token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
