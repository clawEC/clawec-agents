---
name: clawec-tiktok-product-analysis
description: 通过 ClawEC API 对 TikTok Shop 单品做商品分析（渠道分布、内容形式、付费/自然流量、每日趋势），可选 AI 解读。在用户需要 TikTok 商品分析、单品调研、product analysis、解析商品链接或 ID、/tool/tiktok-product-analysis 时使用。
---

# TikTok 商品分析

## 关于 ClawEC

ClawEC（虾船长）是**跨境电商一站式 AI 工具箱**，覆盖 TikTok Shop、Amazon 等主流平台的选品、调研、运营与合规场景。平台将分散的数据查询与人工分析沉淀为可复用的 Web 工具与开放 API，并配合 **AI 解读**与**定时任务**，帮助卖家在单人或少人条件下完成从市场洞察到决策落地的闭环。

在 **TikTok Shop** 方向，ClawEC 可做的事包括：**选品机会分析**（扫描品类近 7 天热销、判断商品阶段与进入窗口）、**商品分析**（拆解渠道分布、内容形式与付费/自然流量）、**店铺分析**（查看店铺规模、类目/地区排名与自营品牌账号）。本技能调用商品分析 API，与 Web 端 `/tool/tiktok-product-analysis` 页面一致。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent 注册帐号，然后去 https://www.clawec.com/api-key?source=q-github-agent 获取 key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

---

## 完整流程

```
Step 1  POST /aigc/ec/tiktok/product_analysis/search              → 提交分析
Step 2  GET  /aigc/ec/tiktok/product_analysis/search/logs          → 定位本次记录
Step 3  GET  /aigc/ec/tiktok/product_analysis/search/log/detail   → 获取完整结果
Step 4  （aiInterpret=true 时）轮询 log/detail                     → 等待 AI 解读完成
```

Web 端通过 WebSocket `tiktok_product_analysis_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

完整 API 字段见 [docs/titkok-product-api.md](../../../docs/titkok-product-api.md)。

---

## Step 1：提交商品分析

`POST /aigc/ec/tiktok/product_analysis/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| product | 是 | 商品 ID 或 TikTok Shop 商品链接 |
| region | 否 | 目标市场代码；不传时尝试从链接解析，默认 `US` |
| aiInterpret | 否 | 是否开启 AI 解读，默认 `false` |

### region 取值

| 代码 | 市场 |
|------|------|
| US | 美国 |
| UK | 英国 |
| ID | 印度尼西亚 |
| TH | 泰国 |
| MY | 马来西亚 |
| PH | 菲律宾 |
| VN | 越南 |
| SG | 新加坡 |
| BR | 巴西 |
| MX | 墨西哥 |
| DE | 德国 |
| FR | 法国 |
| IT | 意大利 |
| ES | 西班牙 |
| JP | 日本 |

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/tiktok/product_analysis/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"product":"1732414658666402537","region":"US","aiInterpret":true}'
```

或使用脚本：

```bash
# 商品 ID + 市场
bash scripts/search.sh "1732414658666402537" US

