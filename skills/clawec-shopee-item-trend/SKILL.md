---
name: clawec-shopee-item-trend
description: 通过 Clawec API 查询 Shopee 商品趋势（月/季/年颗粒度，销量销售额、价格、评分等时间序列）。在用户需要虾皮商品趋势、单品走势、竞品销量变化分析时使用。
---

# Shopee 商品趋势

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于查询单个 Shopee 商品在指定时间范围内的经营趋势。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/shopee/data/item/trend`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点：`tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| itemId | body | 是 | 商品 ID |
| granularity | body | 是 | 统计颗粒度：`1`=自然月 `2`=自然季度 `3`=年 |
| startDate | body | 是 | 数据范围开始，`yyyy-MM-dd` |
| endDate | body | 是 | 数据范围结束，`yyyy-MM-dd` |
| pageNo | body | 否 | 分页页码，从 1 开始；默认 `1` |
| pageSize | body | 否 | 分页大小，最大 10；默认 `10` |

### site 站点对照

| 代码 | 站点 |
|------|------|
| tw | 台湾 |
| my | 马来西亚 |
| id | 印度尼西亚 |
| th | 泰国 |
| ph | 菲律宾 |
| sg | 新加坡 |
| vn | 越南 |
| br | 巴西 |

用户给出商品链接时先提取商品 ID 与站点再查询。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","itemId":123456789,"granularity":1,"startDate":"2025-05-27","endDate":"2026-05-27","pageNo":1,"pageSize":10}'
```

或使用脚本：

```bash
# 站点 + 商品 ID + 颗粒度(1月/2季/3年) + 开始日 + 结束日（均必填）
bash scripts/query.sh tw 123456789 1 2025-05-27 2026-05-27

# 指定分页
bash scripts/query.sh tw 123456789 1 2025-05-27 2026-05-27 1 10
```

脚本参数顺序：`site itemId granularity startDate endDate [pageNo] [pageSize]`

## 响应结构

```json
{
  "status": 1,
  "data": {
    "success": true,
    "errorCode": "",
    "errorMessage": "",
    "data": [ ... ],
    "total": 12,
    "pageNo": 1,
    "pageSize": 10
  }
}
```

- 顶层 `status`: `1` = 成功，`0` = 失败
- `data.success` / `errorCode` / `errorMessage`: 业务层成功与错误信息
- `data.data`: 当前页趋势时间序列
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 趋势核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| date / site / itemId / itemName | 账期、站点、商品 |
| catId / catName / shopName | 类目、店铺 |
| productTypeName / shopTypeName / ctime | 商品类型、店铺类型、上架时间 |
| price / sales / gmv / totalSales | 价格、销量、销售额、累计销量 |
| ratingStar / likeCount / commentCount | 评分、点赞、评论 |

账期格式随颗粒度变化：月 `yyyy-MM`、季度 `yyyy-Nq`、年 `yyyy`。

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认站点、商品 ID、颗粒度、起止日期
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求（`pageSize` 不超过 10）
4. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
5. 按 `date` 排序解读升降；结合 `total` 判断是否需翻页
6. 输出中文商品趋势报告

## 输出建议

默认中文报告，包含：

- 查询条件：站点、商品 ID、颗粒度、时间范围、分页
- **基础信息**：标题、类目、店铺、商品/店铺类型、上架时间
- **趋势表**：账期、价格、销量、GMV、累计销量、评分、点赞/评论
- **走势解读**：销量/GMV 升降、价格变动、评分与互动变化
- **结论**：单品是否处于上升期/回落期，给出 2–3 条竞品观察

## 示例

**输入**：台湾站商品 `123456789`，自然月，2025-05-27 ~ 2026-05-27

**输出摘要**：

| 账期 | 价格 | 销量 | GMV | 累计销量 | 评分 |
|------|------|------|-----|----------|------|
| 2025-06 | … | … | … | … | … |
| 2025-07 | … | … | … | … | … |

**观察**：（结合销量与价格变化给出趋势结论）
