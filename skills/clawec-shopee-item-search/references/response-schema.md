# Shopee 类目商品搜索 — 响应结构

## 顶层 DataResponseItemDataPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ItemDataPage | 分页结果 |

## 请求体 ItemDataQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | integer | 是 | 类目 ID |
| productType | integer | 否 | `1` 优选 / `2` 商城 / `3` 其他 / `0` 全部（默认） |
| isBorder | integer | 否 | `1` 本土 / `2` 跨境 / `0` 全部（默认） |
| ctimeStart / ctimeEnd | string | 否 | 上架时间，`yyyy-MM-dd` |
| sales30dayMin / sales30dayMax | integer | 否 | 近 30 天销量区间 |
| gmv30dayMin / gmv30dayMax | number | 否 | 近 30 天销售额区间 |
| priceMin / priceMax | number | 否 | 价格区间 |
| sortType | integer | 否 | `1` 近30天销量（默认）/ `2` 近30天销售额 / `3` 价格 |
| sortOrder | string | 否 | `asc` / `desc`（默认 `desc`） |
| timest | string | 否 | 账期 `yyyy-MM-dd`；不传默认昨天 |
| pageNo | integer | 否 | 页码，1–100000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–10，默认 `10` |

## data：ItemDataPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ItemDataSummary[] | 当前页商品列表 |
| total | integer | 总记录数 |
| pageNo | integer | 页码 |
| pageSize | integer | 每页条数 |

## ItemDataSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| site | string | 站点名称 |
| itemName | string | 商品标题 |
| itemId | integer | 商品 ID |
| catId | integer | 类目 ID |
| catName | string | 类目名称 |
| shopName | string | 店铺名称 |
| productType | integer | `1` 虾皮优选 / `2` 虾皮商城 / `3` 其他 |
| shopType | integer | `1` 本土店铺 / `2` 跨境店铺 |
| ctime | string | 上架时间 |
| price | number | 价格 |
| sales | integer | 日销量 |
| sales7day | integer | 周销量 |
| sales30day | integer | 月销量 |
| gmv | number | 日销售额 |
| gmv7day | number | 周销售额 |
| gmv30day | number | 月销售额 |
| totalSales | integer | 累计销量 |
| ratingStar | number | 产品评分 |
| likeCount | integer | 累计点赞数 |
| commentCount | integer | 累计评论数 |
| timest | string | 更新账期 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. `shopType`：`1` 本土、`2` 跨境；`productType`：`1` 优选、`2` 商城、`3` 其他，展示时转中文标签。
3. 选品优先看：`sales30day`、`gmv30day`、`price`、`ratingStar`、`ctime`、`shopType`。
4. `pageSize` 上限 10；结合 `total` 提示是否翻页。
5. 与关键词搜品（`/aigc/ec/shopee_search`）区分：本接口无 `keyword`，必须传 `site` + `categoryId`。
