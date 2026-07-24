# Shopee 商品榜单 — 响应结构

## 顶层 DataResponseItemRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ItemRankingPage | 分页结果 |

## 请求体 ItemRankingQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | integer | 是 | 类目 ID |
| sortField | integer | 是 | `1` 热销榜 / `2` 飙升榜 |
| period | integer | 是 | `1` 天榜 / `2` 周榜 / `3` 月榜 |
| date | string | 否 | 榜单日期 `yyyy-MM-dd`；不传默认昨天 |
| borderType | integer | 否 | `0` 总榜（默认）/ `1` 跨境 / `2` 本土 |
| productType | integer | 否 | `1` 优选 / `2` 商城 / `3` 其他 / `0` 全部（默认） |
| pageNo | integer | 否 | 页码，1–100000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–10，默认 `10` |

## data：ItemRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ItemRankingSummary[] | 当前页榜单列表 |
| total | integer | 总记录数 |
| pageNo | integer | 页码 |
| pageSize | integer | 每页条数 |

## ItemRankingSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| site | string | 站点名称 |
| itemName | string | 商品标题 |
| itemImg | string | 商品图片 |
| itemLocalPath | string | 本土商品链接 |
| itemBorderPath | string | 跨境商品链接 |
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
2. 按 `period` 选择对应销量/GMV 列展示：天→`sales`/`gmv`，周→`sales7day`/`gmv7day`，月→`sales30day`/`gmv30day`。
3. 链接优先：`borderType=1` 用 `itemBorderPath`，`borderType=2` 用 `itemLocalPath`，总榜两者均可展示。
4. `pageSize` 上限 10；结合 `total` 提示是否翻页。
5. 与类目商品搜索（`/aigc/ec/shopee/data/item/search`）区分：本接口是榜单（热销/飙升），必填 `sortField` + `period`。
