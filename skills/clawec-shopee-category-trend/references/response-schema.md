# Shopee 类目趋势概览 — 响应结构

## 顶层 DataResponseCatTrendOverviewList

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | CatTrendOverviewList | 趋势结果 |

## 请求体 CatTrendOverviewQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sites | string[] | 是 | 站点列表，如 `["tw","my"]` |
| catId | integer | 是 | 类目 ID |
| granularity | integer | 是 | `1` 自然月 / `2` 自然季度 / `3` 年 |
| startDate | string | 是 | 开始日期 `yyyy-MM-dd` |
| endDate | string | 是 | 结束日期 `yyyy-MM-dd` |
| productType | integer | 否 | `0` 全部（默认）/ `1` 优选 / `2` 商城 / `3` 其他 |
| location | integer | 否 | `0` 全部（默认）/ `1` 本地 / `2` 跨境 |

## data：CatTrendOverviewList

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | CatTrendOverviewSummary[] | 趋势概览列表 |

## CatTrendOverviewSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| date | string | 账期（如 `2026-01`） |
| site | string | 站点编码 |
| catId | integer | 类目 ID |
| catName | string | 类目名称 |
| level | integer | 类目级别：1、2、3 |
| itemCount | integer | 产品数 |
| activeItemCount | integer | 有销量产品数 |
| sales | integer | 销量 |
| gmv | number | 销售额 |
| brandCount | integer | 品牌数 |
| shopCount | integer | 店铺数 |
| activeShopCount | integer | 有销量店铺数 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 先按 `site` 分组，再按 `date` 升序排列，便于读趋势。
3. 多站点时做横向对比：同期销量/GMV、产品数、店铺数差异。
4. 动销可粗算：`activeItemCount / itemCount`；有销量店铺占比：`activeShopCount / shopCount`（注意除零）。
5. `sites` 必须为 JSON 数组；脚本侧用逗号分隔站点名再转为数组。