# 商品链接 + AI 解读
bash scripts/search.sh "https://shop.tiktok.com/view/product/..." US --ai
```

---

## Step 2：分析历史列表

`GET /aigc/ec/tiktok/product_analysis/search/logs`

| 参数 | 说明 |
|------|------|
| start | 分页索引，从 1 开始 |
| size | 每页条数，默认 20 |
| begin | 可选，开始时间戳 |
| end | 可选，结束时间戳 |

```bash
bash scripts/logs.sh 1 20
```

返回 `data.items` 为历史记录数组。提交分析后，按 `param.product`、`param.region` 匹配本次记录，取 `id` 作为详情查询参数。

---

## Step 3：分析详情

`GET /aigc/ec/tiktok/product_analysis/search/log/detail?id=<记录ID>`

```bash
bash scripts/log_detail.sh 123456789
```

详情 `data` 字段含完整分析结果，以及 AI 相关字段（若开启解读）：

| 字段 | 说明 |
|------|------|
| param | 原始搜索参数 |
| data.productId / data.title | 解析后的商品 ID、标题 |
| data.region / data.currency | 地区、货币 |
| data.overview | 概览指标（销量、GMV、达人/视频/直播占比等） |
| data.channel_distribution | 渠道分布（短视频、直播、商品卡等） |
| data.content_distribution | 内容形式分布 |
| data.ads_distribution | 付费/自然流量分布 |
| data.chart_list | 每日趋势数组 |
| aiStatus | `appending` 解读中；`success` 已完成；`fail` 失败 |
| aiStatusDesc | AI 解读状态描述 |
| aiAnalysis | AI 解读正文（Markdown） |

### data.overview 常见指标

概览为动态 Map，通常包含销量、GMV、达人带货占比、视频/直播贡献、增长率等，具体键名以 API 返回为准。

### data.channel_distribution

短视频、直播、商品卡等渠道的流量/销售贡献占比。

### data.content_distribution

不同内容形式（如达人视频、品牌自播、商品卡等）的分布。

### data.ads_distribution

付费推广与自然流量的占比与趋势。

### data.chart_list

每日趋势数据点数组，用于绘制销量/GMV/流量走势。

---

## Step 4：AI 解读轮询

当 `aiInterpret=true` 时，分析完成后 AI 解读为异步任务：

1. 调用 `log/detail`，检查 `aiStatus`
2. `aiStatus === "appending"` 或尚无 `aiStatus` 时，等待 **3–5 秒** 后重试
3. `aiStatus === "success"` 时读取 `aiAnalysis` 并输出
4. `aiStatus === "fail"` 时告知用户解读失败，仍可输出原始分析数据
5. 建议最多轮询 **60 次**（约 3–5 分钟），超时则返回当前状态并提示稍后重查

一键执行（分析 + 定位记录 + 拉详情 + AI 轮询）：

```bash
bash scripts/search_and_poll.sh "1732414658666402537" US --ai
```

---

## 响应结构

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

---

## 工作流程

1. 确认商品 `product`（ID 或链接）与目标市场 `region`（可选，默认 US）
2. 确认是否需要 `aiInterpret=true`
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 调用 **product_analysis/search** 提交分析
5. 调用 **logs** 匹配本次记录 ID；若暂未出现，等待 2–3 秒后重试
6. 调用 **log/detail** 获取完整 `data`
7. 若开启 AI 解读，轮询 **log/detail** 直到 `aiStatus` 为 `success` 或 `fail`
8. 整理中文摘要：商品基本信息、渠道/内容/付费结构、趋势要点、AI 解读（若有）

## 输出建议

默认中文摘要，包含：

- **搜索条件**：商品 ID/链接、市场
- **商品信息**：标题、地区、货币
- **概览指标**：销量、GMV、达人/视频/直播占比等核心数字
- **渠道结构**：短视频 vs 直播 vs 商品卡贡献
- **内容形式**：主要带货内容类型及占比
- **付费流量**：付费 vs 自然流量比例与特点
- **趋势**：`chart_list` 近 7/30 天走势一句话概括
- **AI 解读**（若开启）：完整输出 `aiAnalysis`；失败时说明状态

## 示例

**输入**：美国站商品 ID `1732414658666402537`，需要 AI 解读

**步骤**：

```bash
bash scripts/search_and_poll.sh "1732414658666402537" US --ai
```

**输出摘要**：

| 指标 | 值 |
|------|-----|
| 商品 | Wireless Earbuds Pro |
| 市场 | US |
| 近30天 GMV | $125K |
| 主渠道 | 短视频 68%、直播 22%、商品卡 10% |
| 付费占比 | 35% |

**AI 解读**：（Markdown 正文摘要）
