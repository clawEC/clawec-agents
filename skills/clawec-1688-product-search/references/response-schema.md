# 1688 产品搜索 — 响应结构

## 顶层

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | array | 商品列表 |

## _1688Product

| 字段 | 类型 | 说明 |
|------|------|------|
| price | string | 价格 |
| name | string | 名称 |
| sale | string | 销量 |
| cover | string | 封面 |
| url | string | 商品链接 |
| id | string | 产品 ID |
| aiSuggest | string | AI 建议 |
| features | Feature[] | 特点 |
| sellerInfo | Seller | 卖家信息 |
| purchaseCondition | Feature[] | 购买条件 |
| _1688Id | string | 1688 ID |

## Feature

| 字段 | 类型 | 说明 |
|------|------|------|
| label | string | 名称 |
| value | string | 值 |

## Seller

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 卖家名称 |
| url | string | 卖家店铺链接 |
