# Ozon 商品搜索 — 响应结构

## 顶层

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | array | 商品列表 |
| pointInfo | PointInfo | 积分/扣点信息 |

失败时可能返回 `errorCode`、`errorMsg` 等字段（如 `token错误`）。

## OzonProduct（data 数组元素）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 商品 ID |
| name | string | 名称 |
| price | string | 价格 |
| cover | string | 封面图 URL |
| rating | string | 排名 |
| sales | string | 销量 |
| star | string | 评分 |
| images | string[] | 图片 URL 列表 |
| url | string | 商品链接 |
| market | string | 市场/站点 |

## PointInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| type | integer | 类型 |
| point | integer | 积分/扣点数 |

## 请求体 OzonSearchParam

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 搜索关键词 |
