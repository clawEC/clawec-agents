---
name: clawec-product-video-create
description: 通过 ClawEC API 生成跨境电商商品视频：数字人首帧合成、AI 写脚本、图生视频提交与结果查询。在用户需要商品短视频、带货视频、数字人商品视频、电商主图视频时使用。
---

# 商品视频生成

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台。本技能调用 ClawEC 商品视频 API（与 Web 端 `product-video-create` 页面一致）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **Token**: 登录 Token 或 API Key
- **请求头**: `Token: <TOKEN>`

优先从 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY` 读取。

---

## 完整流程（三步向导）

```
Step 1  数字人首帧
  GET  /aigc/ec_product_video/image/create/avatar_options  → 数字人列表
  GET  /aigc/ec_product_video/image/create/dic             → 首帧图字典
  POST /upload/image                                       → 上传产品图（最多 1 张）
  POST /aigc/ec_product_video/image/create                 → 生成首帧候选图
  WebSocket product_video_image_result_refresh             → 获取候选 URL

Step 2  选定首帧 URL，进入视频参数

Step 3  视频生成
  GET  /aigc/ec_product_video/video/create/dic             → 视频字典
  POST /aigc/ec_media/video/point_calculate              → 积分预估
  POST /aigc/ec_product_video/text_create（可选）         → AI 写脚本
  POST /upload/image（可选）                              → 手动上传首/尾帧
  POST /aigc/ec_product_video/video/create                 → 提交视频
  GET  /aigc/ec_product_video/video/create/logs            → 轮询结果
```

WebSocket 推送：`video_result_refresh`（视频）、`product_video_image_result_refresh`（首帧图）。

---

## Step 1：数字人首帧

### 1.1 数字人列表

`GET /aigc/ec_product_video/image/create/avatar_options`

| 参数 | 说明 |
|------|------|
| start | 分页，从 1 开始 |
| size | 每页条数 |
| gender | 可选筛选 |
| race | 可选筛选 |

items 元素含 `id`、`imageThumb` 等，提交首帧图时用 `avatarId`。

```bash
bash scripts/avatar_options.sh 1 10
```

### 1.2 首帧图字典

`GET /aigc/ec_product_video/image/create/dic` → models / ratios / sizes

```bash
bash scripts/image_dic.sh
```

### 1.3 上传产品图

`POST /upload/image`，最多 **1** 张产品参考图。

```bash
bash scripts/upload_image.sh /path/to/product.jpg
```

### 1.4 生成首帧候选图

`POST /aigc/ec_product_video/image/create`

| 参数 | 必填 | 说明 |
|------|------|------|
| avatarId | 是 | 数字人 ID |
| model | 是 | 模型 ID |
| ratio | 是 | 比例 ID（默认倾向 9:16） |
| size | 是 | 分辨率 ID |
| prompt | 否 | 场景描述 |
| images | 否 | 产品图 URL 数组 |

```bash
bash scripts/image_create.sh \
  --avatar-id AVATAR_ID \
  --model M_ID --ratio R_ID --size S_ID \
  --images '["https://cdn.../product.jpg"]' \
  --prompt "手持产品，电商直播间风格"
```

结果通过 WebSocket 推送：

```json
{ "type": "product_video_image_result_refresh", "data": { "images": ["url1", "url2"] } }
```

选定一张 URL 作为视频首帧 `attaches[0]`。

---

## Step 3：视频生成

### 3.1 视频字典

`GET /aigc/ec_product_video/video/create/dic` → models / ratios / sizes / lengths

```bash
bash scripts/video_dic.sh
```

### 3.2 积分预估

`POST /aigc/ec_media/video/point_calculate`（create_mode 固定为 1）

```bash
bash scripts/point_calculate.sh --model M_ID --ratio R_ID --size S_ID --length 10
```

### 3.3 AI 写脚本（可选）

`GET /aigc/ec_product_video/text_model/options` → 文本模型列表

`POST /aigc/ec_product_video/text_create`

| 参数 | 说明 |
|------|------|
| prompt | 创作要求 |
| model | 文本模型 ID |
| target_language | 目标语言，如 `简体中文` |
| video_length | 视频时长秒数 5–15 |

```bash
bash scripts/text_create.sh \
  --prompt "无线耳机带货口播" \
  --model TEXT_MODEL_ID \
  --lang "简体中文" \
  --length 10
```

返回生成脚本文本，作为视频 `prompt`。

### 3.4 提交视频生成

`POST /aigc/ec_product_video/video/create`

| 参数 | 必填 | 说明 |
|------|------|------|
| prompt | 是 | 视频脚本/提示词 |
| create_mode | 是 | 固定 `1`（首尾帧模式） |
| model | 是 | 模型 ID |
| ratio | 是 | 比例 ID |
| size | 是 | 分辨率 ID |
| length | 否 | 时长（数字） |
| attaches | 是 | `[首帧URL, 尾帧URL?]`，首帧必填 |

也可通过 `POST /upload/image` 手动上传首/尾帧后填入 attaches。

```bash
bash scripts/video_create.sh \
  --prompt "口播脚本..." \
  --model M_ID --ratio R_ID --size S_ID --length 10 \
  --attaches '["https://cdn.../first_frame.jpg"]'
```

### 3.5 查询结果

`GET /aigc/ec_product_video/video/create/logs?start=1&size=5`

| items 字段 | 说明 |
|------------|------|
| id | 记录 ID |
| url | 视频 URL |
| param | 原始参数 |
| time | 时间 |

```bash
bash scripts/video_logs.sh 1 5
```

删除：`GET /aigc/ec_product_video/video/log/delete?id=<ID>`

完整结构见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 选数字人 + 上传产品图 → 生成首帧候选 → 选定首帧
2. 可选 AI 写脚本，或用户提供 prompt
3. 选视频模型/比例/时长 → 提交 create → 轮询 logs
4. 返回视频 URL 与参数摘要
