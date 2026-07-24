# Ozon 热搜词榜单 — 响应结构

## 顶层 DataResponseHotKeywordRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | HotKeywordRankingPage | 分页结果 |

## 请求体 HotKeywordRankingQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| period | string | 是 | `WEEK` / `MONTH` / `QUARTER` / `YEAR` |
| pageNo | integer | 否 | 页码，1–10000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–15，默认 `15` |
| level1CategoryId | integer | 否 | 一级类目 ID |
| keyword | string | 否 | 关键词（中/俄/英） |
| searchType | string | 否 | `FUZZY`（默认）/ `EXACT` |
| minSearchIndex / maxSearchIndex | integer | 否 | 搜索指数区间 |
| minSearchVolumeGrowthRate / maxSearchVolumeGrowthRate | number | 否 | 搜索量增长率区间 |
| minOrderConversionRate / maxOrderConversionRate | number | 否 | 订单转化率区间 |
| minOrderedAmount / maxOrderedAmount | number | 否 | 已订购金额区间 |
| minOrderedProductCount / maxOrderedProductCount | integer | 否 | 已订购商品数区间 |
| minCartCount / maxCartCount | integer | 否 | 加购次数区间 |
| minCartAveragePrice / maxCartAveragePrice | number | 否 | 购物车均价区间 |
| minSupplyDemandRatio / maxSupplyDemandRatio | number | 否 | 供需比区间 |
| updatePeriod | string | 否 | 账期；格式随 `period` 变化 |
| sortField | string | 否 | `SEARCH_INDEX` / `ORDERED_AMOUNT` / `ORDERED_PRODUCT_COUNT`，默认 `SEARCH_INDEX` |
| sortDirection | string | 否 | `ASC` / `DESC`，默认 `DESC` |

## data：HotKeywordRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | HotKeywordRankingSummary[] | 当前分页数据 |
| total | integer | 总记录数 |
| pageNo | integer | 当前页码 |
| pageSize | integer | 每页条数 |

## HotKeywordRankingSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| keywordId | integer | 关键词 ID |
| keyword | string | 关键词俄文 |
| keywordCn | string | 关键词中文 |
| categoryId | integer | 类目 ID |
| categoryName | string | 所属类目路径（俄/中） |
| searchIndex | integer | 搜索指数 |
| searchIndexGrowthRate | string | 搜索指数增长率 |
| conversionIndex | string | 转化指数 |
| cartConversionRate | string | 加购转化率 |
| exposureIndex | string | 曝光指数 |
| productCount | integer | 商品数 |
| supplyDemandRatio | string | 供需比 |
| orderedProductCount | integer | 已订购商品数 |
| orderConversionRate | string | 订单转化率 |
| orderedAmount | string | 已订购金额 |
| averageBrowseProductCount | integer | 平均浏览商品数 |
| cartAveragePrice | string | 购物车均价 |
| competitorCount | integer | 竞争对手数 |
| searchVolumeGrowthRate | string | 搜索量增长率 |
| noActionQueryCount | integer | 无操作查询数 |
| noActionQueryShare | string | 无操作查询占比 |
| similarResultQueryCount | integer | 类似结果查询数 |
| similarResultQueryRatio | string | 类似结果查询占比 |
| noResultQueryCount | integer | 无结果查询数 |
| noResultQueryRatio | string | 无结果查询占比 |
| updatePeriod | string | 更新账期 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 展示优先用 `keywordCn`，必要时附带俄文 `keyword`。
3. 选词时同时看：`searchIndex`、`searchIndexGrowthRate`、`orderConversionRate`、`orderedAmount`、`supplyDemandRatio`、`competitorCount`。
4. `period` 为必填；未指定类目时为全站/默认范围（以实际返回为准）。
5. `pageSize` 上限 15；结合 `total` 提示是否翻页。百分比与金额多为字符串，展示保留原文。
