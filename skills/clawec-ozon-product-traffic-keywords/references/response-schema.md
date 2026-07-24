# Ozon 商品流量词 — 响应结构

## 顶层 DataResponseProductTrafficKeywordPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ProductTrafficKeywordPage | 分页结果 |

## 请求体 ProductTrafficKeywordQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| itemIds | string | 是 | 商品 ID，英文逗号分隔，最多 10 个 |
| pageNo | integer | 否 | 页码，1–10000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–15，默认 `15` |
| keywordType | string | 否 | `ALL` / `THEME_TAG` / `NATURAL` / `AD_CPC` / `AD_ORDER` / `AD_SPECIAL`，默认 `ALL` |
| keyword | string | 否 | 俄文或中文，模糊查询 |
| sortField | string | 否 | 见技能文档排序表，默认 `SEARCH_INDEX` |
| sortDirection | string | 否 | `ASC` / `DESC`，默认 `DESC` |

## data：ProductTrafficKeywordPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ProductTrafficKeywordSummary[] | 当前分页数据 |
| total | integer | 总记录数 |
| pageNo | integer | 当前页码 |
| pageSize | integer | 每页条数 |

## ProductTrafficKeywordSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| keyword | string | 关键词俄文 |
| keywordCn | string | 关键词中文 |
| itemId | integer | 商品 ID |
| categoryId | integer | 类目 ID |
| categoryName | string | 所属类目路径（可含俄/中/英） |
| keywordType | string | 关键词类型 |
| searchIndex | integer | 搜索指数 |
| searchIndexGrowthRate | string | 搜索指数增长率 |
| conversionIndex | number | 转化指数 |
| cartConversionRate | string | 加购转化率 |
| exposureIndex | string | 曝光指数 |
| productCount | integer | 商品数 |
| supplyDemandRatio | string | 供需比 |
| orderedProductCount | integer | 已订购商品 |
| orderConversionRate | string | 订单转化率 |
| orderedAmount | string | 订购金额 |
| averageBrowseProductCount | integer | 平均浏览商品数 |
| cartAveragePrice | string | 加购均价 |
| competitorCount | integer | 竞争对手数 |
| searchVolumeGrowthRate | string | 搜索量增长率 |
| noActionQueryCount | integer | 无操作查询数 |
| noActionQueryShare | string | 无操作查询占比 |
| similarResultQueryCount | integer | 类似结果查询数 |
| similarResultQueryRatio | string | 类似结果查询占比 |
| noResultQueryCount | integer | 无结果查询数 |
| noResultQueryRatio | string | 无结果查询占比 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 展示优先用 `keywordCn`，必要时附带俄文 `keyword`。
3. 多商品查询时按 `itemId` 分组，再各自按搜索指数或转化排序。
4. 选词时同时看：`searchIndex`、`searchIndexGrowthRate`、`conversionIndex`、`orderConversionRate`、`supplyDemandRatio`、`competitorCount`。
5. `pageSize` 上限 15；结合 `total` 提示是否翻页。`itemIds` 超过 10 个时分批请求。
