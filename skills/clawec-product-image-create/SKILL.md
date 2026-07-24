---
name: clawec-product-image-create
description: 通过 ClawEC API 生成跨境电商商品图（主图/副图/详情图），支持选择目标平台与市场、模型/比例/分辨率、上传参考图、提交生成并查询结果。在用户需要商品主图、副图、详情图、A+ 图、电商产品图生成时使用。
---

# 商品图生成

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 商品图生成 API（与 Web 端 `product-image-create` 页面一致），面向跨境电商 Listing 素材场景。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **Token**: 在 https://www.clawec.com/?source=q-github-agent 注册并登录；也可在 https://www.clawec.com/api-key?source=q-github-agent 获取 API Key 作为 Token 使用
- **请求头**:
  - `Token: <TOKEN>`（登录 Token 或 API Key）
  - `Content-Type: application/json`（JSON 接口）
  - `Time-Zone: Asia/Shanghai`（可选，与 Web 端一致）

优先从环境变量 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY` 读取；未设置时向用户索取，勿硬编码。

> 注意：商品图生成接口使用 `Token` 请求头，与 `/aigc/tool/*` 开放工具的 `Authorization: Bearer` 写法不同。

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
1. GET  /aigc/ec_product_media/platform_options   → 获取目标平台与市场列表
2. GET  /aigc/ec_media/image/create/dic           → 获取 models / ratios / sizes
3. POST /upload/image                             → 上传参考图（可选，最多 12 张）
4. POST /aigc/ec_media/image/create               → 提交商品图生成任务
5. GET  /aigc/ec_media/image/create/logs/product  → 轮询生成结果
```

生成通常为异步任务；提交成功后需轮询日志接口，直到对应记录的 `urls` 非空或 `fail=true`。

与通用 `image-create` 技能的主要区别：

- 需先选 **目标平台**（`target_platform`，必填）和可选 **目标市场**（`region`）
- 需指定 **图片场景**（`image_scene`：主图 / 副图 / 详情图）
- 结果查询走 **`/logs/product`** 而非 `/logs`
- 提示词与参考图 **至少填一项** 即可提交

---

## 1. 获取平台与市场列表

`GET /aigc/ec_product_media/platform_options`

返回跨境电商平台及其下属市场（region），先选平台再选市场。

### 调用

```bash
curl -s -G "https://www.clawec.com/api/aigc/ec_product_media/platform_options" \
  -H "Token: $CLAWEC_TOKEN" \
  --data-urlencode "platform=1" \
  --data-urlencode "terminal=4" \
  --data-urlencode "language=zh-CN"
```

或使用脚本：

```bash
bash scripts/platform_options.sh
```

### 响应 `data` 结构（MarketResp 数组）

| 字段 | 说明 |
|------|------|
| code | 平台代码，提交 `target_platform` 时使用 |
| name | 平台名称，如 Amazon、Shopee |
| regions | 该平台下的市场列表 |

#### regions 元素（RegionResp）

| 字段 | 说明 |
|------|------|
| code | 市场代码，提交 `region` 时使用 |
| name | 市场名称，如 美国、日本 |

---

## 2. 获取模型列表（字典）

`GET /aigc/ec_media/image/create/dic`

与通用图片生成共用同一字典接口，返回 **模型**、**比例**、**分辨率**。

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

#### models 元素

| 字段 | 说明 |
|------|------|
| id | 模型 ID，提交 `model` 时使用 |
| title | 展示名称 |
| point | 每张图消耗积分（可选） |
| level | 所需会员等级（可选） |
| levelText | 等级展示文案（可选） |

---

## 3. 上传参考图

`POST /upload/image`

multipart/form-data 上传本地图片，返回 URL 填入生成请求的 `images` 数组。

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| file | form | 是 | 图片文件 |
| platform | form | 是 | 如 `1` |
| terminal | form | 是 | 如 `4` |
| language | form | 否 | 如 `zh-CN` |

限制：

- 仅支持 `image/*`
- 单次最多 **12** 张参考图
- 返回 `data.url` 或 `data.path`；相对路径需拼接 Base URL

### 调用

```bash
curl -s -X POST "https://www.clawec.com/api/upload/image" \
  -H "Token: $CLAWEC_TOKEN" \
  -F "file=@/path/to/product.jpg" \
  -F "platform=1" \
  -F "terminal=4" \
  -F "language=zh-CN"
```

或使用脚本：

```bash
bash scripts/upload.sh /path/to/product.jpg
```

---

## 4. 提交商品图生成

`POST /aigc/ec_media/image/create`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| prompt | body | 条件 | 提示词；与 `images` 至少填一项 |
| target_platform | body | 是 | 目标平台 code，来自 platform_options |
| image_scene | body | 否 | 图片场景，默认 `cover` |
| region | body | 否 | 目标市场 code，来自 platform_options.regions |
| model | body | 否 | 模型 ID |
| ratio | body | 否 | 比例 ID |
| size | body | 否 | 分辨率 ID |
| images | body | 否 | 参考图 URL 数组 |

### image_scene 取值

| 值 | 说明 | 路由别名 |
|----|------|----------|
| cover | 主图 | main、main_cover |
| cover_other | 副图 | sub、sub_cover |
| detail | 详情图 / A+ | aplus、a+ |

提示词中可引用参考图：按上传顺序称为 `[图1]`、`[图2]` …，例如：`参考[图1]的产品，生成亚马逊风格白底主图`。

### 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec_media/image/create" \
  -H "Token: $CLAWEC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "白色背景产品主图，无线耳机，专业电商摄影",
    "model": "MODEL_ID",
    "ratio": "RATIO_ID",
    "size": "SIZE_ID",
    "image_scene": "cover",
    "target_platform": "amazon",
    "region": "US",
    "images": ["https://cdn.example.com/ref.jpg"],
    "platform": 1,
    "terminal": 4,
    "language": "zh-CN"
  }'
```

或使用脚本：

```bash
bash scripts/create.sh \
  --target-platform amazon \
  --scene cover \
  --region US \
  --prompt "白色背景产品主图，无线耳机" \
  --model MODEL_ID \
  --ratio RATIO_ID \
  --size SIZE_ID \
  --images '["https://cdn.example.com/ref.jpg"]'
```

提交成功返回 `status: 1`；实际图片在 logs 接口获取。

---

## 5. 获取生成结果

`GET /aigc/ec_media/image/create/logs/product`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| start | query | 否 | 分页索引，从 `1` 开始 |
| size | query | 否 | 每页条数，Web 端默认 `5` |

### 调用

```bash
curl -s -G "https://www.clawec.com/api/aigc/ec_media/image/create/logs/product" \
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

#### items 元素

| 字段 | 说明 |
|------|------|
| id | 记录 ID |
| urls | 生成的图片 URL 数组；生成中可能为空 |
| fail | `true` 表示生成失败 |
| param | 原始参数（含 prompt / model / ratio / size / images / image_scene / target_platform / region） |
| time | 创建时间字符串 |

### 轮询建议

1. 提交后立即请求 `logs/product?start=1&size=5`
2. 取最新记录，检查 `urls` 与 `fail`
3. 若 `urls` 仍为空且 `fail` 不为 `true`，等待 3–5 秒后重试
4. Web 端通过 WebSocket `wss://www.clawec.com/api/aigc/socket` 接收 `image_result_refresh` 推送；脚本场景用轮询即可

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
- `data`: 业务数据
- `pointInfo`: 积分消耗信息

完整字段说明见 [references/response-schema.md](references/response-schema.md)。

---

## 工作流程

1. 确认图片场景（主图/副图/详情图）、目标平台与市场
2. 检查 `CLAWEC_TOKEN` 或 `CLAWEC_API_KEY`
3. 调用 **platform_options** 获取并选定 `target_platform` / `region`
4. 调用 **dic** 获取 model / ratio / size
5. 若有参考图，调用 **upload** 获取 URL
6. 确认提示词或参考图至少有一项，调用 **create** 提交
7. 轮询 **logs/product** 直到拿到 `urls` 或确认 `fail`
8. 向用户展示图片链接、场景、平台与市场信息

## 输出建议

默认中文摘要，包含：

- 图片场景（主图/副图/详情图）
- 目标平台与市场
- 使用的模型、比例、分辨率
- 提示词与参考图数量
- 生成结果 URL；失败时说明原因

## 示例

**输入**：为 Amazon 美国站生成无线耳机白底主图，参考已上传的产品照片

**步骤**：

1. `platform_options.sh` → target_platform=`amazon`, region=`US`
2. `dic.sh` → model / ratio / size
3. `upload.sh product.jpg` → 参考图 URL
4. `create.sh --target-platform amazon --region US --scene cover --prompt "白底主图，无线耳机" --images '[...]'`
5. `logs.sh` 轮询 → 返回生成 URL

**输出摘要**：

- 场景：主图 | 平台：Amazon | 市场：美国
- 模型 / 比例 / 分辨率：…
- 参考图：1 张
- 结果：https://cdn.../output.png
