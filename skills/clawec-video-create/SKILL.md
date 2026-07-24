---
name: clawec-video-create
description: 通过 ClawEC API 进行 AI 视频生成，支持首尾帧/自由素材/纯提示词三种模式，含模型字典、积分预估、素材上传与结果查询。在用户需要 AI 生视频、文生视频、图生视频、首尾帧视频时使用。
---

# AI 视频生成

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台。本技能调用 ClawEC 视频生成 API（与 Web 端 `video-create` 页面一致）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **Token**: 登录 Token 或 API Key（https://www.clawec.com/api-key?source=q-github-agent）
- **请求头**: `Token: <TOKEN>`、`Content-Type: application/json`（JSON 接口）

优先从 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY` 读取。

公共参数（GET query / POST body）：`platform=1`、`terminal=4`、`language=zh-CN`。

---

## 完整流程

```
1. GET  /aigc/ec_media/video/create/dic        → models / ratios / sizes / lengths
2. POST /aigc/ec_media/video/point_calculate  → 预估积分（可选）
3. POST /upload/image 或 /upload/file          → 上传素材
4. POST /aigc/ec_media/video/create            → 提交生成
5. GET  /aigc/ec_media/video/create/logs       → 轮询结果
```

WebSocket `wss://www.clawec.com/api/aigc/socket` 推送 `video_result_refresh` 时可刷新 logs。

---

## 1. 获取字典

`GET /aigc/ec_media/video/create/dic`

| 字段 | 说明 |
|------|------|
| models | 模型列表 |
| ratios | 比例列表 |
| sizes | 分辨率列表 |
| lengths | 时长列表（秒，提交时 `length` 为数字） |

```bash
bash scripts/dic.sh
```

---

## 2. 积分预估

`POST /aigc/ec_media/video/point_calculate`

| 参数 | 必填 | 说明 |
|------|------|------|
| create_mode | 是 | 生成模式 `1`/`2`/`3` |
| model | 是 | 模型 ID |
| ratio | 是 | 比例 ID |
| size | 是 | 分辨率 ID |
| length | 否 | 时长（数字） |
| prompt | 否 | 可传 `.` 占位 |

返回 `data` 为预估积分数值。

```bash
bash scripts/point_calculate.sh --mode 1 --model MODEL_ID --ratio R_ID --size S_ID --length 5
```

---

## 3. 上传素材

### 首尾帧模式（create_mode=1）

`POST /upload/image` — 上传首帧（必填）/ 尾帧（可选）图片。

### 自由模式（create_mode=2）

`POST /upload/file` — 支持图片、视频、音频，最多 12 个素材。

```bash
bash scripts/upload_image.sh /path/to/frame.jpg
bash scripts/upload_file.sh /path/to/asset.mp4
```

---

## 4. 提交视频生成

`POST /aigc/ec_media/video/create`

| 参数 | 必填 | 说明 |
|------|------|------|
| prompt | 是 | 提示词 |
| create_mode | 是 | `1` 首尾帧 / `2` 自由素材 / `3` 纯提示词 |
| model | 是 | 模型 ID |
| ratio | 是 | 比例 ID |
| size | 是 | 分辨率 ID |
| length | 否 | 时长（数字） |
| attaches | 否 | 素材 URL 数组 |

**create_mode 规则**：

| 模式 | attaches | 约束 |
|------|----------|------|
| 1 | `[首帧URL, 尾帧URL?]` | 首帧必填 |
| 2 | 素材 URL 列表 | 最多 12 个 |
| 3 | 不传 | 仅 prompt |

```bash
bash scripts/create.sh \
  --mode 1 \
  --prompt "产品展示，缓慢旋转" \
  --model MODEL_ID --ratio R_ID --size S_ID --length 5 \
  --attaches '["https://cdn.../first.jpg","https://cdn.../last.jpg"]'
```

---

## 5. 获取生成结果

`GET /aigc/ec_media/video/create/logs?start=1&size=5`

| items 字段 | 说明 |
|------------|------|
| id | 记录 ID |
| url | 生成视频 URL |
| param | 原始参数 |
| time | 创建时间 |

轮询直到最新记录 `url` 非空。

```bash
bash scripts/logs.sh 1 5
```

删除：`GET /aigc/ec_media/video/log/delete?id=<ID>`

完整结构见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认生成模式与提示词
2. 调用 dic 选型
3. 按需上传素材
4. 可选 point_calculate 告知用户积分
5. 提交 create，轮询 logs
6. 返回视频 URL 与参数摘要
