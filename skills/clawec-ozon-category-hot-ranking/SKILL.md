---
name: clawec-ozon-category-hot-ranking
description: 通过 Clawec API 查询 Ozon 类目热销榜单（GMV/销量/价格排序、动销率、佣金、跨境占比等）。在用户需要 Ozon 类目热销榜、品类选品、类目机会对比、俄罗斯跨境类目调研时使用。
---

# Ozon 类目热销榜单

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于查询 Ozon 一级类目下的热销子类目榜单与经营指标。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/ozon/data/category/hot-ranking`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| categoryId | body | 是 | 一级类目 ID（见下表） |
| pageNo | body | 否 | 分页页码，从 1 开始，最大 10000；默认 `1` |
| pageSize | body | 否 | 分页大小，最大 15；默认 `15` |
| language | body | 否 | 类目语言：`CH` 中文、`RU` 俄文、`EN` 英文；默认 `CH` |
| period | body | 否 | 数据周期：`SEVEN_DAY` / `TWENTY_EIGHT_DAY` / `MONTH` / `QUARTER` / `YEAR`；默认 `SEVEN_DAY` |
| updatePeriod | body | 否 | 数据更新账期；不传则取所选周期最近账期。近 7/28 天：`yyyy-MM-dd`；自然月：`yyyy-MM`；季度：`yyyy-Qn`；年度：`yyyy` |
| sortField | body | 否 | 排序字段：`SALES` 销量、`GMV` 销售额、`PRICE` 价格；默认 `GMV` |
| sortDirection | body | 否 | 排序方向：`ASC` / `DESC`；默认 `DESC` |

### categoryId 一级类目对照

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

用户用中文类目名表述时，先映射到上表 `categoryId` 再请求。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/category/hot-ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"categoryId":17027489,"period":"SEVEN_DAY","pageNo":1,"pageSize":15,"sortField":"GMV","sortDirection":"DESC","language":"CH"}'
```

或使用脚本：

```bash
# 一级类目 ID（必填）+ 周期（默认 SEVEN_DAY）
bash scripts/query.sh 17027489

# 指定周期、分页与排序
bash scripts/query.sh 17027489 SEVEN_DAY 1 15 GMV DESC CH

# 指定更新账期（第 8 个参数）
bash scripts/query.sh 17027489 SEVEN_DAY 1 15 GMV DESC CH 2026-05-20
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
- `data.data`: 当前页类目热销摘要数组
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 榜单核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| category | 类目路径（含一/二/三级 ID 与中俄文名称） |
| crossBorderSalePermission | 跨境禁售权限 |
| updatePeriod | 更新账期 |
| totalProductCount / salableProductCount / salesRate | 商品总数、有销量商品数、动销率 |
| gmv / gmvGrowthRate | 销售额及增长率 |
| topBrandGmv / brandGmvRate | 头部品牌销售额及占比 |
| topGmv / topGmvRate / topAveragePrice | 头部销售额、占比、平均价 |
| commissionRates | FBO/FBS/RFBS/FBP 佣金比例 |
| crossBorderProductShare | 跨境商品占比 |
| averageSales / averageGmv / averageCancelRate | 平均销量、销售额、取消率 |
| averageWeight / averageVolume | 平均重量、体积 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认一级类目（名称 → `categoryId`）、数据周期与排序方式
2. 如用户指定账期，校验 `updatePeriod` 格式与 `period` 匹配
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求（`pageSize` 不超过 15）
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
6. 解析 `data.data`，结合 `total` 判断是否需翻页
7. 输出中文热销榜解读

## 输出建议

默认中文报告，包含：

- 查询条件：一级类目名与 ID、周期、账期、排序、分页（当前页 / 总条数）
- **热销榜表**：类目中文路径、GMV、GMV 增速、动销率、跨境占比、头部均价、跨境权限
- **机会观察**：指出高 GMV + 高增速、或高增速但动销率/竞争（头部占比）尚可的子类目
- **成本提示**：摘录 `commissionRates` 与均重/均体积，便于粗估履约成本
- **结论**：推荐优先关注的 1–3 个三级类目及理由；若结果偏少可建议换周期或翻页

## 示例

**输入**：美容和卫生（`17027489`），近 7 天，按 GMV 降序

**输出摘要**：

| 类目 | GMV | GMV增速 | 动销率 | 跨境占比 | 头部均价 | 跨境权限 |
|------|-----|---------|--------|----------|----------|----------|
| 美容和卫生 > … > … | … | … | … | … | … | 跨境允许销售 |
| … | … | … | … | … | … | … |

**观察**：（结合增速、动销与佣金给出 2–3 条选品建议）
