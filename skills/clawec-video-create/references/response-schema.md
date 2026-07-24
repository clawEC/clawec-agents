# AI 视频生成 — 响应结构

## 通用 envelope

`status` `1`=成功；`code` `2001`=Token 无效，`2002`=积分不足；`data` 为业务数据。

## GET /aigc/ec_media/video/create/dic

| 字段 | 说明 |
|------|------|
| models | 模型 `{ id, title, point?, level?, levelText? }` |
| ratios | 比例 `{ id, title }` |
| sizes | 分辨率 `{ id, title }` |
| lengths | 时长 `{ id, title }`（id 为秒数） |

## POST /aigc/ec_media/video/point_calculate

请求：`create_mode`, `model`, `ratio`, `size`, `length?`, `prompt?`  
响应 `data`：数字（预估积分）。

## POST /aigc/ec_media/video/create

| 字段 | 必填 | 说明 |
|------|------|------|
| prompt | 是 | 提示词 |
| create_mode | 是 | 1/2/3 |
| model | 是 | 模型 ID |
| ratio | 是 | 比例 ID |
| size | 是 | 分辨率 ID |
| length | 否 | 时长数字 |
| attaches | 否 | 素材 URL 数组 |

## GET /aigc/ec_media/video/create/logs

| data 字段 | 说明 |
|-----------|------|
| count, more, start | 分页 |
| items[].id | 记录 ID |
| items[].url | 视频 URL |
| items[].param | 原始参数 |
| items[].time | 时间 |

## WebSocket

`{"type":"video_result_refresh"}` → 刷新 logs。
