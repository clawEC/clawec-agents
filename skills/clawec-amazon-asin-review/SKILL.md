---
name: clawec-amazon-asin-review
description: 通过 clawEC API 查询亚马逊 ASIN 买家评论。在用户需要 ASIN 评论、星级筛选、评论洞察时使用。
---

# 亚马逊ASIN评论查询

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于查询 ASIN 买家评论，支持按星级、评论类型筛选及分页。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/amazon/data/asin/review`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| marketplace | body | 是 | 市场编码 US=美国 UK=英国 ES=西班牙 FR=法国 DE=德国 IT=意大利 CA=加拿大 JP=日本；默认 `US` |
| asin | body | 是 | ASIN；默认 `B07Z82895W` |
| starList | body | 否 | 星级筛选列表，如 [5,4,3]；默认 `[5,4,3]` |
| typeList | body | 否 | 评论类型筛选列表 |
| page | body | 否 | 页码，默认1；默认 `1` |
| size | body | 否 | 每页条数，默认20；默认 `20` |


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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/asin/review" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace": "US", "asin": "B07Z82895W", "starList": "[5,4,3]", "page": "1", "size": "20"}'
```

或使用脚本：

```bash
bash scripts/query.sh US B07Z82895W [5,4,3] "" 1 20
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

1. 确认 marketplace、asin；可选 starList、typeList、page、size
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：市场、ASIN、星级/类型、分页
- 评论要点：星级分布、高频观点
- 给出 1–2 条产品改进/竞品观察
