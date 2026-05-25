# 亚马逊新品跟踪 — 响应结构

## 顶层

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | object | 新品相关数据，字段由 API 动态返回 |

失败时可能附带错误消息字段（如 `msg`、`errorMsg` 等），以实际响应为准。

## 请求体 AmazonNewRelease

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| cat | string | 否 | 类目代码；未指定类目时传 `""` |

### cat 合法取值

空字符串或以下之一：

`lawn-garden` `fashion` `amazon-devices` `music` `musical-instruments` `sports-collectibles` `office-products` `books` `appliances` `baby-products` `pet-supplies` `home-garden`

传入其他值可能导致失败，调用前应校验。

## data 对象

OpenAPI 未固定 `data` 内字段名。`data` 可能为：

- 商品/新品数组（直接或嵌套在 `list`、`items`、`products` 等键下）
- 含表格元数据的对象（类似产品搜索接口的 `extra` / `table` 结构）

### 单条新品常见字段（示例）

| 字段（示例） | 说明 |
|--------------|------|
| name / title | 商品名称 |
| cover / image | 封面图 |
| price | 价格 |
| rank | 新品榜排名 |
| star / rating | 评分 / 评论数 |
| sales | 销量 |
| url | 商品链接 |
| asin | ASIN |

解析时先判断 `data` 是数组还是对象；若为对象，查找数组型子字段再展开。遍历全部键值，勿假设固定 schema。
