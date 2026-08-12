---
name: clawec-ozon-keyword-hot-ranking
description: 通过 clawEC API 查询 Ozon 热搜词榜单。在用户需要热搜词、关键词榜单筛选时使用。
---

# Ozon热搜词榜单

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按周期与多维条件查询热搜词榜单。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/keyword/hot-ranking`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| pageNo | body | 否 | 分页页码，从1开始，最大10000；不传默认1；默认 `1` |
| pageSize | body | 否 | 分页大小，最大15；不传默认15；默认 `15` |
| level1CategoryId | body | 否 | 一级类目ID。对照：17027494=住宅和花园, 17027491=运动与休闲, 17027489=美容和卫生, 15621032=鞋类, 15621031=服装, 17027915=家具, 17027486=家用电器, 17027… |
| keyword | body | 否 | 关键词名称，支持中文、俄文、英文 |
| searchType | body | 否 | 关键词搜索类型：模糊搜索(FUZZY)、精确搜索(EXACT)；默认模糊搜索；默认 `FUZZY` |
| minSearchIndex | body | 否 | 最小搜索指数 |
| maxSearchIndex | body | 否 | 最大搜索指数 |
| minSearchVolumeGrowthRate | body | 否 | 最小搜索量增长率 |
| maxSearchVolumeGrowthRate | body | 否 | 最大搜索量增长率 |
| minOrderConversionRate | body | 否 | 最小订单转化率 |
| maxOrderConversionRate | body | 否 | 最大订单转化率 |
| minOrderedAmount | body | 否 | 最小已订购金额 |
| maxOrderedAmount | body | 否 | 最大已订购金额 |
| minOrderedProductCount | body | 否 | 最小已订购商品 |
| maxOrderedProductCount | body | 否 | 最大已订购商品 |
| minCartCount | body | 否 | 最小添加购物车次数 |
| maxCartCount | body | 否 | 最大添加购物车次数 |
| minCartAveragePrice | body | 否 | 最小购物车均价 |
| maxCartAveragePrice | body | 否 | 最大购物车均价 |
| minSupplyDemandRatio | body | 否 | 最小供需比 |
| maxSupplyDemandRatio | body | 否 | 最大供需比 |
| period | body | 是 | 数据周期：周(WEEK)、自然月(MONTH)、季度(QUARTER)、年度(YEAR) |
| updatePeriod | body | 否 | 查询数据更新账期。不传时默认取所选周期的最近账期值。周：yyyy-MM-dd；自然月：yyyy-MM；季度：yyyy-Qn；年度：yyyy |
| sortField | body | 否 | 排序字段：搜索指数(SEARCH_INDEX)、已订购金额(ORDERED_AMOUNT)、已订购商品数(ORDERED_PRODUCT_COUNT)；默认 SEARCH_INDEX；默认 `SEARCH_INDEX` |
| sortDirection | body | 否 | 排序方向，默认 DESC；默认 `DESC` |


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/keyword/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"period": "MONTH", "pageNo": "1", "pageSize": "15", "level1CategoryId": "15621042", "sortField": "SEARCH_INDEX", "sortDirection": "DESC"}'
```

筛选参数较多时，推荐直接传 JSON body（或 `@payload.json`）。
或使用脚本：

```bash
bash scripts/query.sh '{"period": "MONTH", "pageNo": "1", "pageSize": "15", "level1CategoryId": "15621042", "sortField": "SEARCH_INDEX", "sortDirection": "DESC"}'

bash scripts/query.sh @payload.json
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

1. 确认 period（必填：WEEK/MONTH/QUARTER/YEAR）及其他筛选；参数较多时用 JSON
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：周期、类目与主要筛选
- 热搜词列表核心指标
- 给出 2–3 条选词观察
