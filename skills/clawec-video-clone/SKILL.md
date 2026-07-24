---
name: clawec-video-clone
description: 通过 ClawEC API 实现短视频仿写：提取视频文案、AI 仿写、保存记录，可选语音合成。支持本地上传与抖音链接。在用户需要短视频文案仿写、爆款脚本改写、口播文案克隆时使用。
---

# 短视频仿写

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台。本技能调用 ClawEC 短视频仿写 API（与 Web 端 `video-clone` 页面一致）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **Token**: 登录 Token 或 API Key
- **请求头**: `Token: <TOKEN>`

优先从 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY` 读取。

---

## 完整流程

```
Step 0  准备视频 URL（上传 / 抖音解析 / 直链，仅 1 个视频）
Step 1  POST /aigc/ec_media/video/info/extract（SSE）     → 提取原文案
Step 2  POST /aigc/ec_media/video/text/clone（SSE）      → AI 仿写
Step 2b POST /aigc/ec_media/video/text/clone/log/save     → 保存仿写记录
Step 3  GET  /aigc/ec_media/video/text/clone/logs         → 历史记录
可选    GET  /aigc/voice/style/list + POST voice_create   → 文案转语音
```

---

## Step 0：准备视频

### 本地上传

`POST /upload/file`

```bash
bash scripts/upload_file.sh /path/to/video.mp4
```

### 抖音解析

`POST /aigc/ec_media/douyin_video_url_extract`

```bash
bash scripts/douyin_extract.sh "抖音分享文案..."
```

页面 Step1 固定 prompt 为「提取视频中的文案」，仅支持 **1** 个视频。

---

## Step 1：提取视频文案（SSE）

`POST /aigc/ec_media/video/info/extract`

| 参数 | 说明 |
|------|------|
| text | 固定为 `提取视频中的文案` |
| videos | 视频 URL 数组（1 个） |

```bash
bash scripts/extract.sh --videos '["https://cdn.../video.mp4"]'
```

---

## Step 2：AI 仿写（SSE）

`POST /aigc/ec_media/video/text/clone`

| 参数 | 必填 | 说明 |
|------|------|------|
| text | 是 | Step1 提取的原文案 |
| prompt | 否 | 仿写风格/要求指令 |

```bash
bash scripts/clone.sh \
  --text "原文案内容..." \
  --prompt "改写为跨境电商口播风格，保留卖点"
```

---

## Step 2b：保存仿写记录

`POST /aigc/ec_media/video/text/clone/log/save`

| 参数 | 说明 |
|------|------|
| logId | `0` 新建；已有 ID 则更新 |
| videoUrl | 源视频 URL |
| videoText | 原文案 |
| cloneText | 仿写结果 |

```bash
bash scripts/clone_log_save.sh \
  --video-url "https://..." \
  --video-text "原文" \
  --clone-text "仿写结果"
```

---

## Step 3：查询历史

`GET /aigc/ec_media/video/text/clone/logs?start=1&size=20`

| items 字段 | 说明 |
|------------|------|
| logId | 记录 ID |
| videoUrl | 源视频 |
| videoText | 原文案 |
| cloneText | 仿写文案 |
| time | 时间 |

```bash
bash scripts/clone_logs.sh 1 20
```

---

## 可选：文案转语音

### 获取音色列表

`GET /aigc/voice/style/list`

返回数组：`{ name, value, desc, previewUrl }`，提交时用 `value` 作为 `voiceId`。

```bash
bash scripts/voice_styles.sh
```

### 生成语音

`POST /aigc/ec_media/voice_create`

| 参数 | 说明 |
|------|------|
| text | 纯文本（去除 Markdown） |
| voiceId | 音色 value |

返回音频 URL 字符串或 `{ url }`。

```bash
bash scripts/voice_create.sh --text "仿写后的口播文案" --voice-id VOICE_VALUE
```

完整结构见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 获取 1 个视频 URL
2. extract 提取原文案
3. clone 仿写（可带风格 prompt）
4. 保存记录并返回仿写文案
5. 按需生成 TTS 音频
