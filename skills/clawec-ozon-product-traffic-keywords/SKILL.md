---
name: clawec-ozon-product-traffic-keywords
description: 通过 Clawec API 查询 Ozon 商品流量词（搜索指数、转化、供需比、自然/广告流量词等）。在用户需要 Ozon 流量词、关键词挖掘、竞品词分析、广告词调研、SEO/投放选词时使用。
---

# Ozon 商品流量词

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按商品 ID 查询 Ozon 商品流量词及搜索/转化指标（最多 10 个商品）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/ozon/data/product/traffic-keywords`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| itemIds | body | 是 | 商品 ID；最多 10 个，多个用**英文逗号**分隔 |
| pageNo | body | 否 | 分页页码，从 1 开始，最大 10000；默认 `1` |
| pageSize | body | 否 | 分页大小，最大 15；默认 `15` |
| keywordType | body | 否 | 关键词类型（见下表）；默认 `ALL` |
| keyword | body | 否 | 关键词俄文或中文，支持模糊查询 |
| sortField | body | 否 | 排序字段（见下表）；默认 `SEARCH_INDEX` |
| sortDirection | body | 否 | 排序方向：`ASC` / `DESC`；默认 `DESC` |

### keywordType 取值

| 值 | 说明 |
|----|------|
| ALL | 全部 |
| THEME_TAG | 主题标签 |
| NATURAL | 自然流量 |
| AD_CPC | 广告流量 |
| AD_ORDER | 订单广告 |
| AD_SPECIAL | 特殊广告 |

### sortField 常用取值

| 值 | 说明 |
|----|------|
| SEARCH_INDEX | 搜索指数（默认） |
| SEARCH_INDEX_GROWTH_RATE | 搜索指数增长率 |
| CONVERSION_INDEX | 转化指数 |
| CART_CONVERSION_RATE | 加购转化率 |
| EXPOSURE_INDEX | 曝光指数 |
| PRODUCT_COUNT | 商品数 |
| SUPPLY_DEMAND_RATIO | 供需比 |
| ORDERED_PRODUCT_COUNT | 已订购商品 |
| ORDER_CONVERSION_RATE | 订单转化率 |
| ORDERED_AMOUNT | 订购金额 |
| AVERAGE_BROWSE_PRODUCT_COUNT | 平均浏览商品数 |
| CART_AVERAGE_PRICE | 加购均价 |
| COMPETITOR_COUNT | 竞争对手 |
| SEARCH_VOLUME_GROWTH_RATE | 搜索量增长率 |
| NO_ACTION_QUERY_COUNT | 无操作查询 |
| NO_ACTION_QUERY_SHARE | 无操作查询占比 |
| SIMILAR_RESULT_QUERY_COUNT | 类似结果查询 |
| SIMILAR_RESULT_QUERY_RATIO | 类似结果查询占比 |
| NO_RESULT_QUERY_COUNT | 无结果查询 |
| NO_RESULT_QUERY_RATIO | 无结果查询占比 |

超过 10 个商品 ID 时拆成多批请求。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/traffic-keywords" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"itemIds":"123456789","keywordType":"ALL","pageNo":1,"pageSize":15,"sortField":"SEARCH_INDEX","sortDirection":"DESC"}'
```

筛选自然流量词示例：

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/traffic-keywords" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"itemIds":"123456789,987654321","keywordType":"NATURAL","keyword":"кроссовки","sortField":"CONVERSION_INDEX","sortDirection":"DESC"}'
```

或使用脚本：

```bash
# 商品 ID（必填）
bash scripts/query.sh 123456789

# 批量 ID + 词类型 + 分页 + 排序
bash scripts/query.sh "123456789,987654321" NATURAL 1 15 SEARCH_INDEX DESC

# 模糊关键词（第 7 个参数）
bash scripts/query.sh 123456789 ALL 1 15 SEARCH_INDEX DESC кроссовки
```

## 响应结构

```json
{
  "status": 1,
  "data": {
    "success": true,
    "errorCode": "",
    "errorMessage": "",
    "data": [ ... ],
    "total": 100,
    "pageNo": 1,
    "pageSize": 15
  }
}
```

- 顶层 `status`: `1` = 成功，`0` = 失败
- `data.success` / `errorCode` / `errorMessage`: 业务层成功与错误信息
- `data.data`: 当前页流量词摘要数组
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 流量词核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| keyword / keywordCn | 关键词俄文 / 中文 |
| itemId | 商品 ID |
| keywordType | 关键词类型 |
| categoryId / categoryName | 类目 ID、类目路径 |
| searchIndex / searchIndexGrowthRate | 搜索指数及增长率 |
| conversionIndex / cartConversionRate / orderConversionRate | 转化指数、加购转化、订单转化 |
| exposureIndex / productCount / supplyDemandRatio | 曝光指数、商品数、供需比 |
| competitorCount / orderedAmount / cartAveragePrice | 竞品数、订购金额、加购均价 |
| noActionQueryShare / noResultQueryRatio | 无操作占比、无结果占比 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认商品 ID 列表（最多 10 个；超限则分批）
2. 确认词类型（自然/广告等）、是否模糊筛选 `keyword`、排序字段
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求（`pageSize` 不超过 15）
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
6. 解析 `data.data`，结合 `total` 判断是否需翻页
7. 输出中文流量词解读与选词建议

## 输出建议

默认中文报告，包含：

- 查询条件：商品 ID、词类型、关键词筛选、排序、分页（当前页 / 总条数）
- **流量词表**：中文词、俄文词、类型、搜索指数、指数增速、转化指数、订单转化、供需比、竞品数
- **选词机会**：高搜索指数 + 转化尚可、或高增速蓝海（竞品少/供需比友好）的词
- **投放提示**：区分 `NATURAL` 与 `AD_*` 词，指出更适合 SEO 标题 vs CPC/订单广告的词
- **结论**：推荐优先布局的 3–5 个词及理由；结果偏少时可换类型或翻页

## 示例

**输入**：商品 `123456789`，全部词类型，按搜索指数降序

**输出摘要**：

| 中文词 | 俄文词 | 类型 | 搜索指数 | 增速 | 转化指数 | 订单转化 | 竞品数 |
|--------|--------|------|----------|------|----------|----------|--------|
| … | … | NATURAL | … | … | … | … | … |
| … | … | AD_CPC | … | … | … | … | … |

**观察**：（结合指数、转化与供需给出选词建议）
