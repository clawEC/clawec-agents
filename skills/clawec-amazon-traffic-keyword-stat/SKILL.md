---
name: clawec-amazon-traffic-keyword-stat
description: 通过 clawEC API 查询亚马逊 ASIN 流量词数量统计（全部流量词、自然排名词、广告词及类型分布）。在用户需要亚马逊流量词统计、自然/广告词占比、竞品关键词覆盖分析时使用。
---

# 亚马逊流量词统计

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于查询指定 ASIN 在特定市场下的流量关键词数量统计（全部 / 自然 / 广告及类型分布）。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/amazon/data/traffic/keyword_stat`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| marketplace | body | 是 | 市场编码；默认 `US` |
| asin | body | 是 | 商品 ASIN |
| month | body | 否 | 查询月份，格式 `yyyyMM`；不传则返回最新可用数据 |

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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/traffic/keyword_stat" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace":"US","asin":"B07Z82895W"}'
```

指定月份：

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/traffic/keyword_stat" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace":"UK","asin":"B07Z82895W","month":"202405"}'
```

或使用脚本：

```bash
bash scripts/query.sh US B07Z82895W

bash scripts/query.sh UK B07Z82895W 202405
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

1. 确认 `marketplace`、`asin`；如用户指定月份则校验 `yyyyMM`
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥、ASIN 与站点
5. 解析返回数据，整理为中文流量词统计摘要

## 输出建议

- 查询条件：市场、ASIN、月份
- 对比全部流量词 / 自然排名词 / 广告词数量及占比
- 给出 1–2 条关键词覆盖或 PPC 观察
