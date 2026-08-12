---
name: clawec-amazon-keyword-aba-research
description: 通过 clawEC API 查询亚马逊 ABA 官方关键词选品数据。在用户需要 ABA 选品、ABA 关键词排名与 Top ASIN 时使用。
---

# 亚马逊ABA选品

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按月查询 ABA 官方关键词搜索、购买、排名及 Top 品牌/ASIN 数据。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/amazon/data/keyword/aba_research`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| marketplace | body | 是 | 市场编码 US=美国 UK=英国 ES=西班牙 FR=法国 DE=德国 IT=意大利 CA=加拿大 JP=日本；默认 `US` |
| includeKeywords | body | 否 | 包含关键词，可为空表示全部 |
| date | body | 否 | 数据月份，格式yyyyMM |


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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/keyword/aba_research" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace": "US", "includeKeywords": "earbuds", "date": "202507"}'
```

或使用脚本：

```bash
bash scripts/query.sh US earbuds 202507
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

1. 确认 marketplace；可选 includeKeywords、date
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：市场、包含关键词、月份
- ABA 搜索/购买/排名与 Top 品牌/ASIN
- 给出 2–3 条 ABA 选品观察
