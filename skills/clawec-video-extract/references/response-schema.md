# 视频信息提取 — 响应结构

## POST /aigc/ec_media/douyin_video_url_extract

请求：`{ text }`  
响应 `data`：视频 URL 字符串，或 `{ url }` / `{ href }` 等。

## POST /aigc/ec_media/video/info/extract

请求：

| 字段 | 说明 |
|------|------|
| text | 提取提示词 |
| videos | 视频 URL 数组（最多 12） |

响应：**SSE 流**，`data:` 行拼接为 Markdown 文本。

## GET /aigc/ec_media/video/info/extract/logs

| items[] | 说明 |
|---------|------|
| param.text | 提示词 |
| param.videos | 视频 URL 列表 |
| result | Markdown 结果 |
| time | 时间 |
