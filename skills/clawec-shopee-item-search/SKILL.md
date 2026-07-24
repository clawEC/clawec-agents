---
name: clawec-shopee-item-search
description: 通过 Clawec API 按站点与类目查询 Shopee 商品列表（近30天销量/GMV、价格、本土跨境、优选商城等筛选）。在用户需要虾皮类目搜品、Shopee 商品数据榜、站点选品、销量销售额筛选时使用；关键词搜品请用 clawec-shopee-product-search。
---

# Shopee 类目商品搜索

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按站点与类目查询 Shopee 商品列表及销量/销售额等经营指标。与关键词搜品技能（`/aigc/ec/shopee_search`）不同，本接口按类目与数据筛选条件查询。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/shopee/data/item/search`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点：`tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | body | 是 | 类目 ID（一级类目见下表） |
| productType | body | 否 | `1`=虾皮优选 `2`=虾皮商城 `3`=其他 `0`=全部（默认） |
| isBorder | body | 否 | `1`=本土 `2`=跨境 `0`=全部（默认） |
| ctimeStart / ctimeEnd | body | 否 | 上架时间范围，`yyyy-MM-dd` |
| sales30dayMin / sales30dayMax | body | 否 | 近 30 天销量区间 |
| gmv30dayMin / gmv30dayMax | body | 否 | 近 30 天销售额区间 |
| priceMin / priceMax | body | 否 | 价格区间 |
| sortType | body | 否 | `1`=近30天销量（默认）`2`=近30天销售额 `3`=价格 |
| sortOrder | body | 否 | `asc` / `desc`（默认 `desc`） |
| timest | body | 否 | 查询账期，`yyyy-MM-dd`，只能选某一天；不传默认昨天 |
| pageNo | body | 否 | 分页页码，从 1 开始，最大 100000；默认 `1` |
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

### categoryId 一级类目对照

| ID | 类目 |
|----|------|
| 100001 | 保健 |
| 100009 | 时尚配饰 |
| 100010 | 家用电器 |
| 100011 | 男装服饰 |
| 100012 | 男士鞋 |
| 100013 | 手机平板与配件 |
| 100015 | 旅行&行李箱 |
| 100016 | 女士包 |
| 100017 | 女装服饰 |
| 100531 | 美食外送 |
| 100532 | 女鞋 |
| 100533 | 男士包 |
| 100534 | 手表 |
| 100535 | 音响设备 |
| 100629 | 美食、伴手礼 |
| 100630 | 美妆保养 |
| 100631 | 宠物 |
| 100632 | 母婴用品 |
| 100633 | 婴幼童时装 |
| 100634 | 游戏 & 电玩 |
| 100635 | 相机 & 无人机 |
| 100636 | 居家生活 |
| 100637 | 运动与户外活动 |
| 100638 | 文具 |
| 100639 | 珍藏品 |
| 100640 | 汽车类 |
| 100641 | 摩托车类 |
| 100642 | 票务、优惠券与服务 |
| 100643 | 书籍 & 杂志 |
| 100644 | 电脑 & 配件 |
| 102053 | 附近优惠 |
| 102187 | 车辆备件和配件 |

用户用中文类目名或站点名表述时，先映射到上表代码再请求。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","categoryId":100630,"sortType":1,"sortOrder":"desc","pageNo":1,"pageSize":10}'
```

带筛选条件示例：

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","categoryId":100630,"isBorder":2,"sales30dayMin":100,"priceMin":10,"priceMax":1000,"sortType":1,"sortOrder":"desc"}'
```

或使用脚本：

```bash
# 站点 + 类目 ID（必填）
bash scripts/query.sh tw 100630

# 指定排序与分页
bash scripts/query.sh tw 100630 1 desc 1 10

# 账期（第 7 个参数）+ 额外筛选 JSON（第 8 个参数）
bash scripts/query.sh tw 100630 1 desc 1 10 2026-07-13 '{"isBorder":2,"sales30dayMin":100,"priceMax":1000}'
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
    "pageSize": 10
  }
}
```

- 顶层 `status`: `1` = 成功，`0` = 失败
- `data.success` / `errorCode` / `errorMessage`: 业务层成功与错误信息
- `data.data`: 当前页商品摘要数组
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 商品核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| itemId / itemName | 商品 ID、标题 |
| site / catId / catName | 站点、类目 |
| shopName / productType / shopType | 店铺、商品类型、店铺类型（1本土/2跨境） |
| price / ctime | 价格、上架时间 |
| sales / sales7day / sales30day / totalSales | 日/周/月/累计销量 |
| gmv / gmv7day / gmv30day | 日/周/月销售额 |
| ratingStar / likeCount / commentCount | 评分、点赞、评论 |
| timest | 更新账期 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认站点 `site` 与类目（名称 → `categoryId`）
2. 按需补充筛选：产品类型、本土/跨境、上架时间、销量/GMV/价格区间、账期
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求（`pageSize` 不超过 10）
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
6. 解析 `data.data`，结合 `total` 判断是否需翻页
7. 输出中文商品列表解读

## 输出建议

默认中文报告，包含：

- 查询条件：站点、类目、筛选、排序、账期、分页（当前页 / 总条数）
- **商品表**：标题、商品 ID、价格、近30天销量、近30天GMV、评分、店铺、本土/跨境、上架时间
- **机会观察**：高销量/高 GMV、评分稳定、适合跨境或本土切入的单品
- **结论**：推荐关注的 1–3 个商品及理由；结果偏少时可放宽筛选或翻页

## 示例

**输入**：台湾站美妆保养（`100630`），按近30天销量降序

**输出摘要**：

| 标题 | 价格 | 30天销量 | 30天GMV | 评分 | 店铺 | 类型 |
|------|------|----------|---------|------|------|------|
| … | … | … | … | … | … | 跨境 |
| … | … | … | … | … | … | … |

**观察**：（结合销量、价格带与上架时间给出 2–3 条选品建议）
