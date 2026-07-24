# Reddit 搜索 — 响应结构

## 顶层 DataResponseObject

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| code | integer | 业务状态码（以实际返回为准） |
| msg | string | 状态说明 |
| data | object | 搜索结果，内部结构以实际返回为准 |
| extra | string | 附加信息 |
| pointInfo | PointInfo | 积分/扣点信息 |

失败时可能返回错误信息字段（如 `token错误`），以实际响应为准。

## PointInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| type | number | 类型 |
| point | integer | 积分/扣点数 |

## 请求体 RedditSearchParam

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 搜索关键词 |

## data（常见字段，非穷举）

OpenAPI 中 `data` 未展开子字段；调用后按实际 JSON 解析。常见帖子相关字段示例：

| 字段 | 类型 | 说明 |
|------|------|------|
| title | string | 帖子标题 |
| subreddit | string | 子版块名称 |
| score | number | 投票得分 |
| num_comments | integer | 评论数 |
| url | string | 外链或讨论链接 |
| permalink | string | Reddit 永久链接 |
| created_utc | number | Unix 时间戳 |
| author | string | 作者用户名 |
| selftext | string | 文本帖正文 |

若 `data` 为数组，则每项为一条帖子/结果记录；若为对象，可能包含列表字段（如 `posts`、`items`），以实际返回为准。
