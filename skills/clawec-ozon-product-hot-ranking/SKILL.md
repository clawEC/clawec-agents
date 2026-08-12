---
name: clawec-ozon-product-hot-ranking
description: 通过 clawEC API 查询 Ozon 热销商品列表。在用户需要热销商品榜、类目爆款筛选时使用。
---

# Ozon热销商品列表

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按一级类目与多维筛选条件查询热销商品列表。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/product/hot-ranking`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| pageNo | body | 否 | 分页页码，从1开始，最大10000；不传默认1；默认 `1` |
| pageSize | body | 否 | 分页大小，最大15；不传默认15；默认 `15` |
| level1CategoryId | body | 是 | 一级类目ID。对照：17027494=住宅和花园, 17027491=运动与休闲, 17027489=美容和卫生, 15621032=鞋类, 15621031=服装, 17027915=家具, 17027486=家用电器, 17027… |
| period | body | 否 | 数据周期：近7天(SEVEN_DAY)、近28天(TWENTY_EIGHT_DAY)、自然月(MONTH)、季度(QUARTER)、年度(YEAR)；默认 `SEVEN_DAY` |
| updatePeriod | body | 否 | 查询数据更新账期。不传时默认取所选周期的最近账期值。近7天/近28天：yyyy-MM-dd；自然月：yyyy-MM；季度：yyyy-Qn；年度：yyyy |
| minSales | body | 否 | 销量最小值 |
| maxSales | body | 否 | 销量最大值 |
| minGmv | body | 否 | 销售额最小值，单位卢布 |
| maxGmv | body | 否 | 销售额最大值，单位卢布 |
| minPrice | body | 否 | 平均价格最小值 |
| maxPrice | body | 否 | 平均价格最大值 |
| minCreateDate | body | 否 | 商品卡创建日期最小值，yyyy-MM-dd |
| maxCreateDate | body | 否 | 商品卡创建日期最大值，yyyy-MM-dd |
| deliveryModes | body | 否 | 发货模式：FBS、FBO、rFBS、OZON；不传表示全部 |
| crossBorderSalePermission | body | 否 | 跨境禁售权限：1=跨境禁止销售，2=跨境允许销售；不传表示不限 |
| productType | body | 否 | 产品类型：1=本土产品，2=跨境产品，3=未知；不传表示全部 |
| salesLevel | body | 否 | 销售水平：1=头部销售，2=销售前1%，3=销售前10%，4=销售前50%；不传表示不限 |
| sortField | body | 否 | 排序字段：销量(SALES)、销售额(GMV)、价格(PRICE)；默认 `SALES` |
| sortDirection | body | 否 | 排序方向；默认 `DESC` |


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"level1CategoryId": "15621042", "period": "SEVEN_DAY", "pageNo": "1", "pageSize": "15", "sortField": "SALES", "sortDirection": "DESC"}'
```

筛选参数较多时，推荐直接传 JSON body（或 `@payload.json`）。
或使用脚本：

```bash
bash scripts/query.sh '{"level1CategoryId": "15621042", "period": "SEVEN_DAY", "pageNo": "1", "pageSize": "15", "sortField": "SALES", "sortDirection": "DESC"}'

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

1. 确认 level1CategoryId（必填）及其他筛选条件；参数较多时用 JSON
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：类目、周期与主要筛选
- 热销商品列表核心指标
- 给出 2–3 条选品观察
