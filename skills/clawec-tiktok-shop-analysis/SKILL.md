---
name: clawec-tiktok-shop-analysis
description: 通过 ClawEC API 对 TikTok Shop 店铺做经营分析（规模指标、类目/地区排名、店铺类型、品牌账号），可选 AI 解读。在用户需要 TikTok 店铺分析、竞品店铺调研、shop analysis、解析 seller_id 或店铺链接、/tool/tiktok-shop-analysis 时使用。
---

# TikTok 店铺分析

## 关于 ClawEC

ClawEC（虾船长）是**跨境电商一站式 AI 工具箱**，覆盖 TikTok Shop、Amazon 等主流平台的选品、调研、运营与合规场景。平台将分散的数据查询与人工分析沉淀为可复用的 Web 工具与开放 API，并配合 **AI 解读**与**定时任务**，帮助卖家在单人或少人条件下完成从市场洞察到决策落地的闭环。

在 **TikTok Shop** 方向，ClawEC 可做的事包括：**选品机会分析**（扫描品类近 7 天热销、判断商品阶段与进入窗口）、**商品分析**（拆解渠道分布、内容形式与付费/自然流量）、**店铺分析**（查看店铺规模、类目/地区排名与自营品牌账号）。本技能调用店铺分析 API，与 Web 端 `/tool/tiktok-shop-analysis` 页面一致。

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
Step 1  POST /aigc/ec/tiktok/shop_analysis/search              → 提交分析
Step 2  GET  /aigc/ec/tiktok/shop_analysis/search/logs          → 定位本次记录
Step 3  GET  /aigc/ec/tiktok/shop_analysis/search/log/detail   → 获取完整结果
Step 4  （aiInterpret=true 时）轮询 log/detail                  → 等待 AI 解读完成
```

Web 端通过 WebSocket `tiktok_shop_analysis_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

完整 API 字段见 [docs/tiktok-shop-api.md](../../../docs/tiktok-shop-api.md)。

---

## Step 1：提交店铺分析

`POST /aigc/ec/tiktok/shop_analysis/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| shop | 是 | 店铺 seller_id 或 TikTok Shop 店铺链接 |
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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/tiktok/shop_analysis/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"shop":"7494176112345678901","region":"US","aiInterpret":true}'
```

或使用脚本：

```bash
# seller_id + 市场
bash scripts/search.sh "7494176112345678901" US

# 店铺链接 + AI 解读
bash scripts/search.sh "https://shop.tiktok.com/view/shop/..." US --ai
```

---

## Step 2：分析历史列表

`GET /aigc/ec/tiktok/shop_analysis/search/logs`

| 参数 | 说明 |
|------|------|
| start | 分页索引，从 1 开始 |
| size | 每页条数，默认 20 |
| begin | 可选，开始时间戳 |
| end | 可选，结束时间戳 |

```bash
bash scripts/logs.sh 1 20
```

返回 `data.items` 为历史记录数组。提交分析后，按 `param.shop`、`param.region` 匹配本次记录，取 `id` 作为详情查询参数。

---

## Step 3：分析详情

`GET /aigc/ec/tiktok/shop_analysis/search/log/detail?id=<记录ID>`

```bash
bash scripts/log_detail.sh 123456789
```

详情 `data` 字段含完整分析结果，以及 AI 相关字段（若开启解读）：

| 字段 | 说明 |
|------|------|
| param | 原始搜索参数 |
| data.sellerId / data.name / data.avatar | 店铺 ID、名称、头像 |
| data.region | 市场/地区 |
| data.shopType | 店铺类型：跨境店/本地店 |
| data.isCrossBorder / data.isLocal | 是否跨境店 / 本地店 |
| data.metrics | 经营与规模指标 |
| data.categoryRank | 类目排名 |
| data.regionRank | 地区排名 |
| data.brandAccount | 自营品牌账号信息 |
| aiStatus | `appending` 解读中；`success` 已完成；`fail` 失败 |
| aiStatusDesc | AI 解读状态描述 |
| aiAnalysis | AI 解读正文（Markdown） |

### data.metrics 核心字段（ShopMetrics）

| 字段 | 说明 |
|------|------|
| totalGmv | 累计 GMV |
| totalUnitsSold | 累计销量（件） |
| productCount | 在售商品数 |
| authorCount | 累计带货达人数 |
| awemeCount | 累计带货视频数 |
| liveCount | 累计直播场次 |
| shopAge | 店铺年龄（天） |
| rating | 店铺评分 |
| fulfillmentRate | 履约率 |

### data.categoryRank / data.regionRank（RankInfo）

| 字段 | 说明 |
|------|------|
| rank | 排名 |
| name | 排名维度名称（类目名或地区名） |
| desc | 排名描述，可直接展示 |

### data.brandAccount（BrandAccountInfo）

| 字段 | 说明 |
|------|------|
| id | 账号 ID |
| name | 账号名称/昵称 |
| avatar | 头像 |

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
bash scripts/search_and_poll.sh "7494176112345678901" US --ai
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

1. 确认店铺 `shop`（seller_id 或链接）与目标市场 `region`（可选，默认 US）
2. 确认是否需要 `aiInterpret=true`
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 调用 **shop_analysis/search** 提交分析
5. 调用 **logs** 匹配本次记录 ID；若暂未出现，等待 2–3 秒后重试
6. 调用 **log/detail** 获取完整 `data`
7. 若开启 AI 解读，轮询 **log/detail** 直到 `aiStatus` 为 `success` 或 `fail`
8. 整理中文摘要：店铺画像、规模指标、排名、品牌账号、AI 解读（若有）

## 输出建议

默认中文摘要，包含：

- **搜索条件**：seller_id/链接、市场
- **店铺画像**：名称、类型（跨境/本地）、店铺年龄、评分、履约率
- **规模指标**：累计 GMV、销量、在售商品数、达人/视频/直播数量
- **排名**：类目排名、地区排名及描述
- **品牌账号**：自营账号名称（若有）
- **竞品对比要点**（按需）：与同类店铺的规模差异、达人矩阵特点
- **AI 解读**（若开启）：完整输出 `aiAnalysis`；失败时说明状态

## 示例

**输入**：美国站 seller_id `7494176112345678901`，需要 AI 解读

**步骤**：

```bash
bash scripts/search_and_poll.sh "7494176112345678901" US --ai
```

**输出摘要**：

| 指标 | 值 |
|------|-----|
| 店铺 | BeautyGlow Official |
| 类型 | 跨境店 |
| 累计 GMV | $2.5M |
| 在售商品 | 156 |
| 带货达人 | 1,200+ |
| 类目排名 | #12（美妆护肤） |

**AI 解读**：（Markdown 正文摘要）
