# 亚马逊品类机会分析 — 响应结构

## 顶层 DataResponseProductCatSearchResp

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ProductCatSearchResp | 分析结果 |
| pointInfo | PointInfo | 积分/扣点 `{ type, point }` |

## 请求体 AiProductSearchParam

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 关键词 |
| target_platform | string | 是 | 本技能**固定 `amazon`** |
| region | string | 是 | Amazon：`US` `UK` `ES` `FR` `DE` `IT` `CA` `JP` |
| table | integer | 否 | `0` 不下发表格，`1` 下发；默认 `0` |

## data：ProductCatSearchResp

| 字段 | 类型 | 说明 |
|------|------|------|
| keywordList | KeywordItem[] | 关键词机会分析列表 |

## KeywordItem

| 字段 | 类型 | 说明 |
|------|------|------|
| keyword | string | 原始关键词 |
| keywordCn | string | 中文名称 |
| platform | string | 平台标识，Amazon 场景为 `amazon` |
| region | string | 地区 |
| oppScore | string | 市场机会综合评分（越高机会越大） |
| oppScoreDesc | string | 机会分解读 |
| searchRank | string | 最新一个月核心指标值（Amazon：搜索排名） |
| searchRankDesc | string | 核心指标说明 |
| rankTrends | TrendPoint[] | 近 12 个月趋势 |
| rankTrendsDesc | string | 趋势图标题 |
| rankTrendsPointName | string | 纵轴标签（如排名） |
| soldCnt30d | string | 近 30 天累计销量 |
| soldCnt30dGrowthRate | string | 销量环比，如 `DOWN -0.9%`、`UP 1.2%` |
| soldAmt30d | string | 近 30 天累计销售额（含货币符号） |
| soldAmt30dGrowthRate | string | 销售额环比 |
| radar | RadarInfo | 关键词雷达分 |

## TrendPoint

| 字段 | 类型 | 说明 |
|------|------|------|
| x | string | 月份 |
| y | number | 指标数值 |

## RadarInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| radarDescription | string | 雷达图说明 |
| propertyList | RadarProperty[] | 各维度得分 |

## RadarProperty

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 维度名（如市场需求分、评价分、新品分、市场销售分、市场供给分） |
| value | number | 得分 |

## 解析建议

1. 按 `oppScore` 数值降序排列 `keywordList`（需将字符串转为数字比较）。
2. `searchRank` 在 Amazon 上通常数值越小排名越靠前，解读趋势时注意 `rankTrends` 的 `y` 变化方向。
3. 环比字段含 `UP`/`DOWN` 前缀时保留原文并翻译为中文涨跌说明。
4. `table=1` 时若响应含额外表格结构，与 `keywordList` 一并展示，以实际返回为准。
