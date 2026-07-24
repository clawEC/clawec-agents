---
name: clawec-ozon-keyword-hot-ranking
description: 通过 Clawec API 查询 Ozon 热搜词榜单（搜索指数、订购金额、转化、供需比等，支持类目与多维筛选）。在用户需要 Ozon 热搜词、关键词榜单、选词机会、类目搜索趋势调研时使用。
---

# Ozon 热搜词榜单

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于查询 Ozon 热搜词榜单与搜索/转化指标。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/ozon/data/keyword/hot-ranking`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| period | body | 是 | 数据周期：`WEEK` / `MONTH` / `QUARTER` / `YEAR` |
| pageNo | body | 否 | 分页页码，从 1 开始，最大 10000；默认 `1` |
| pageSize | body | 否 | 分页大小，最大 15；默认 `15` |
| level1CategoryId | body | 否 | 一级类目 ID（见下表） |
| keyword | body | 否 | 关键词名称，支持中文、俄文、英文 |
| searchType | body | 否 | `FUZZY` 模糊（默认）/ `EXACT` 精确 |
| minSearchIndex / maxSearchIndex | body | 否 | 搜索指数区间 |
| minSearchVolumeGrowthRate / maxSearchVolumeGrowthRate | body | 否 | 搜索量增长率区间 |
| minOrderConversionRate / maxOrderConversionRate | body | 否 | 订单转化率区间 |
| minOrderedAmount / maxOrderedAmount | body | 否 | 已订购金额区间 |
| minOrderedProductCount / maxOrderedProductCount | body | 否 | 已订购商品数区间 |
| minCartCount / maxCartCount | body | 否 | 加购次数区间 |
| minCartAveragePrice / maxCartAveragePrice | body | 否 | 购物车均价区间 |
| minSupplyDemandRatio / maxSupplyDemandRatio | body | 否 | 供需比区间 |
| updatePeriod | body | 否 | 更新账期；不传取最近账期。周：`yyyy-MM-dd`；自然月：`yyyy-MM`；季度：`yyyy-Qn`；年度：`yyyy` |
| sortField | body | 否 | `SEARCH_INDEX`（默认）/ `ORDERED_AMOUNT` / `ORDERED_PRODUCT_COUNT` |
| sortDirection | body | 否 | `ASC` / `DESC`；默认 `DESC` |

### level1CategoryId 一级类目对照

| ID | 类目 |
|----|------|
| 17027494 | 住宅和花园 |
| 17027491 | 运动与休闲 |
| 17027489 | 美容和卫生 |
| 15621032 | 鞋类 |
| 15621031 | 服装 |
| 17027915 | 家具 |
| 17027486 | 家用电器 |
| 17027482 | 建筑和装修 |
| 15621042 | 电子产品 |
| 17027488 | 儿童用品 |
| 17027493 | 小百货和配饰 |
| 17027492 | 文具 |
| 92130764 | 乐器 |
| 52265716 | 药店 |
| 17027485 | 爱好和创作 |
| 17027487 | 宠物用品 |
| 17027496 | 食品 |
| 17027495 | 汽车用品 |
| 88976462 | 农场 |
| 200001482 | 书籍 |
| 17027490 | 古董和收藏品 |
| 76902590 | 珠宝 |
| 17027484 | 成人用品 |
| 75021418 | 日化 |
| 99999999 | 电影、音乐、视频游戏、软件 |
| 200001506 | 吸烟产品和配件 |
| 200001160 | 慈善 |
| 92120918 | 汽车和摩托车 |
| 200001388 | Ozon Fresh食品 |
| 999999999 | 其他 |

用户用中文类目名表述时，先映射到上表 `level1CategoryId` 再请求。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/keyword/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"period":"WEEK","pageNo":1,"pageSize":15,"sortField":"SEARCH_INDEX","sortDirection":"DESC"}'
```

按类目 + 关键词筛选示例：

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/keyword/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"period":"MONTH","level1CategoryId":17027489,"keyword":"кроссовки","searchType":"FUZZY","minSearchIndex":1000,"sortField":"ORDERED_AMOUNT","sortDirection":"DESC"}'
```

或使用脚本：

```bash
# 周期（必填）
bash scripts/query.sh WEEK

# 周期 + 分页 + 排序
bash scripts/query.sh MONTH 1 15 SEARCH_INDEX DESC

# 账期（第 6 个参数）+ 额外筛选 JSON（第 7 个参数）
bash scripts/query.sh WEEK 1 15 SEARCH_INDEX DESC 2026-04-20 '{"level1CategoryId":17027489,"keyword":"кроссовки","minSearchIndex":1000}'
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
- `data.data`: 当前页热搜词摘要数组
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 热搜词核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| keywordId / keyword / keywordCn | 词 ID、俄文、中文 |
| categoryId / categoryName | 类目 ID、类目路径 |
| searchIndex / searchIndexGrowthRate | 搜索指数及增长率 |
| conversionIndex / cartConversionRate / orderConversionRate | 转化指数、加购转化、订单转化 |
| orderedAmount / orderedProductCount | 已订购金额、已订购商品数 |
| productCount / supplyDemandRatio / competitorCount | 商品数、供需比、竞品数 |
| cartAveragePrice / exposureIndex | 购物车均价、曝光指数 |
| updatePeriod | 更新账期 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认数据周期 `period`（必填）；可选一级类目、关键词与搜索类型
2. 按用户需求补充筛选：搜索指数、转化率、订购金额、供需比等区间
3. 如指定账期，校验 `updatePeriod` 格式与 `period` 匹配
4. 检查 `CLAWEC_API_KEY` 是否可用
5. 执行 API 请求（`pageSize` 不超过 15）
6. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
7. 解析 `data.data`，结合 `total` 判断是否需翻页
8. 输出中文热搜词榜解读与选词建议

## 输出建议

默认中文报告，包含：

- 查询条件：周期、账期、类目、关键词筛选、排序、分页（当前页 / 总条数）
- **热搜词表**：中文词、俄文词、搜索指数、指数增速、订购金额、订购商品数、订单转化、供需比、竞品数、类目
- **机会观察**：高指数高转化、或高增速且竞品/供需尚可的词
- **结论**：推荐优先布局的 3–5 个词及理由；结果偏少时可放宽筛选或换周期/翻页

## 示例

**输入**：美容和卫生（`17027489`），周榜，按搜索指数降序

**输出摘要**：

| 中文词 | 俄文词 | 搜索指数 | 增速 | 订购金额 | 订单转化 | 供需比 | 竞品数 |
|--------|--------|----------|------|----------|----------|--------|--------|
| … | … | … | … | … | … | … | … |

**观察**：（结合指数、转化与供需给出选词建议）
