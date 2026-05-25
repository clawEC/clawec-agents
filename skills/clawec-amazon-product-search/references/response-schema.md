# 亚马逊产品搜索 — 响应结构

## 顶层

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| code | integer | HTTP 业务码，成功时通常为 `200` |
| msg | string | 消息，如 `success` |
| data | array | 商品列表 |
| extra | string | JSON 字符串，内含表格展示元数据 |

失败时可能返回 `errorCode`、`errorMsg` 等字段（如 `token错误`）。

## AmazonProduct（data 数组元素）

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 商品名称 |
| cover | string | 封面图 URL |
| price | string | 价格 |
| sales | string | 销量 |
| rating | string | 评论数 |
| star | string | 评分 |
| url | string | 商品详情链接 |

## extra 结构（解析后）

`extra` 为 JSON 字符串，解析后常见结构：

```json
{
  "title": "亚马逊新品排行",
  "table": {
    "columns": [
      { "field": "name", "label": "名称" },
      { "field": "cover", "label": "封面" },
      { "field": "price", "label": "价格" },
      { "field": "sales", "label": "销量" },
      { "field": "rating", "label": "评论数" },
      { "field": "star", "label": "评分" },
      { "field": "url", "label": "详情链接" }
    ],
    "data": [ ... ],
    "cards": []
  }
}
```

当顶层 `data` 为空时，可优先从 `extra.table.data` 读取商品列表。

## 请求体 AmazonProductSearch

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 搜索关键词 |
| region | string | 是 | 站点区域：`NA` `CA` `BR` `UK` `DE` `FR` `JP` `SG` `AU` |
