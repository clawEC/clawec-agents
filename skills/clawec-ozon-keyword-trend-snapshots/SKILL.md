---
name: clawec-ozon-keyword-trend-snapshots
description: 通过 clawEC API 查询 Ozon 单个关键词趋势快照。在用户需要 Ozon 关键词趋势、词趋势快照时使用。
---

# Ozon关键词趋势快照

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按关键词 ID 查询趋势快照（仅支持单个关键词）。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/keyword/trend-snapshots`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| keywordId | body | 是 | 关键词ID，只能查询单个关键词 |
| period | body | 否 | 数据周期：周(WEEK)、自然月(MONTH)、季度(QUARTER)、年度(YEAR)；默认周榜；默认 `WEEK` |


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/keyword/trend-snapshots" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"keywordId": "12345", "period": "WEEK"}'
```

或使用脚本：

```bash
bash scripts/query.sh 12345 WEEK
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

1. 确认 keywordId；可选 period（WEEK/MONTH/QUARTER/YEAR）
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：关键词 ID、周期
- 趋势核心指标摘要
- 给出 1–2 条趋势观察
