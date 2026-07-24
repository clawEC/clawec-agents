---
name: clawec-image-create
description: 通过 ClawEC API 进行 AI 图片生成，支持选择模型/比例/分辨率、上传参考图、提交生成任务并查询结果。在用户需要 AI 生图、文生图、图生图、电商素材出图、参考图生成时使用。
---

# AI 图片生成

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 图片生成 API（与 Web 端 `image-create` 页面一致），完成模型选型、参考图上传、提交生成与结果查询。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **Token**: 在 https://www.clawec.com/?source=q-github-agent 注册并登录；也可在 https://www.clawec.com/api-key?source=q-github-agent 获取 API Key 作为 Token 使用
- **请求头**:
  - `Token: <TOKEN>`（登录 Token 或 API Key）
  - `Content-Type: application/json`（JSON 接口）
  - `Time-Zone: Asia/Shanghai`（可选，与 Web 端一致）

优先从环境变量 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY` 读取；未设置时向用户索取，勿硬编码。

> 注意：图片生成接口使用 `Token` 请求头，与 `/aigc/tool/*` 开放工具的 `Authorization: Bearer` 写法不同。

### 公共参数

Web 端所有请求会自动附带以下参数（GET 为 query，POST 为 body 字段）：

| 参数 | 说明 |
|------|------|
| platform | 平台标识，Web 端来自运行时配置 |
| terminal | 终端类型，Web 端固定 `4` |
| flag | 业务标识，Web 端来自运行时配置 |
| language | 语言，如 `zh-CN` |

脚本中可使用默认值：`platform=1&terminal=4&language=zh-CN`（上传接口同理）。

---

## 完整流程

```
1. GET  /aigc/ec_media/image/create/dic     → 获取 models / ratios / sizes
2. POST /upload/image                       → 上传参考图（可选，最多 12 张）
3. POST /aigc/ec_media/image/create         → 提交生成任务
4. GET  /aigc/ec_media/image/create/logs    → 轮询生成结果
```

生成通常为异步任务；提交成功后需轮询日志接口，直到对应记录的 `urls` 非空或 `fail=true`。

---

## 1. 获取模型列表（字典）

`GET /aigc/ec_media/image/create/dic`

返回可选的 **模型**、**比例**、**分辨率** 三组字典，提交生成时需使用其中的 `id` 字段。

### 调用

```bash
curl -s -G "https://www.clawec.com/api/aigc/ec_media/image/create/dic" \
  -H "Token: $CLAWEC_TOKEN" \
  --data-urlencode "platform=1" \
  --data-urlencode "terminal=4" \
  --data-urlencode "language=zh-CN"
```

或使用脚本：

```bash
bash scripts/dic.sh
```

### 响应 `data` 结构

| 字段 | 类型 | 说明 |
|------|------|------|
| models | array | 生成模型列表 |
| ratios | array | 画面比例列表，默认选第一个 |
| sizes | array | 分辨率列表，默认选第一个 |

#### models 元素（TypeRespString + 扩展字段）

| 字段 | 说明 |
|------|------|
| id | 模型 ID，提交 `model` 时使用 |
| title | 展示名称 |
| point | 每张图消耗积分（可选） |
| level | 所需会员等级（可选） |
| levelText | 等级展示文案（可选） |

#### ratios / sizes 元素

| 字段 | 说明 |
|------|------|
| id | 提交 `ratio` / `size` 时使用 |
| title | 展示名称，如 `16:9`、`2K` |

---

## 2. 上传参考图

`POST /upload/image`

multipart/form-data 上传本地图片，返回可访问 URL，再填入生成请求的 `images` 数组。

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| file | form | 是 | 图片文件 |
| platform | form | 是 | 如 `1` |
| terminal | form | 是 | 如 `4` |
| language | form | 否 | 如 `zh-CN` |

限制（与 Web 端一致）：

- 仅支持 `image/*`
- 单次生成最多 **12** 张参考图
- 返回 `data.url` 或 `data.path`；若为相对路径需拼接 Base URL

### 调用

```bash
curl -s -X POST "https://www.clawec.com/api/upload/image" \
  -H "Token: $CLAWEC_TOKEN" \
  -F "file=@/path/to/reference.jpg" \
  -F "platform=1" \
  -F "terminal=4" \
  -F "language=zh-CN"
```

或使用脚本：

```bash
bash scripts/upload.sh /path/to/reference.jpg
```

### 响应 `data` 示例

```json
{
  "url": "https://cdn.example.com/xxx.jpg"
}
```

---

## 3. 提交图片生成

`POST /aigc/ec_media/image/create`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| prompt | body | 是 | 提示词 |
| model | body | 否 | 模型 ID，来自 dic.models[].id |
| ratio | body | 否 | 比例 ID，来自 dic.ratios[].id |
| size | body | 否 | 分辨率 ID，来自 dic.sizes[].id |
| images | body | 否 | 参考图 URL 数组，来自上传接口 |

提示词中可引用参考图：上传后按顺序称为 `[图1]`、`[图2]` …，例如：`将[图1]中的产品放入白色背景`。

### 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/image/create" \
  -H "Token: $CLAWEC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "一只可爱的橙色猫咪，产品摄影风格",
    "model": "MODEL_ID",
    "ratio": "RATIO_ID",
    "size": "SIZE_ID",
    "images": ["https://cdn.example.com/ref.jpg"],
    "platform": 1,
    "terminal": 4,
    "language": "zh-CN"
  }'
```

或使用脚本：

```bash
bash scripts/create.sh \
  --prompt "一只可爱的橙色猫咪" \
  --model MODEL_ID \
  --ratio RATIO_ID \
  --size SIZE_ID \
  --images '["https://cdn.example.com/ref.jpg"]'
```

提交成功返回 `status: 1`；`data` 通常为空对象，实际图片在日志接口中获取。

---

## 4. 获取生成结果

`GET /aigc/ec_media/image/create/logs`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| start | query | 否 | 分页索引，从 `1` 开始，默认 `1` |
| size | query | 否 | 每页条数，Web 端默认 `5` |

### 调用

```bash
curl -s -G "https://www.clawec.com/api/aigc/ec_media/image/create/logs" \
  -H "Token: $CLAWEC_TOKEN" \
  --data-urlencode "start=1" \
  --data-urlencode "size=5" \
  --data-urlencode "platform=1" \
  --data-urlencode "terminal=4" \
  --data-urlencode "language=zh-CN"
```

或使用脚本：

```bash
bash scripts/logs.sh 1 5
```

### 响应 `data` 结构

| 字段 | 说明 |
|------|------|
| count | 总记录数 |
| more | `1` = 还有下一页，`0` = 无更多 |
| start | 下一页索引 |
| items | 生成记录数组 |

#### items 元素（ImageResultV2）

| 字段 | 说明 |
|------|------|
| id | 记录 ID |
| urls | 生成的图片 URL 数组；生成中时可能为空 |
| fail | `true` 表示生成失败 |
| param | 原始参数（prompt / model / ratio / size / images） |
| time | 创建时间字符串 |

### 轮询建议

1. 提交生成后立即请求 `logs?start=1&size=5`
2. 取最新一条（或匹配 prompt 的记录），检查 `urls` 与 `fail`
3. 若 `urls` 仍为空且 `fail` 不为 `true`，等待 3–5 秒后重试
4. Web 端亦通过 WebSocket `wss://www.clawec.com/api/aigc/socket` 接收 `image_result_refresh` 推送；脚本场景用轮询即可

### 删除记录（可选）

`GET /aigc/ec_media/image/log/delete?id=<记录ID>`

---

## 响应 envelope

所有接口统一外层结构：

```json
{
  "status": 1,
  "code": 200,
  "msg": "success",
  "data": { ... },
  "pointInfo": { "type": 0, "point": 0 }
}
```

- `status`: `1` = 成功，`0` = 失败
- `code`: 业务码；`2001` = 未登录/Token 无效，`2002` = 积分不足
- `data`: 业务数据（http 封装层通常直接返回此字段）
- `pointInfo`: 积分消耗信息

完整字段说明见 [references/response-schema.md](references/response-schema.md)。

---

## 工作流程

1. 确认用户提示词、是否需要参考图
2. 检查 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY`
3. 调用 **dic** 获取 model / ratio / size，按用户需求或默认选第一项
4. 若有参考图，逐个调用 **upload** 获取 URL
5. 调用 **create** 提交任务
6. 轮询 **logs** 直到拿到 `urls` 或确认 `fail`
7. 向用户展示图片链接与所用参数；失败时说明原因并建议调整提示词或积分充值

## 输出建议

默认中文摘要，包含：

- 使用的模型、比例、分辨率（展示 title，附 id）
- 提示词与参考图数量
- 生成结果：图片 URL 列表；失败时给出 `fail` 说明
- 积分消耗（若 `pointInfo` 或模型 `point` 有值）

## 示例

**输入**：生成一张「白色背景上的无线耳机产品图」，参考我上传的耳机照片

**步骤**：

1. `dic.sh` → 选定 model=`flux-pro`, ratio=`1:1`, size=`2K`
2. `upload.sh ref.jpg` → `https://cdn.../ref.jpg`
3. `create.sh --prompt "白色背景产品摄影，无线耳机，柔和布光" --model flux-pro --ratio 1:1 --size 2K --images '["https://cdn.../ref.jpg"]'`
4. `logs.sh` 轮询 → 返回 `urls: ["https://cdn.../output.png"]`

**输出摘要**：

- 模型：Flux Pro | 比例 1:1 | 分辨率 2K
- 提示词：白色背景产品摄影，无线耳机，柔和布光
- 参考图：1 张
- 结果：https://cdn.../output.png
