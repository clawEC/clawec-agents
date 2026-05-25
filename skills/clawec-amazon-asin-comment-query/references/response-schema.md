# 亚马逊 ASIN 评论查询 — 响应结构

## 顶层

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | object | 评论相关数据，字段由 API 动态返回 |

失败时可能附带错误消息字段（如 `msg`、`errorMsg` 等），以实际响应为准。

## 请求体 AmazonAsinQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| url | string | 否* | 商品详情页 URL |
| asin | string | 否* | 商品 ASIN |
| region | string | 否* | 站点：`NA` `CA` `BR` `UK` `DE` `FR` `JP` `SG` `AU` |

\* 二选一：仅 `url`，或 `asin` + `region`（无 `url` 时由服务端按 ASIN 与区域拼接链接）。

## data 对象

OpenAPI 未固定 `data` 内字段名。`data` 可能为：

- 评论数组（直接或可嵌套在 `list`、`comments`、`reviews` 等键下）
- 含统计与列表的组合对象

### 单条评论常见字段（示例）

| 字段（示例） | 说明 |
|--------------|------|
| star / rating | 星级 |
| title | 评论标题 |
| content / body / text | 评论正文 |
| date / time | 评论日期 |
| author / name | 买家昵称 |
| verified | 是否 Verified Purchase |
| helpful | 有帮助投票数 |
| images | 评论附图 |

### 统计类字段（示例）

| 字段（示例） | 说明 |
|--------------|------|
| total | 评论总数 |
| starDistribution | 各星级数量或占比 |

解析时先判断 `data` 是数组还是对象；若为对象，查找数组型子字段再展开。遍历全部键值，勿假设固定 schema。
