# Shopee 商品热搜词 — 响应结构

## 顶层 DataResponseItemHotWordList

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| data | ItemHotWordList | 热搜词结果 |

## 请求体 ItemHotWordQuery

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| site | string | 是 | `tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| itemIds | string | 是 | 商品 ID，英文逗号分隔，最多 10 个 |
| type | integer | 是 | `1` 引流词 / `2` 同类目热词 |
| timest | string | 否 | 账期 `yyyy-MM-dd`；不传默认昨天 |

## data：ItemHotWordList

| 字段 | 类型 | 说明 |
|------|------|------|
| success | boolean | 是否成功 |
| errorCode | string | 机器可读错误码 |
| errorMessage | string | 可读错误描述 |
| data | ItemHotWordSummary[] | 热搜词列表 |

## ItemHotWordSummary

| 字段 | 类型 | 说明 |
|------|------|------|
| timest | string | 日期 |
| site | string | 站点名称 |
| hotWordName | string | 热搜词 |
| itemCount | integer | 产品数 |
| sales30day | integer | 近 30 天销量 |
| gmv30day | number | 近 30 天销售额 |
| recPrice | number | 推荐出价 |
| searchIndex | integer | 搜索指数 |

## 解析建议

1. 先判断顶层 `status`，再判断 `data.success`；失败时展示 `errorCode` / `errorMessage`。
2. 选词优先看：`searchIndex`、`sales30day`、`gmv30day`、`itemCount`、`recPrice`。
3. `type=1` 侧重该商品引流词；`type=2` 侧重同类目热词，报告中明确标注类型。
4. `itemIds` 超过 10 个时分批请求；同批商品须同一 `site`。
5. 可按 `searchIndex` 或 `sales30day` 降序整理后再输出选词建议。
