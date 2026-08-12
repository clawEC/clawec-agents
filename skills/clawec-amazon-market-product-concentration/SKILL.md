---
name: clawec-amazon-market-product-concentration
description: 通过 clawEC API 查询亚马逊类目头部商品集中度。在用户需要商品集中度、头部 Listing 竞争分析时使用。
---

# 亚马逊类目商品集中度

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于查询指定类目下头部商品的销量/销售额集中度及竞争格局。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/amazon/data/market/product_concentration`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| marketplace | body | 是 | 市场编码 US=美国 UK=英国 ES=西班牙 FR=法国 DE=德国 IT=意大利 CA=加拿大 JP=日本；默认 `US` |
| nodeIdPath | body | 是 | 类目节点 id 路径，格式为 父节点ID:子节点ID。 家电-家电保修：2619525011:2242350011 家电-洗碗机：2619525011:3741271 家电-垃圾处理机：2619525011:18116205011 家…；默认 `1055398:1063252` |
| month | body | 否 | 筛选月份，格式yyyyMM，示例：202507；默认 `202507` |


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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/market/product_concentration" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace": "US", "nodeIdPath": "1055398:1063252", "month": "202507"}'
```

或使用脚本：

```bash
bash scripts/query.sh US 1055398:1063252 202507
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

1. 确认 marketplace、nodeIdPath；可选 month
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：市场、类目路径、月份
- 头部商品销量/销额集中度
- 给出 1–2 条商品格局观察
