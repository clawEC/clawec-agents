---
name: clawec-amazon-asin-traffic-source
description: 通过 ClawEC API 分析亚马逊 ASIN 流量来源（关键词流向、关联流量、流量词、出单词），可选 AI 解读。在用户需要 asin traffic source、流量来源分析时使用。
---

# ASIN 流量来源（Traffic Source）

## 关于 ClawEC

ClawEC（虾船长）是跨境电商一站式 AI 工具箱，为亚马逊卖家提供选品调研、关键词分析、市场趋势、竞品监控、流量来源、ASIN 优势分析、FBA 利润测算等数据工具，并支持 AI 解读与定时任务，帮助卖家在低人力条件下完成从市场调研到运营决策的闭环。

本技能调用 ClawEC 开放 API，与 Web 端 `/tool/asin-traffic-source` 页面一致。

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
Step 1  POST /aigc/ec/amazon/traffic_source/search              → 提交搜索
Step 2  GET  /aigc/ec/amazon/traffic_source/search/logs          → 定位记录
Step 3  GET  /aigc/ec/amazon/traffic_source/search/log/detail   → 获取结果
Step 4  （aiInterpret=true 时）轮询 log/detail
```

Web 端通过 WebSocket `traffic_source_result_refresh` 推送刷新；脚本场景用 **轮询 log/detail** 即可。

---

## Step 1：提交搜索

`POST /aigc/ec/amazon/traffic_source/search`

| 参数 | 必填 | 说明 |
|------|------|------|
| marketplace | 是 | 市场代码 |
| asin | 是 | ASIN |
| month | 是 | 数据月份 yyyyMM |
| trafficSource | 否 | 流量来源，Web 默认 true |
| trafficListingStat | 否 | 关联流量统计 |
| trafficKeyword | 否 | 关键词反查 |
| keywordOrder | 否 | 出单词反查 |
| aiInterpret | 否 | AI 解读 |

至少开启一项查询维度。

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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/traffic_source/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace":"US","asin":"B0XXXXXX","month":"202505","trafficSource":true,"trafficKeyword":true,"aiInterpret":true}'

bash scripts/search.sh US --asin B0XXXXXX --month 202505 --traffic-source --traffic-keyword --ai
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

- ASIN、month 必填；至少一项流量维度
- 输出：流量渠道分布、流量词表、出单词、AI 解读
