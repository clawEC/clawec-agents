# 短视频仿写 — 响应结构

## 视频准备

同 video-extract：`POST /upload/file`、`POST /aigc/ec_media/douyin_video_url_extract`。

## POST /aigc/ec_media/video/info/extract

Step1 固定 `text: "提取视频中的文案"`，`videos: [url]`，SSE 流式返回原文案。

## POST /aigc/ec_media/video/text/clone

| 字段 | 说明 |
|------|------|
| text | 原文案 |
| prompt | 可选仿写指令 |

SSE 流式返回仿写文案。

## POST /aigc/ec_media/video/text/clone/log/save

| 字段 | 说明 |
|------|------|
| logId | 0=新建 |
| videoUrl | 源视频 |
| videoText | 原文 |
| cloneText | 仿写文 |

响应 `data`：新 logId（数字）。

## GET /aigc/ec_media/video/text/clone/logs

| items[] | 说明 |
|---------|------|
| logId | ID |
| videoUrl | 视频 |
| videoText | 原文 |
| cloneText | 仿写 |
| time | 时间 |

## GET /aigc/voice/style/list

数组元素：`{ name, value, desc, previewUrl }`。

## POST /aigc/ec_media/voice_create

| 字段 | 说明 |
|------|------|
| text | 纯文本 |
| voiceId | 音色 value |

响应：音频 URL 字符串或对象。
