# 商品视频生成 — 响应结构

## GET /aigc/ec_product_video/image/create/avatar_options

| data | 说明 |
|------|------|
| items[] | `{ id, imageThumb, ... }` |
| count, more, start | 分页 |

## GET /aigc/ec_product_video/image/create/dic

models / ratios / sizes（同图片字典）。

## POST /aigc/ec_product_video/image/create

| 字段 | 必填 | 说明 |
|------|------|------|
| avatarId | 是 | 数字人 ID |
| model, ratio, size | 是 | 字典 ID |
| prompt | 否 | 场景描述 |
| images | 否 | 产品图 URL |

结果经 WebSocket：`product_video_image_result_refresh`，`data.images` 为 URL 数组。

## GET /aigc/ec_product_video/video/create/dic

models / ratios / sizes / lengths。

## POST /aigc/ec_product_video/text_create

| 字段 | 说明 |
|------|------|
| prompt | 创作要求 |
| model | 文本模型 ID |
| target_language | 目标语言 |
| video_length | 5–15 秒 |

响应 `data`：脚本文本字符串。

## POST /aigc/ec_product_video/video/create

| 字段 | 必填 | 说明 |
|------|------|------|
| prompt | 是 | 脚本 |
| create_mode | 是 | 固定 1 |
| model, ratio, size | 是 | 字典 ID |
| length | 否 | 时长 |
| attaches | 是 | 首帧 URL（必填） |

## GET /aigc/ec_product_video/video/create/logs

| items[] | 说明 |
|---------|------|
| id | 记录 ID |
| url | 视频 URL |
| param | 参数 |
| time | 时间 |

## WebSocket

- `video_result_refresh` → 刷新视频 logs
- `product_video_image_result_refresh` → 首帧候选图 `{ images: [] }`
