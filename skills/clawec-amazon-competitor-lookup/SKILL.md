---
name: clawec-amazon-competitor-lookup
description: 通过 clawEC API 按关键词、品牌、卖家或 ASIN 查询竞品表现。在用户需要竞品监控、竞品调研、competitor lookup 时使用。
---

# 亚马逊竞品监控

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按关键词、品牌、卖家或 ASIN 列表查询竞品商品表现数据。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/amazon/data/competitor/lookup`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| marketplace | body | 是 | 市场编码 US=美国 UK=英国 ES=西班牙 FR=法国 DE=德国 IT=意大利 CA=加拿大 JP=日本 |
| month | body | 否 | 查询月份，格式yyyyMM，示例：202507 |
| brand | body | 否 | 品牌 |
| sellerName | body | 否 | 卖家 |
| asins | body | 否 | ASIN列表，最多40个 |
| keyword | body | 否 | 关键字 |

asins 最多 40 个。

### marketplace 取值

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

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/competitor/lookup" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace": "US", "month": "202507", "asins": "B07Z82895W", "keyword": ""}'
```

或使用脚本：

```bash
bash scripts/query.sh US 202507 "" "" B07Z82895W
```

## 响应结构

```json
{
  "status": 1,
  "data": { ... }
}
```

- `status`: `1` = 成功，`0` = 失败
- 成功时解析 `data` 按用户需求整理为中文摘要即可（无需卡片组件）


## 工作流程

1. 确认 marketplace；并至少提供 brand / sellerName / asins / keyword 之一
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：市场、月份、品牌/卖家/ASIN/关键词
- 竞品表现对比表
- 给出 2–3 条竞争观察
