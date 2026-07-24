# Shopee 店铺榜单 — 响应结构

## 顶层 DataResponseShopRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ShopRankingPage | 分页结果 |

## 请求体 ShopRankingQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | integer | 是 | 类目 ID |
| sortField | integer | 是 | `1` 热销榜 / `2` 飙升榜 |
| period | integer | 是 | `1` 天 / `2` 周 / `3` 月 |
| date | string | 否 | 账期 `yyyy-MM-dd`；不传默认昨天 |
| shopType | integer | 否 | 产品类型：`1` 优选 / `2` 商城 / `3` 其他 / `0` 全部（默认） |
| borderType | integer | 否 | 店铺类型：`1` 本土 / `2` 跨境 / `0` 全部（默认） |
| pageNo | integer | 否 | 页码，1–100000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–10，默认 `10` |

## data：ShopRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ShopRankingSummary[] | 当前页榜单列表 |
| total | integer | 总记录数 |
| pageNo | integer | 页码 |
| pageSize | integer | 每页条数 |

## ShopRankingSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| site | string | 站点名称 |
| shopId | integer | 店铺 ID |
| shopName | string | 店铺名称 |
| shopImg | string | 店铺图片 |
| shopPath | string | 店铺链接 |
| catId | integer | 类目 ID |
| catName | string | 类目名称 |
| productTypeName | string | 产品类型名称 |
| shopTypeName | string | 店铺类型名称 |
| sales | integer | 日销量 |
| sales7day | integer | 周销量 |
| sales30day | integer | 月销量 |
| gmv | number | 日销售额 |
| gmv7day | number | 周销售额 |
| gmv30day | number | 月销售额 |
| itemCount | integer | 商品数 |
| followerCount | integer | 粉丝数 |
| ratingStar | number | 店铺评分 |
| timest | string | 更新账期 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 按 `period` 选择对应销量/GMV 列：天→`sales`/`gmv`，周→`sales7day`/`gmv7day`，月→`sales30day`/`gmv30day`。
3. 展示时附带 `shopPath`、`shopTypeName`、`productTypeName`，便于对标竞店。
4. `pageSize` 上限 10；结合 `total` 提示是否翻页。
5. 与商品榜单（`/aigc/ec/shopee/data/item/ranking`）区分：本接口返回店铺维度榜单。
