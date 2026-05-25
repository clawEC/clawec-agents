# 亚马逊 ASIN 详情查询 — 响应结构

## 顶层

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | object | 商品详情，字段由 API 动态返回 |

失败时可能附带错误消息字段（如 `msg`、`errorMsg` 等），以实际响应为准。

## 请求体 AmazonAsinQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| url | string | 否* | 商品详情页 URL |
| asin | string | 否* | 商品 ASIN |
| region | string | 否* | 站点：`NA` `CA` `BR` `UK` `DE` `FR` `JP` `SG` `AU` |

\* 二选一：仅 `url`，或 `asin` + `region`（无 `url` 时由服务端按 ASIN 与区域拼接链接）。

## data 对象

OpenAPI 未固定 `data` 内字段名；常见可能包含（以实际返回为准）：

| 字段（示例） | 说明 |
|--------------|------|
| name / title | 商品标题 |
| asin | ASIN |
| price | 价格 |
| star / rating | 评分 / 评论数 |
| sales | 销量 |
| cover / images | 主图或图片列表 |
| url | 商品链接 |
| brand | 品牌 |
| category | 类目 |

解析时遍历 `data` 全部键值，勿假设固定 schema；向用户展示时使用中文标签映射未知字段名。
