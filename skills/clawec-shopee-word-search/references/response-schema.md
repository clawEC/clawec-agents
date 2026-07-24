# Shopee 热搜词列表 — 响应结构

## 顶层 DataResponseWordDataPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | WordDataPage | 分页结果 |

## 请求体 WordDataQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | integer | 否 | 类目 ID |
| categoryLocation | integer | 否 | `1` 本土 / `2` 跨境 / `0` 全部（默认） |
| itemCountMin / itemCountMax | integer | 否 | 产品总数区间 |
| sales30dayMin / sales30dayMax | integer | 否 | 近 30 天销量区间 |
| recPriceMin / recPriceMax | number | 否 | 推荐出价区间 |
| sortType | integer | 否 | `1` 近30天销量（默认）/ `2` 推荐出价 / `3` 搜索指数 / `4` 产品总数 |
| pageNo | integer | 否 | 页码，默认 `1` |
| pageSize | integer | 否 | 每页条数，1–100，默认 `10` |
| timest | string | 否 | 账期 `yyyy-MM-dd`；不传默认昨天 |

## data：WordDataPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | WordDataSummary[] | 当前页热搜词列表 |
| total | integer | 总记录数 |
| pageNo | integer | 页码 |
| pageSize | integer | 每页条数 |

## WordDataSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| site | string | 站点名称 |
| hotWordId | integer | 关键词 ID |
| word | string | 关键词源语 |
| transCn | string | 关键词中文 |
| transEn | string | 关键词英文 |
| catId | integer | 类目 ID |
| catName | string | 所属类目 |
| itemCount | integer | 产品总数 |
| activeItemCount | integer | 有销量产品数 |
| dailyActiveRate | number | 近一日产品动销率（%） |
| sales | integer | 日销量 |
| sales30day | integer | 月销量 |
| sales30dayGrowthRate | number | 月销量增长率（%） |
| gmv | number | 日销售额 |
| gmv30day | number | 月销售额 |
| itemAveragePrice | number | 产品均价 |
| recPrice | number | 推荐出价 |
| searchIndex | integer | 近 30 天搜索指数 |
| likeCount | integer | 累计点赞数 |
| ratingNum | integer | 累计评论数 |
| timest | string | 更新账期 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 展示优先用 `transCn`，必要时附带 `word` / `transEn`。
3. 选词时同时看：`searchIndex`、`sales30day`、`sales30dayGrowthRate`、`itemCount`、`recPrice`、`itemAveragePrice`。
4. `pageSize` 上限 100；结合 `total` 提示是否翻页。
5. 与单品热搜词（`/aigc/ec/shopee/data/item/hotword`）区分：本接口按站点/类目查词库，必填仅 `site`。
