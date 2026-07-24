---
name: clawec-tiktok-product-research
description: 通过 ClawEC API 对 TikTok Shop 品类做选品机会分析（热销排行、阶段判断、进入窗口、达人/视频趋势），可选 AI 解读。在用户需要 TikTok 选品机会、品类扫描、product opportunity、TikTok 选品调研、/tool/tiktok-product-research 时使用。
---

# TikTok 选品机会分析

## 关于 ClawEC

ClawEC（虾船长）是**跨境电商一站式 AI 工具箱**，覆盖 TikTok Shop、Amazon 等主流平台的选品、调研、运营与合规场景。平台将分散的数据查询与人工分析沉淀为可复用的 Web 工具与开放 API，并配合 **AI 解读**与**定时任务**，帮助卖家在单人或少人条件下完成从市场洞察到决策落地的闭环。

在 **TikTok Shop** 方向，ClawEC 可做的事包括：**选品机会分析**（扫描品类近 7 天热销、判断商品阶段与进入窗口）、**商品分析**（拆解渠道分布、内容形式与付费/自然流量）、**店铺分析**（查看店铺规模、类目/地区排名与自营品牌账号）。本技能调用选品机会分析 API，与 Web 端 `/tool/tiktok-product-research` 页面一致。

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
Step 1  POST /aigc/ec/tiktok/product_opportunity/search              → 提交分析
Step 2  GET  /aigc/ec/tiktok/product_opportunity/search/logs          → 定位本次记录
Step 3  GET  /aigc/ec/tiktok/product_opportunity/search/log/detail   → 获取完整结果
Step 4  （aiInterpret=true 时）轮询 log/detail                        → 等待 AI 解读完成
```

Web 端通过 WebSocket `tiktok_product_opportunity_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

完整 API 字段见 [docs/tiktok-product-research-api.md](../../../docs/tiktok-product-research-api.md)。

---

## Step 1：提交选品机会分析

`POST /aigc/ec/tiktok/product_opportunity/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| region | 是 | 目标市场代码（见下表） |
| category | 是 | 品类关键词或名称，如「瑜伽裤」「手机壳」，用于匹配 TikTok 类目 |
| days | 否 | 分析周期天数，默认 `7`，对应近 N 天销量/GMV 等指标 |
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

未指定 `region` 时默认 `US`；未指定 `days` 时默认 `7`。

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/tiktok/product_opportunity/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"region":"US","category":"瑜伽裤","days":7,"aiInterpret":true}'
```

或使用脚本：

```bash
# 品类 + 市场 + 天数
bash scripts/search.sh "瑜伽裤" US 7

# 开启 AI 解读
bash scripts/search.sh "手机壳" US 7 --ai
```

---

## Step 2：分析历史列表

`GET /aigc/ec/tiktok/product_opportunity/search/logs`

| 参数 | 说明 |
|------|------|
| start | 分页索引，从 1 开始 |
| size | 每页条数，默认 20 |
| begin | 可选，开始时间戳 |
| end | 可选，结束时间戳 |

```bash
bash scripts/logs.sh 1 20
```

返回 `data.items` 为历史记录数组。提交分析后，按 `param.region`、`param.category`、`param.days` 匹配本次记录，取 `id` 作为详情查询参数。

---

## Step 3：分析详情

`GET /aigc/ec/tiktok/product_opportunity/search/log/detail?id=<记录ID>`

```bash
bash scripts/log_detail.sh 123456789
```

详情 `data` 字段含完整分析结果，以及 AI 相关字段（若开启解读）：

| 字段 | 说明 |
|------|------|
| param | 原始搜索参数 |
| data.categoryInfo | 解析后的类目信息 |
| data.categoryOverview | 类目竞争与市场概览 |
| data.items | 热销/机会商品排行 |
| data.openWindowCount | 对新卖家仍开放进入窗口的商品数量 |
| aiStatus | `appending` 解读中；`success` 已完成；`fail` 失败 |
| aiStatusDesc | AI 解读状态描述 |
| aiAnalysis | AI 解读正文（Markdown） |

### data.categoryInfo 核心字段

| 字段 | 说明 |
|------|------|
| categoryName | 类目中文名 |
| categoryFullName | 类目完整路径 |
| matchScore | 匹配分数 |

### data.categoryOverview 核心字段

| 字段 | 说明 |
|------|------|
| basicMetrics | 基础指标（类目规模、竞争密度等） |
| salesTrends | 销售趋势指标 |
| authorSalesMatrix | 达人带货矩阵（不同粉丝层级销售贡献） |
| competitionDensity | 竞争密度：低/中/高 |
| competitionDesc | 竞争密度说明 |

### data.items 核心字段（ProductOpportunityItem）

| 字段 | 说明 |
|------|------|
| rank | 排名 |
| productId / productName / cover / price | 商品 ID、名称、封面、价格 |
| day7UnitsSold / day7Gmv | 近 7 天销量 / GMV |
| totalUnitsSold / totalGmv | 累计销量 / GMV |
| growthRate | 增长率 |
| creatorCount / videoCount / sellerCount | 带货达人数 / 视频数 / 卖家数 |
| creatorTrend / videoTrend | 达人/视频趋势描述 |
| stage / stageDesc | 阶段：NEW/GROWTH/EXPLOSIVE/STABLE → 新品/成长/爆发/稳定 |
| entryWindowOpen / entryWindowReason | 进入窗口是否开放及说明 |
| fromNewListed | 是否来自新品榜 |
| detailUrl | 商品详情链接 |
| shop | 店铺信息 |

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
bash scripts/search_and_poll.sh "瑜伽裤" US 7 --ai
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

1. 确认目标市场 `region`、品类关键词 `category`、分析周期 `days`（默认 7）
2. 确认是否需要 `aiInterpret=true`
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 调用 **product_opportunity/search** 提交分析
5. 调用 **logs** 匹配本次记录 ID；若暂未出现，等待 2–3 秒后重试
6. 调用 **log/detail** 获取完整 `data`
7. 若开启 AI 解读，轮询 **log/detail** 直到 `aiStatus` 为 `success` 或 `fail`
8. 整理中文摘要：类目概览、竞争密度、开放窗口商品数、Top 机会品、AI 解读（若有）

## 输出建议

默认中文摘要，包含：

- **搜索条件**：市场、品类、分析天数
- **类目匹配**：`categoryInfo.categoryFullName`、匹配分数
- **市场概览**：竞争密度、基础指标与达人矩阵要点
- **机会汇总**：`openWindowCount`、结果条数
- **Top 机会品**（建议 Top 5–10）：排名、商品名、价格、近 7 天销量/GMV、阶段、进入窗口判断、达人/视频趋势
- **进入窗口开放品**：列出 `entryWindowOpen=true` 的商品及原因
- **AI 解读**（若开启）：完整输出 `aiAnalysis`；失败时说明状态

## 示例

**输入**：美国站，品类「phone case」，近 7 天，需要 AI 解读

**步骤**：

```bash
bash scripts/search_and_poll.sh "phone case" US 7 --ai
```

**输出摘要**：

| 指标 | 值 |
|------|-----|
| 匹配类目 | 手机配件 > 手机壳 |
| 竞争密度 | 中 |
| 开放窗口商品数 | 8 |
| 结果条数 | 50 |

**Top 机会品**：#1 iPhone 15 Case — 阶段：成长，近7天销量 12K，进入窗口：开放 …

**AI 解读**：（Markdown 正文摘要）
