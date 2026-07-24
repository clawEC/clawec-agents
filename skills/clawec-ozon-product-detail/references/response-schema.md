# Ozon 商品详情 — 响应结构

## 顶层 DataResponseProductDetailList

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ProductDetailList | 详情结果 |

## 请求体 ProductDetailQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| itemIds | string | 是 | 商品 ID，英文逗号分隔，最多 10 个 |
| period | string | 否 | `SEVEN_DAY` / `TWENTY_EIGHT_DAY` / `MONTH` / `QUARTER` / `YEAR`，默认 `TWENTY_EIGHT_DAY` |
| updatePeriod | string | 否 | 账期；格式随 `period` 变化 |
| sortField | string | 否 | `SALES` / `GMV` / `PRICE` |
| sortDirection | string | 否 | `ASC` / `DESC` |

## data：ProductDetailList

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ProductDetailSummary[] | 商品详情列表 |

## ProductDetailSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| itemTitle | string | 商品标题（俄文） |
| itemImage | string | 商品主图 URL |
| itemId | integer | 商品 ID |
| category | CategoryPathSummary | 类目信息 |
| brand | string | 品牌 |
| shopId | integer | 店铺 ID |
| shopName | string | 店铺名称 |
| price | string | 价格 |
| cardPrice | string | 卡片价 |
| originalPrice | string | 原价 |
| rating | string | 评分 |
| reviewCount | integer | 评论数 |
| updatePeriod | string | 更新账期 |
| sales | integer | 销量 |
| salesDynamics | string | 销量动态 |
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
| commissionRates | CommissionRates | 佣金比例 |
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

## CommissionRates

| 字段 | 类型 | 说明 |
|------|------|------|
| fboCommissionRate | string | FBO 佣金比例 |
| fbsCommissionRate | string | FBS 佣金比例 |
| rfbsCommissionRate | string | RFBS 佣金比例 |
| fbpCommissionRate | string | FBP 佣金比例 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. `itemTitle` 为俄文，展示时保留原文，并附带 `brand`、`itemId`、`category.categoryNameCn`。
3. 多商品对比时优先对齐：价格、销量、GMV、转化率、广告占比、库存、佣金。
4. `itemIds` 超过 10 个时分批请求，合并结果后再输出。
5. 百分比与金额多为字符串，展示保留原文；比较时再转数值。
