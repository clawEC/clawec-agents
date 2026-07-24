---
name: clawec-amazon-keyword-selection
description: 通过 ClawEC API 进行亚马逊关键词选品（通过关键词月搜索量、购买率、供需比与蓝海指数，找出细分市场中蕴藏的商机），可选 AI 解读。在用户需要关键词选品、亚马逊关键词选品、keyword research、/tool/keyword-research 时使用。
---

# 关键词选品

## 关于 ClawEC

ClawEC（虾船长）是跨境电商一站式 AI 工具箱，为亚马逊卖家提供选品调研、关键词选品、ABA 选品、竞品监控、流量来源、ASIN 优势分析、FBA 利润测算等数据工具，并支持 AI 解读与定时任务，帮助卖家在低人力条件下完成从市场调研到运营决策的闭环。

本技能调用 ClawEC 开放 API，与 Web 端「亚马逊关键词选品」页面 `/tool/keyword-research` 一致。

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
Step 1  POST /aigc/ec/amazon/keyword_research/search              → 提交关键词选品搜索
Step 2  GET  /aigc/ec/amazon/keyword_research/search/logs          → 定位本次记录
Step 3  GET  /aigc/ec/amazon/keyword_research/search/log/detail   → 获取完整结果
Step 4  （aiInterpret=true 时）轮询 log/detail                    → 等待 AI 解读完成
```

Web 端通过 WebSocket `keyword_research_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

---

## Step 1：提交关键词选品搜索

`POST /aigc/ec/amazon/keyword_research/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| region | 是 | 站点代码 |
| month | 否 | 数据月份 yyyyMM |
| departments | 否 | 类目 code 数组 |
| keyword | 否 | 关键词 |
| aiInterpret | 否 | 是否开启 AI 解读，默认 `false` |

### region

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

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/keyword_research/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"region":"US","month":"202505","keyword":"yoga mat","aiInterpret":true}'
```

或使用脚本：

```bash
bash scripts/search.sh US --month 202505 --keyword "yoga mat" --ai
bash scripts/search_and_poll.sh US --month 202505 --keyword "yoga mat" --ai
```

---

## Step 2：搜索历史列表

`GET /aigc/ec/amazon/keyword_research/search/logs`

```bash
bash scripts/logs.sh 1 20
```

---

## Step 3：搜索详情

`GET /aigc/ec/amazon/keyword_research/search/log/detail?id=<记录ID>`

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
4. `aiStatus === "fail"` 时告知用户解读失败，仍可输出原始关键词数据
5. 建议最多轮询 **60 次**（约 3–5 分钟），超时则返回当前状态并提示稍后重查

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
- `data`: 业务数据（含 `items` 关键词列表）
- `pointInfo`: 积分消耗信息

### items 核心字段

| 字段 | 说明 |
|------|------|
| keywords / keywordCn | 关键词 / 中文 |
| searches | 月搜索量 |
| purchaseRate | 购买率 |
| supplyDemandRatio | 供需比 |
| blueOceanIndex | 蓝海指数 |
| searchRank | 搜索排名 |

## 工作流程

1. 确认 `region`、可选 `month`、`departments`、`keyword`
2. 确认是否需要 `aiInterpret=true`
3. search → logs → log/detail；AI 轮询
4. 整理中文摘要：高潜力关键词、搜索量/购买率/蓝海指数、AI 解读

## 输出建议

- 搜索条件：市场、月份、类目、关键词
- **机会榜**：关键词、搜索量、购买率、供需比、蓝海指数
- **AI 解读**（若开启）：完整输出 `aiAnalysis`
