---
name: clawec-ozon-product-detail
description: 通过 Clawec API 批量查询 Ozon 商品详情（最多10个商品ID，含价格、销量、转化、佣金、库存等）。在用户需要 Ozon 商品详情、SKU 深度调研、竞品单品分析、批量查货时使用。
---

# Ozon 商品详情

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按商品 ID 批量查询 Ozon 商品详情与经营指标（最多 10 个）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/ozon/data/product/detail`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| itemIds | body | 是 | 商品 ID；最多 10 个，多个用**英文逗号**分隔 |
| period | body | 否 | 数据周期：`SEVEN_DAY` / `TWENTY_EIGHT_DAY` / `MONTH` / `QUARTER` / `YEAR`；默认 `TWENTY_EIGHT_DAY` |
| updatePeriod | body | 否 | 数据更新账期；不传则取所选周期最近账期。近 7/28 天：`yyyy-MM-dd`；自然月：`yyyy-MM`；季度：`yyyy-Qn`；年度：`yyyy` |
| sortField | body | 否 | 排序字段：`SALES` / `GMV` / `PRICE` |
| sortDirection | body | 否 | 排序方向：`ASC` / `DESC` |

超过 10 个 ID 时拆成多批请求；用户给出商品链接时先提取商品 ID 再查询。

## 调用

**单个商品：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/detail" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"itemIds":"123456789","period":"TWENTY_EIGHT_DAY"}'
```

**批量（逗号分隔，最多 10 个）：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/detail" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"itemIds":"123456789,987654321","period":"TWENTY_EIGHT_DAY","sortField":"GMV","sortDirection":"DESC"}'
```

或使用脚本：

```bash
# 商品 ID（必填）+ 周期（默认 TWENTY_EIGHT_DAY）
bash scripts/query.sh 123456789

# 批量 ID（逗号分隔）
bash scripts/query.sh "123456789,987654321" TWENTY_EIGHT_DAY

# 指定排序与账期
bash scripts/query.sh "123456789,987654321" TWENTY_EIGHT_DAY GMV DESC 2026-05-20
```

## 响应结构

```json
{
  "status": 1,
  "data": {
    "success": true,
    "errorCode": "",
    "errorMessage": "",
    "data": [ ... ]
  }
}
```

- 顶层 `status`: `1` = 成功，`0` = 失败
- `data.success` / `errorCode` / `errorMessage`: 业务层成功与错误信息
- `data.data`: 商品详情数组

### 详情核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| itemId / itemTitle / itemImage | 商品 ID、标题（俄文）、主图 |
| brand / shopId / shopName | 品牌、店铺 |
| category | 类目路径（中俄文） |
| price / cardPrice / originalPrice / averagePrice | 现价、卡片价、原价、均价 |
| rating / reviewCount | 评分、评论数 |
| sales / salesDynamics / gmv | 销量、销量动态、销售额 |
| cartRatio / clickRatio / orderConversionRate | 加购率、点击率、下单转化率 |
| exposureCount / browseCount | 曝光量、浏览次数 |
| adSales / adRate | 广告销量、广告占比 |
| commissionRates | FBO/FBS/RFBS/FBP 佣金 |
| deliveryMode / deliveryTime / createDate | 发货模式、配送时间、上架日期 |
| stock / weight / volume | 库存、重量、体积 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认商品 ID 列表（最多 10 个；超限则分批）
2. 确认数据周期；如指定账期，校验 `updatePeriod` 与 `period` 匹配
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与 `itemIds`
6. 解析 `data.data`，按用户需求整理对比或单品深度解读

## 输出建议

默认中文报告，包含：

- 查询条件：商品 ID、周期、账期
- **基础信息**：标题（俄文）、主图链接、品牌、店铺、类目中文路径、评分/评论
- **价格与销售**：现价/原价/均价、销量、销量动态、GMV
- **转化与流量**：加购率、点击率、下单转化、曝光/浏览、广告占比
- **成本与履约**：佣金比例、发货模式、配送时间、库存、缺货率、重量体积
- **结论**：单品或对比场景下给出 2–3 条可行动观察

## 示例

**输入**：查询商品 `123456789`，近 28 天

**输出摘要**：

| 字段 | 值 |
|------|-----|
| 标题 | … |
| 品牌 | … |
| 价格 | … |
| 销量 | … |
| GMV | … |
| 评分 | … |
| 发货 | … |

**观察**：（结合转化、广告占比、库存与佣金给出结论）
