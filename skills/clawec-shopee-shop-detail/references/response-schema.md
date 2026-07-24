# Shopee 店铺详情 — 响应结构

## 顶层 DataResponseShopDetailBatchList

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ShopDetailBatchList | 详情结果 |

## 请求体 ShopDetailBatchQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| shopIds | string | 是 | 店铺 ID，英文逗号分隔，最多 10 个 |
| timest | string | 否 | 账期 `yyyy-MM-dd`；不传默认昨天 |

## data：ShopDetailBatchList

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ShopDetailSummary[] | 店铺详情列表 |

## ShopDetailSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| date | string | 日期 |
| shopId | integer | 店铺 ID |
| shopName | string | 店铺名称 |
| shopAddress | string | 店铺地址 |
| shopType | integer | `1` 本土店铺 / `2` 跨境店铺 |
| location | integer | `1` 虾皮优选 / `2` 虾皮商城 / `3` 其他 |
| itemCount | integer | 产品数量 |
| activeItemCount | integer | 有销量产品数 |
| salesRate | number | 动销率（%） |
| sales | integer | 日销量 |
| sales7day | integer | 周销量 |
| sales30day | integer | 月销量 |
| gmv | number | 日销售额 |
| gmv7day | number | 周销售额 |
| gmv30day | number | 月销售额 |
| mainCatName | string | 店铺主营类目名称 |
| ratingStar | number | 店铺评分 |
| followerCount | integer | 累计粉丝数 |
| followingCount | integer | 关注中 |
| ctime | string | 开店时间 |
| site | string | 站点 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. `shopType`、`location` 为数值时转中文标签再展示。
3. 多店对比优先对齐：月销量/GMV、动销率、商品数、粉丝、评分、开店时间、本土/跨境。
4. `shopIds` 超过 10 个时分批请求；同批店铺须同一 `site`。
5. 与店铺榜单区分：本接口按已知店铺 ID 拉详情，必填 `site` + `shopIds`。
