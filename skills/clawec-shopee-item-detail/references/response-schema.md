# Shopee 商品详情 — 响应结构

## 顶层 DataResponseItemDetailBatchList

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ItemDetailBatchList | 详情结果 |

## 请求体 ItemDetailBatchQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| itemIds | string | 是 | 商品 ID，英文逗号分隔，最多 10 个 |
| timest | string | 否 | 账期 `yyyy-MM-dd`；不传默认昨天 |

## data：ItemDetailBatchList

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ItemDetailBatchSummary[] | 商品详情列表 |

## ItemDetailBatchSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| site | string | 站点名称 |
| itemName | string | 商品标题 |
| itemId | integer | 商品 ID |
| catId | integer | 类目 ID |
| catName | string | 类目名称 |
| shopName | string | 店铺名称 |
| productTypeName | string | 商品类型名称 |
| shopTypeName | string | 店铺类型名称 |
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
2. 多商品对比时优先对齐：价格、日/周/月销量与 GMV、评分、店铺类型、上架时间。
3. `itemIds` 超过 10 个时分批请求，合并结果后再输出；同批商品须同一 `site`。
4. 与榜单/类目搜索区分：本接口按已知商品 ID 拉详情，必填 `site` + `itemIds`。
