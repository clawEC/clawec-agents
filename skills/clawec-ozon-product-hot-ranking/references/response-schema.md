# Ozon 热销产品列表 — 响应结构

## 顶层 DataResponseProductHotRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ProductHotRankingPage | 分页结果 |

## 请求体 ProductHotRankingQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| level1CategoryId | integer | 是 | 一级类目 ID |
| pageNo | integer | 否 | 页码，1–10000，默认 `1` |
| pageSize | integer | 否 | 页大小，1–15，默认 `15` |
| period | string | 否 | `SEVEN_DAY` / `TWENTY_EIGHT_DAY` / `MONTH` / `QUARTER` / `YEAR`，默认 `SEVEN_DAY` |
| updatePeriod | string | 否 | 账期；格式随 `period` 变化 |
| minSales / maxSales | integer | 否 | 销量区间 |
| minGmv / maxGmv | number | 否 | 销售额区间（卢布） |
| minPrice / maxPrice | number | 否 | 平均价格区间 |
| minCreateDate / maxCreateDate | string | 否 | 商品卡创建日期，`yyyy-MM-dd` |
| deliveryModes | string[] | 否 | `FBS` / `FBO` / `rFBS` / `OZON` |
| crossBorderSalePermission | integer | 否 | `1` 禁止跨境，`2` 允许跨境 |
| productType | integer | 否 | `1` 本土，`2` 跨境，`3` 未知 |
| salesLevel | integer | 否 | `1` 头部，`2` 前1%，`3` 前10%，`4` 前50% |
| sortField | string | 否 | `SALES` / `GMV` / `PRICE`，默认 `SALES` |
| sortDirection | string | 否 | `ASC` / `DESC`，默认 `DESC` |

## data：ProductHotRankingPage

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ShopItemDetailSummary[] | 当前分页数据 |
| total | integer | 总记录数 |
| pageNo | integer | 当前页码 |
| pageSize | integer | 每页条数 |

## ShopItemDetailSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| shopId | integer | 店铺 ID |
| shopName | string | 店铺名称 |
| updatePeriod | string | 更新账期 |
| itemTitle | string | 商品标题（俄文） |
| itemId | integer | 商品 ID |
| category | CategoryPathSummary | 类目信息 |
| brand | string | 品牌 |
| sales | integer | 销量 |
| salesDynamics | string | 销量动态，百分比字符串 |
| gmv | string | 销售额 |
| cartRatio | string | 加购率 |
| exposureCount | integer | 曝光量 |
| browseCount | integer | 浏览次数 |
| clickRatio | string | 点击率 |
| redemptionSales | string | 赎回销量 |
| redemptionRate | string | 赎回率 |
| adSales | string | 广告销量 |
| adRate | string | 广告占比 |
| orderConversionRate | string | 下单转化率 |
| averagePrice | string | 平均价格 |
| grossProfitRate | string | 毛利率 |
| deliveryMode | string | 发货模式 |
| deliveryTime | integer | 配送时间 |
| createDate | string | 商品卡创建日期 |
| searchCartRatio | string | 搜索加购率 |
| usability | string | 可用性 |
| averageSales | string | 平均销量 |
| averageGmv | string | 平均销售额 |
| outOfStockDayRate | string | 缺货天数比率 |
| stock | integer | 期末库存数 |
| volume | string | 体积 |
| length / width / height | string | 长 / 宽 / 高 |
| weight | string | 重量 |

## CategoryPathSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| categoryId | integer | 类目 ID（通常为三级子类目） |
| level1CategoryId | integer | 一级类目 ID |
| level2CategoryId | integer | 二级类目 ID |
| level3CategoryId | integer | 三级类目 ID |
| typeId | integer | 类目类型 ID |
| categoryNameCn | string | 中文类目名称路径 |
| categoryNameRu | string | 俄文类目名称路径 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. `itemTitle` 为俄文，向用户展示时可保留原文，并附带 `brand`、`itemId`、`category.categoryNameCn` 便于识别。
3. 百分比与金额字段多为字符串，展示保留原文；比较时再转数值。
4. 结合 `total` 与 `pageNo`/`pageSize` 提示是否还有下一页；`pageSize` 上限为 15。
5. 选品解读可同时看：`sales`、`salesDynamics`、`gmv`、`orderConversionRate`、`adRate`、`stock`、`outOfStockDayRate`、`deliveryMode`、`createDate`。
