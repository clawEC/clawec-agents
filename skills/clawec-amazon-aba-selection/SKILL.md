---
name: clawec-amazon-aba-selection
description: 通过 ClawEC API 进行亚马逊 ABA 选品（按类目与时间维度分析 ABA 市场趋势，发现热门与异动关键词，支持搜索模式筛选与 AI 解读）。在用户需要 ABA 选品、亚马逊 ABA 选品、market trend、市场趋势选品、/tool/market-trend-analysis 时使用。
---

# ABA 选品

## 关于 ClawEC

ClawEC（虾船长）是跨境电商一站式 AI 工具箱，为亚马逊卖家提供选品调研、关键词分析、ABA 选品、竞品监控、流量来源、ASIN 优势分析、FBA 利润测算等数据工具，并支持 AI 解读与定时任务，帮助卖家在低人力条件下完成从市场调研到运营决策的闭环。

本技能调用 ClawEC 开放 API，与 Web 端「亚马逊ABA选品」页面 `/tool/market-trend-analysis` 一致。

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
Step 1  POST /aigc/ec/amazon/market_trend/search              → 提交 ABA 选品搜索
Step 2  GET  /aigc/ec/amazon/market_trend/search/logs          → 定位本次记录
Step 3  GET  /aigc/ec/amazon/market_trend/search/log/detail   → 获取完整结果
Step 4  （aiInterpret=true 时）轮询 log/detail                → 等待 AI 解读完成
```

Web 端通过 WebSocket `market_trend_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

---

## Step 1：提交 ABA 选品搜索

`POST /aigc/ec/amazon/market_trend/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| marketplace | 是 | 市场代码（Web 端称 region） |
| date | 是 | 数据月份 yyyyMM |
| departments | 否 | 类目数组 |
| searchModel | 否 | 搜索模式 1–6 |
| aiInterpret | 否 | 是否开启 AI 解读，默认 `false` |

### marketplace

| 代码 | 市场 |
|------|------|
| US | 美国 |
| UK | 英国 |
| ES | 西班牙 |
| FR | 法国 |
| DE | 德国 |
| IT | 意大利 |
| CA | 加拿大 |
| JP | 日本 |

### searchModel

| 值 | 模式 |
|----|------|
| 1 | 热门市场 |
| 2 | 异动市场 |
| 3 | 持续增长市场 |
| 4 | 快速飙升市场 |
| 5 | 潜力市场 |
| 6 | 长尾市场 |

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/market_trend/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace":"US","date":"202505","searchModel":1,"aiInterpret":true}'
```

或使用脚本：

```bash
bash scripts/search.sh US --date 202505 --search-model 1 --ai
bash scripts/search_and_poll.sh US --date 202505 --departments "Electronics" --ai
```

---

## Step 2：搜索历史列表

`GET /aigc/ec/amazon/market_trend/search/logs`

| 参数 | 说明 |
|------|------|
| start | 分页索引，从 1 开始 |
| size | 每页条数，默认 20 |

```bash
bash scripts/logs.sh 1 20
```

---

## Step 3：搜索详情

`GET /aigc/ec/amazon/market_trend/search/log/detail?id=<记录ID>`

```bash
bash scripts/log_detail.sh 123456789
```

| 字段 | 说明 |
|------|------|
| aiStatus | `appending` 解读中；`success` 已完成；`fail` 失败 |
| aiAnalysis | AI 解读正文（Markdown） |
| param.aiInterpret | 是否请求了 AI 解读 |

---

## Step 4：AI 解读轮询

当 `aiInterpret=true` 时，搜索完成后 AI 解读为异步任务：

1. 调用 `log/detail`，检查 `aiStatus`
2. `aiStatus === "appending"` 或尚无 `aiStatus` 时，等待 **3–5 秒** 后重试
3. `aiStatus === "success"` 时读取 `aiAnalysis` 并输出
4. `aiStatus === "fail"` 时告知用户解读失败，仍可输出原始 ABA 数据
5. 建议最多轮询 **60 次**（约 3–5 分钟），超时则返回当前状态并提示稍后重查

一键执行：

```bash
bash scripts/search_and_poll.sh US --date 202505 --search-model 2 --ai
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

## 工作流程

1. 确认 marketplace、date；可选 departments、searchModel
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 调用 **market_trend/search** 提交 ABA 选品搜索
4. 调用 **logs** 匹配本次记录 ID
5. 调用 **log/detail** 获取完整结果
6. 若开启 AI 解读，轮询直到 `aiStatus` 为 `success` 或 `fail`
7. 整理中文摘要：类目、Top 关键词、搜索量/购买率、AI 解读

## 输出建议

默认中文摘要，包含：

- 搜索条件：市场、月份、类目、搜索模式
- **汇总**：结果条数、Top 关键词与搜索量
- **Top 品牌**
- **明细表**（按需）：关键词、排名、搜索量、购买率
- **AI 解读**（若开启）：完整输出 `aiAnalysis`
