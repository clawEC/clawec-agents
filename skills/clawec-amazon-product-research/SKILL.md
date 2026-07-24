---
name: clawec-amazon-product-research
description: 通过 ClawEC API 进行亚马逊选产品调研（市场/月份/类目/关键词/fastMode 选品模式，可选 AI 解读）。在用户需要选产品、product research、亚马逊选品时使用。
---

# 选产品（Product Research）

## 关于 ClawEC

ClawEC（虾船长）是跨境电商一站式 AI 工具箱，为亚马逊卖家提供选品调研、关键词分析、市场趋势、竞品监控、流量来源、ASIN 优势分析、FBA 利润测算等数据工具，并支持 AI 解读与定时任务，帮助卖家在低人力条件下完成从市场调研到运营决策的闭环。

本技能调用 ClawEC 开放 API，与 Web 端 `/tool/product-research` 页面一致。

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
Step 1  POST /aigc/ec/amazon/product_research/search              → 提交搜索
Step 2  GET  /aigc/ec/amazon/product_research/search/logs          → 定位记录
Step 3  GET  /aigc/ec/amazon/product_research/search/log/detail   → 获取结果
Step 4  （aiInterpret=true 时）轮询 log/detail                    → 等待 AI 解读
```

Web 端通过 WebSocket `product_research_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

类目列表（可选）：`GET /aigc/ec/amazon/category_research/categories?marketplace=US&month=202505`

---

## Step 1：提交搜索

`POST /aigc/ec/amazon/product_research/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| marketplace | 是 | 市场代码 |
| month | 是 | 数据月份 yyyyMM |
| keyword | 否 | 关键词 |
| nodeIdPaths | 否 | 类目路径数组 |
| matchType | 否 | Web 端固定 `2` |
| aiInterpret | 否 | AI 解读，默认 false |
| fastMode 过滤器 | 否 | 见下表 |

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

### fastMode（`--fast-mode`）

| ID | 模式 |
|----|------|
| low_price_long_tail | 低价长尾 |
| sales_surge | 销量飙升 |
| potential_market | 潜力市场 |
| unmet_market | 未被满足市场 |
| speculative_market | 投机市场 |
| broad_listing | 全品类铺货 |
| premium_listing | 精品铺货 |
| low_price | 低价商品 |
| beginner | 新手推荐 |

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/product_research/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace":"US","month":"202505","keyword":"phone case","matchType":2,"page":1,"size":50,"nodeIdPathEqual":false,"aiInterpret":true}'

bash scripts/search.sh US --month 202505 --keyword "phone case" --ai
bash scripts/search_and_poll.sh US --month 202505 --fast-mode beginner --ai
```

---

## Step 2：历史列表

`GET /aigc/ec/amazon/product_research/search/logs?start=1&size=20`

```bash
bash scripts/logs.sh 1 20
```

---

## Step 3：详情

`GET /aigc/ec/amazon/product_research/search/log/detail?id=<ID>`

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
4. `aiStatus === "fail"` 时告知用户解读失败，仍可输出原始数据
5. 建议最多轮询 **60 次**（约 3–5 分钟），超时则返回当前状态并提示稍后重查

```bash
bash scripts/search_and_poll.sh US --month 202505 --keyword "phone case" --ai
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

1. 确认 marketplace、month；可选 keyword、nodeIdPaths、fastMode
2. 调用 search → logs 匹配 → log/detail
3. 若 aiInterpret，轮询 AI
4. 输出中文摘要：条件、Top 商品、指标、AI 解读

## 输出建议

- 搜索条件、结果条数、Top ASIN（BSR/销量/价格/利润率）
- AI 解读全文（若开启）
