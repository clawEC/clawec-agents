# Shopee 店铺趋势 — 响应结构

## 顶层 DataResponseShopTrendDetailPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ShopTrendDetailPage | 分页结果 |

## 请求体 ShopTrendDetailQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| shopId | integer | 是 | 店铺 ID |
| granularity | integer | 是 | `1` 自然月 / `2` 自然季度 / `3` 年 |
| startDate | string | 是 | 开始日期 `yyyy-MM-dd` |
| endDate | string | 是 | 结束日期 `yyyy-MM-dd` |
| catId | integer | 否 | 类目 ID；不传查店铺整体趋势 |
| pageNo | integer | 否 | 页码，默认 `1` |
| pageSize | integer | 否 | 页大小，1–10，默认 `10` |

## data：ShopTrendDetailPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ShopTrendDetailSummary[] | 当前页趋势列表 |
| total | integer | 总记录数 |
| pageNo | integer | 页码 |
| pageSize | integer | 每页条数 |

## ShopTrendDetailSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| date | string | 账期：月 `yyyy-MM`、季度 `yyyy-Nq`、年 `yyyy` |
| site | string | 站点编码 |
| shopId | integer | 店铺 ID |
| shopName | string | 店铺名称 |
| shopAddress | string | 店铺地址 |
| productTypeName | string | 产品类型 |
| shopTypeName | string | 店铺类型 |
| itemCount | integer | 产品数量 |
| activeItemCount | integer | 有销量产品数 |
| activeRate | number | 动销率（%） |
| sales | integer | 销量 |
| gmv | number | 销售额 |
| mainCatName | string | 店铺主营类目名称 |
| ratingStar | number | 店铺评分 |
| followerCount | integer | 累计粉丝数 |
| followingCount | integer | 关注中 |
| ctime | string | 开店时间 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 按 `date` 升序排列后解读趋势；时间跨度较长时结合 `total` 翻页取全量。
3. 重点观察：`sales`、`gmv`、`activeRate`、`itemCount`、`followerCount` 的同步或背离。
4. 传 `catId` 时报告中注明为「类目内店铺趋势」，未传则为「店铺整体趋势」。
5. 与店铺详情（快照）区分：本接口是时间序列趋势；详情接口是单日账期批量查店。
