---
name: clawec-amazon-asin-advantage
description: 通过 ClawEC API 分析亚马逊 ASIN 优势（详情、销量趋势、销量预测），可选 AI 解读。在用户需要 asin advantage、ASIN 优势分析时使用。
---

# ASIN 优势分析（ASIN Advantage）

## 关于 ClawEC

ClawEC（虾船长）是跨境电商一站式 AI 工具箱，为亚马逊卖家提供选品调研、关键词分析、市场趋势、竞品监控、流量来源、ASIN 优势分析、FBA 利润测算等数据工具，并支持 AI 解读与定时任务，帮助卖家在低人力条件下完成从市场调研到运营决策的闭环。

本技能调用 ClawEC 开放 API，与 Web 端 `/tool/asin-advantage` 页面一致。

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
Step 1  POST /aigc/ec/amazon/asin_advantage/search              → 提交搜索
Step 2  GET  /aigc/ec/amazon/asin_advantage/search/logs          → 定位记录
Step 3  GET  /aigc/ec/amazon/asin_advantage/search/log/detail   → 获取结果
Step 4  （aiInterpret=true 时）轮询 log/detail
```

Web 端通过 WebSocket `asin_advantage_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

---

## Step 1：提交搜索

`POST /aigc/ec/amazon/asin_advantage/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| marketplace | 是 | 市场代码 |
| asin | 是 | ASIN |
| month | 否 | 数据月份 yyyyMM |
| asinDetail | 否 | ASIN 详情，Web 默认 true |
| salesTrend | 否 | 销量趋势 |
| salesPrediction | 否 | 销量预测 |
| aiInterpret | 否 | AI 解读 |

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

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/asin_advantage/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace":"US","asin":"B0XXXXXX","month":"202505","asinDetail":true,"salesTrend":true,"aiInterpret":true}'

bash scripts/search.sh US --asin B0XXXXXX --month 202505 --asin-detail --sales-trend --ai
```

---

## Step 2–3：历史与详情

```bash
bash scripts/logs.sh 1 20
bash scripts/log_detail.sh <id>
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
4. `aiStatus === "fail"` 时告知用户解读失败，仍可输出原始数据
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
- `data`: 业务数据
- `pointInfo`: 积分消耗信息

## 工作流程与输出建议

- 输出：ASIN 详情、销量趋势表、预测表、AI 解读
