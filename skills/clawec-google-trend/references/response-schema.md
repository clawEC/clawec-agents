# 谷歌趋势 — 响应结构

## 顶层 DataResponseObject

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| code | integer | 业务状态码（以实际返回为准） |
| msg | string | 状态说明 |
| data | object | 趋势数据，内部结构以实际返回为准 |
| extra | string | 附加信息 |
| pointInfo | PointInfo | 积分/扣点信息 |

失败时可能返回错误信息字段（如 `token错误`），以实际响应为准。

## PointInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| type | number | 类型 |
| point | integer | 积分/扣点数 |

## 请求体 GoogleTrendParam

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 关键词；多个词用英文逗号分隔 |
| region | string | 否 | ISO 3166-1 alpha-2 两位大写国家代码，如 US、UK、JP |

### region 示例

US、UK、JP、DE、FR、IT、ES、CA 等 Google Trends 支持的国家/地区代码。

## data（常见字段，非穷举）

OpenAPI 中 `data` 未展开子字段；调用后按实际 JSON 解析。常见趋势相关字段示例：

| 字段 | 类型 | 说明 |
|------|------|------|
| keyword / keywords | string / array | 查询词 |
| region | string | 地区代码 |
| timeline | array | 时间序列，元素可能含 `date`、`value` |
| interest_over_time | array | 兴趣随时间变化 |
| related_queries | object | 相关查询（rising、top 等） |
| related_topics | object | 相关主题 |
| averages | array | 多词对比时的平均相对指数 |

若返回嵌套列表或图表用原始数据，解析时保留时间粒度与数值单位说明。
