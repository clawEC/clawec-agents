# Shopee 热搜词榜单 — 响应结构

## 顶层 DataResponseWordRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | WordRankingPage | 分页结果 |

## 请求体 WordRankingQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | integer | 是 | 类目 ID |
| sortField | integer | 是 | `1` 热销榜 / `2` 飙升榜 |
| period | integer | 是 | `1` 天榜 / `2` 周榜 / `3` 月榜 |
| date | string | 否 | 榜单日期 `yyyy-MM-dd`；不传默认昨天 |
| borderType | integer | 否 | `0` 总榜（默认）/ `1` 跨境 / `2` 本土 |
| pageNo | integer | 否 | 页码，1–100000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–10，默认 `10` |

## data：WordRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | WordDataSummary[] | 当前页热搜词榜单 |
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
3. 按 `period` 侧重对应销量/GMV：天→`sales`/`gmv`，月→`sales30day`/`gmv30day`；飙升榜额外关注 `sales30dayGrowthRate`。
4. `pageSize` 上限 10；结合 `total` 提示是否翻页。
5. 与热搜词列表（`/aigc/ec/shopee/data/word/search`）区分：本接口是榜单，必填 `sortField` + `period`；列表接口支持更多筛选且 `pageSize` 最大 100。
