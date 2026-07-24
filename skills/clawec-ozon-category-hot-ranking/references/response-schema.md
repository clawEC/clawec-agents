# Ozon 类目热销榜单 — 响应结构

## 顶层 DataResponseCategoryHotRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | CategoryHotRankingPage | 分页结果 |

## 请求体 CategoryHotRankingQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| categoryId | integer | 是 | 一级类目 ID |
| pageNo | integer | 否 | 页码，1–10000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–15，默认 `15` |
| language | string | 否 | `CH` / `RU` / `EN`，默认 `CH` |
| period | string | 否 | `SEVEN_DAY` / `TWENTY_EIGHT_DAY` / `MONTH` / `QUARTER` / `YEAR`，默认 `SEVEN_DAY` |
| updatePeriod | string | 否 | 账期；格式随 `period` 变化 |
| sortField | string | 否 | `SALES` / `GMV` / `PRICE`，默认 `GMV` |
| sortDirection | string | 否 | `ASC` / `DESC`，默认 `DESC` |

## data：CategoryHotRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | CategoryHotRankingSummary[] | 当前分页数据 |
| total | integer | 总记录数 |
| pageNo | integer | 当前页码 |
| pageSize | integer | 每页条数 |

## CategoryHotRankingSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| category | CategoryPathSummary | 类目信息 |
| crossBorderSalePermission | string | 跨境禁售权限：跨境允许销售、跨境禁止销售 |
| updatePeriod | string | 更新账期 |
| totalProductCount | integer | 当前账期商品总数 |
| salableProductCount | integer | 有销量商品数 |
| salesRate | string | 动销率，百分比字符串，如 `50.00%` |
| orderedProductCount | integer | 有订购商品数 |
| gmv | string | 销售额，保留两位小数 |
| gmvGrowthRate | string | 销售额增长率，百分比字符串 |
| topBrandGmv | string | 头部品牌销售额 |
| brandGmvRate | string | 品牌销售额占比 |
| topGmv | string | 头部销售额 |
| topGmvRate | string | 头部销售额占比 |
| topAveragePrice | string | 头部产品平均价格 |
| commissionRates | CommissionRates | 佣金比例 |
| crossBorderProductShare | string | 跨境商品占比 |
| averageSales | integer | 平均销量 |
| averageGmv | string | 平均销售额 |
| averageCancelRate | string | 平均取消率 |
| averageWeight | string | 平均重量 |
| averageVolume | string | 平均体积 |

## CategoryPathSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| categoryId | integer | 类目 ID（通常为三级子类目） |
| level1CategoryId | integer | 一级类目 ID |
| level2CategoryId | integer | 二级类目 ID |
| level3CategoryId | integer | 三级类目 ID |
| typeId | integer | 类目类型 ID |
| categoryNameCn | string | 中文类目名称路径（一/二/三级） |
| categoryNameRu | string | 俄文类目名称路径（一/二/三级） |

## CommissionRates

| 字段 | 类型 | 说明 |
|------|------|------|
| fboCommissionRate | string | FBO 佣金比例 |
| fbsCommissionRate | string | FBS 佣金比例 |
| rfbsCommissionRate | string | RFBS 佣金比例 |
| fbpCommissionRate | string | FBP 佣金比例 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 展示类目时优先用 `category.categoryNameCn`；需要俄文对照时附带 `categoryNameRu`。
3. 百分比与金额字段多为字符串，展示时保留原文；比较排序时再转数值。
4. 结合 `total` 与 `pageNo`/`pageSize` 提示是否还有下一页；`pageSize` 上限为 15。
5. 选品解读可同时看：`gmv`、`gmvGrowthRate`、`salesRate`、`topGmvRate`、`crossBorderProductShare`、`crossBorderSalePermission`、`commissionRates`。
