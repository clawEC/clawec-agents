---
name: clawec-ozon-shop-hot-ranking
description: 通过 clawEC API 查询 Ozon 店铺热销榜单。在用户需要店铺热销榜、店铺筛选排行时使用。
---

# Ozon店铺热销榜单

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按类目、销量、评分等多条件查询店铺热销榜单。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/shop/hot-ranking`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| pageNo | body | 否 | 分页页码，从1开始，最大10000；不传默认1；默认 `1` |
| pageSize | body | 否 | 分页大小，最大15；不传默认15；默认 `15` |
| updatePeriod | body | 否 | 查询数据更新账期。不传时默认取最近账期 |
| categoryId | body | 否 | 一级类目ID。不传则查询全部类目。对照：17027494=住宅和花园, 17027491=运动与休闲, 17027489=美容和卫生, 15621032=鞋类, 15621031=服装, 17027915=家具, 17027486=家… |
| shopKeyword | body | 否 | 店铺ID、店铺名称或店铺链接 |
| minProductCount | body | 否 | 当前店铺产品数最小值 |
| maxProductCount | body | 否 | 当前店铺产品数最大值 |
| minSalableProductCount | body | 否 | 有销量产品数最小值 |
| maxSalableProductCount | body | 否 | 有销量产品数最大值 |
| minShopRating | body | 否 | 店铺评分最小值 |
| maxShopRating | body | 否 | 店铺评分最大值 |
| minSalesRate | body | 否 | 店铺动销率最小值 |
| maxSalesRate | body | 否 | 店铺动销率最大值 |
| minSales | body | 否 | 月销量最小值 |
| maxSales | body | 否 | 月销量最大值 |
| minGmv | body | 否 | 月销售额最小值 |
| maxGmv | body | 否 | 月销售额最大值 |
| shopLevel | body | 否 | 店铺级别：0 普通卖家，1 高级卖家，2 官方直营；-1 或不传表示全部 |
| openTimeRange | body | 否 | 开店周期筛选：1 小于1个月，2 1-3个月，3 3-6个月，4 6-12个月，5 1-3年，6 3-5年，7 大于5年 |
| shopArea | body | 否 | 店铺类型：1 跨境店铺，2 本土店铺，3 未知；不传表示全部 |


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/shop/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"pageNo": "1", "pageSize": "15", "categoryId": "15621042"}'
```

筛选参数较多时，推荐直接传 JSON body（或 `@payload.json`）。
或使用脚本：

```bash
bash scripts/query.sh '{"pageNo": "1", "pageSize": "15", "categoryId": "15621042"}'

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

1. 确认 按需传入筛选条件（参数较多时用 JSON）；可空条件查默认榜单
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：类目与主要筛选
- 热销店铺列表核心指标
- 给出 2–3 条店铺机会观察
