---
name: clawec-ozon-product-hot-ranking
description: 通过 Clawec API 查询 Ozon 热销产品列表（销量/GMV/价格筛选排序、发货模式、跨境权限、销售水平等）。在用户需要 Ozon 热销商品、爆品榜、单品选品、竞品销量调研、俄罗斯跨境产品榜单时使用。
---

# Ozon 热销产品列表

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按一级类目查询 Ozon 热销产品列表与经营指标。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/ozon/data/product/hot-ranking`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| level1CategoryId | body | 是 | 一级类目 ID（见下表） |
| pageNo | body | 否 | 分页页码，从 1 开始，最大 10000；默认 `1` |
| pageSize | body | 否 | 分页大小，最大 15；默认 `15` |
| period | body | 否 | 数据周期：`SEVEN_DAY` / `TWENTY_EIGHT_DAY` / `MONTH` / `QUARTER` / `YEAR`；默认 `SEVEN_DAY` |
| updatePeriod | body | 否 | 数据更新账期；不传则取所选周期最近账期。近 7/28 天：`yyyy-MM-dd`；自然月：`yyyy-MM`；季度：`yyyy-Qn`；年度：`yyyy` |
| minSales / maxSales | body | 否 | 销量最小/最大值 |
| minGmv / maxGmv | body | 否 | 销售额最小/最大值（卢布） |
| minPrice / maxPrice | body | 否 | 平均价格最小/最大值 |
| minCreateDate / maxCreateDate | body | 否 | 商品卡创建日期范围，`yyyy-MM-dd` |
| deliveryModes | body | 否 | 发货模式数组：`FBS` / `FBO` / `rFBS` / `OZON`；不传表示全部 |
| crossBorderSalePermission | body | 否 | `1`=跨境禁止销售，`2`=跨境允许销售；不传不限 |
| productType | body | 否 | `1`=本土，`2`=跨境，`3`=未知；不传全部 |
| salesLevel | body | 否 | `1`=头部销售，`2`=前1%，`3`=前10%，`4`=前50%；不传不限 |
| sortField | body | 否 | `SALES` / `GMV` / `PRICE`；默认 `SALES` |
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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"level1CategoryId":17027489,"period":"TWENTY_EIGHT_DAY","pageNo":1,"pageSize":15,"sortField":"SALES","sortDirection":"DESC"}'
```

带筛选条件示例：

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"level1CategoryId":17027489,"period":"SEVEN_DAY","minSales":100,"productType":2,"crossBorderSalePermission":2,"deliveryModes":["FBO","FBS"],"sortField":"SALES","sortDirection":"DESC"}'
```

或使用脚本：

```bash
# 一级类目 ID（必填）+ 周期（默认 SEVEN_DAY）
bash scripts/query.sh 17027489

# 指定周期、分页与排序
bash scripts/query.sh 17027489 TWENTY_EIGHT_DAY 1 15 SALES DESC

# 指定账期（第 7 个参数）+ 额外筛选 JSON（第 8 个参数）
bash scripts/query.sh 17027489 SEVEN_DAY 1 15 SALES DESC 2026-05-20 '{"minSales":100,"productType":2,"deliveryModes":["FBO","FBS"]}'
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
- `data.data`: 当前页热销产品摘要数组
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 产品核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| itemId / itemTitle | 商品 ID、标题（俄文） |
| shopId / shopName | 店铺 ID、名称 |
| brand | 品牌 |
| category | 类目路径（中俄文） |
| sales / salesDynamics / gmv | 销量、销量动态、销售额 |
| averagePrice / grossProfitRate | 均价、毛利率 |
| cartRatio / clickRatio / orderConversionRate | 加购率、点击率、下单转化率 |
| exposureCount / browseCount | 曝光量、浏览次数 |
| adSales / adRate | 广告销量、广告占比 |
| deliveryMode / deliveryTime | 发货模式、配送时间 |
| createDate / stock / weight / volume | 创建日期、库存、重量、体积 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认一级类目（名称 → `level1CategoryId`）、数据周期与排序
2. 按用户需求补充筛选：销量/GMV/价格区间、发货模式、跨境权限、产品类型、销售水平、上架日期
3. 如指定账期，校验 `updatePeriod` 格式与 `period` 匹配
4. 检查 `CLAWEC_API_KEY` 是否可用
5. 执行 API 请求（`pageSize` 不超过 15）
6. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
7. 解析 `data.data`，结合 `total` 判断是否需翻页
8. 输出中文热销产品解读

## 输出建议

默认中文报告，包含：

- 查询条件：一级类目、周期、账期、排序、关键筛选、分页（当前页 / 总条数）
- **热销产品表**：标题（可附俄文）、商品 ID、品牌、店铺、销量、销量动态、GMV、均价、发货模式、类目中文路径
- **转化与流量**（可选展开）：加购率、点击率、下单转化、曝光/浏览、广告占比
- **机会观察**：高销量+高增速、转化较好、库存健康、适合跨境（结合筛选与 `deliveryMode`）的单品
- **结论**：推荐优先关注的 1–3 个 SKU 及理由；结果偏少时可放宽筛选或换周期/翻页

## 示例

**输入**：美容和卫生（`17027489`），近 28 天，按销量降序，跨境允许、产品类型跨境

**输出摘要**：

| 标题 | 品牌 | 销量 | 销量动态 | GMV | 均价 | 发货 | 店铺 |
|------|------|------|----------|-----|------|------|------|
| … | … | … | … | … | … | FBO | … |
| … | … | … | … | … | … | … | … |

**观察**：（结合销量、转化、广告占比与上架时间给出 2–3 条选品建议）
