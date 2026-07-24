# Shopee 商品趋势 — 响应结构

## 顶层 DataResponseItemTrendDetailPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ItemTrendDetailPage | 分页结果 |

## 请求体 ItemTrendDetailQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| itemId | integer | 是 | 商品 ID |
| granularity | integer | 是 | `1` 自然月 / `2` 自然季度 / `3` 年 |
| startDate | string | 是 | 开始日期 `yyyy-MM-dd` |
| endDate | string | 是 | 结束日期 `yyyy-MM-dd` |
| pageNo | integer | 否 | 页码，默认 `1` |
| pageSize | integer | 否 | 页大小，1–10，默认 `10` |

## data：ItemTrendDetailPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ItemTrendDetailSummary[] | 当前页趋势列表 |
| total | integer | 总记录数 |
| pageNo | integer | 页码 |
| pageSize | integer | 每页条数 |

## ItemTrendDetailSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| site | string | 站点编码 |
| itemName | string | 商品标题 |
| itemId | integer | 商品 ID |
| catId | integer | 类目 ID |
| catName | string | 类目名称 |
| shopName | string | 店铺名称 |
| productTypeName | string | 商品类型 |
| shopTypeName | string | 店铺类型 |
| ctime | string | 上架时间 |
| price | number | 价格 |
| sales | integer | 销量 |
| gmv | number | 销售额 |
| totalSales | integer | 累计销量 |
| ratingStar | number | 产品评分 |
| likeCount | integer | 累计点赞数 |
| commentCount | integer | 累计评论数 |
| date | string | 账期：月 `yyyy-MM`、季度 `yyyy-Nq`、年 `yyyy` |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 按 `date` 升序排列后解读趋势；时间跨度较长时结合 `total` 翻页取全量。
3. 重点观察：`sales`、`gmv`、`price`、`totalSales`、`ratingStar` 的同步或背离。
4. 与商品详情（快照）区分：本接口是时间序列趋势；详情接口是单日账期批量查品。
5. 与店铺趋势对称：商品趋势按 `itemId`，店铺趋势按 `shopId`。
