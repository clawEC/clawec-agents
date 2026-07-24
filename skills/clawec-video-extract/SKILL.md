---
name: clawec-video-extract
description: 通过 ClawEC API 从视频中提取信息（文案/脚本等），支持本地上传、抖音链接解析，SSE 流式返回 Markdown 结果，并可查询历史记录。在用户需要视频文案提取、视频内容分析、短视频脚本拆解时使用。
---

# 视频信息提取

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台。本技能调用 ClawEC 视频信息提取 API（与 Web 端 `video-extract` 页面一致）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **Token**: 登录 Token 或 API Key
- **请求头**: `Token: <TOKEN>`

优先从 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY` 读取。

公共参数：`platform`、`terminal=4`、`flag`、`language`（POST body 中附带）。

---

## 完整流程

```
1. POST /upload/file 或 /aigc/ec_media/douyin_video_url_extract  → 获取视频 URL
2. POST /aigc/ec_media/video/info/extract（SSE 流式）            → 提取结果
3. GET  /aigc/ec_media/video/info/extract/logs                   → 历史记录
```

最多同时处理 **12** 个视频。

---

## 1. 准备视频 URL

### 本地上传

`POST /upload/file`（multipart，`file` 字段）

```bash
bash scripts/upload_file.sh /path/to/video.mp4
```

### 抖音链接解析

`POST /aigc/ec_media/douyin_video_url_extract`

| 参数 | 必填 | 说明 |
|------|------|------|
| text | 是 | 抖音分享文案或链接 |

返回 `data` 为视频 URL 字符串或含 `url` 字段的对象。

```bash
bash scripts/douyin_extract.sh "复制打开抖音，看看... https://v.douyin.com/xxx"
```

### 直接使用 URL

视频地址需以 `http://` 或 `https://` 开头，无需额外接口。

---

## 2. 提交提取（SSE 流式）

`POST /aigc/ec_media/video/info/extract`

| 参数 | 必填 | 说明 |
|------|------|------|
| text | 是 | 提示词 / 提取指令 |
| videos | 是 | 视频 URL 数组 |

响应为 **SSE 流**，每行 `data: ...` 为 Markdown 文本片段，需拼接为完整结果。`\x0A` 解码为换行。

```bash
bash scripts/extract.sh \
  --prompt "提取视频中的卖点和口播文案" \
  --videos '["https://cdn.example.com/a.mp4"]'
```

curl 示例：

```bash
curl -sN -X POST "https://www.clawec.com/api/aigc/ec_media/video/info/extract" \
  -H "Token: $CLAWEC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text":"提取卖点","videos":["https://..."],"platform":1,"terminal":4,"language":"zh-CN"}'
```

---

## 3. 查询历史记录

`GET /aigc/ec_media/video/info/extract/logs?start=1&size=5`

| items 字段 | 说明 |
|------------|------|
| param.text | 提示词 |
| param.videos | 视频 URL 列表 |
| result | 提取结果（Markdown 字符串） |
| time | 时间 |

```bash
bash scripts/logs.sh 1 5
```

完整结构见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认提取目标（卖点、口播、脚本等）并撰写 prompt
2. 获取 1–12 个视频 URL（上传 / 抖音解析 / 直链）
3. 调用 extract，拼接 SSE 输出
4. 可选查询 logs 获取历史
5. 中文摘要返回提取内容
