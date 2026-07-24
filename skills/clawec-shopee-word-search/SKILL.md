---
name: clawec-shopee-word-search
description: 通过 Clawec API 查询 Shopee 热搜词列表（按站点/类目，含搜索指数、近30天销量销售额、推荐出价、产品数等筛选）。在用户需要虾皮热搜词榜、类目选词、关键词机会、广告出价参考时使用；单品引流词请用 clawec-shopee-item-hotword。
---

# Shopee 热搜词列表

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按站点（可选类目）查询 Shopee 热搜词列表。与单品热搜词（`/aigc/ec/shopee/data/item/hotword`）不同，本接口是类目/站点维度的热搜词库查询。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/shopee/data/word/search`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点：`tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | body | 否 | 类目 ID（一级类目见下表） |
| categoryLocation | body | 否 | `1`=本土 `2`=跨境 `0`=全部（默认） |
| itemCountMin / itemCountMax | body | 否 | 产品总数区间 |
| sales30dayMin / sales30dayMax | body | 否 | 近 30 天销量区间 |
| recPriceMin / recPriceMax | body | 否 | 推荐出价区间 |
| sortType | body | 否 | `1`=近30天销量（默认）`2`=推荐出价 `3`=搜索指数 `4`=产品总数 |
| pageNo | body | 否 | 当前页码；默认 `1` |
| pageSize | body | 否 | 每页条数，最大 100；默认 `10` |
| timest | body | 否 | 查询账期，`yyyy-MM-dd`；不传默认昨天 |

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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/word/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","categoryId":100630,"sortType":3,"pageNo":1,"pageSize":10}'
```

带筛选条件示例：

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/word/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","categoryId":100630,"categoryLocation":2,"sales30dayMin":100,"sortType":1,"pageSize":20}'
```

或使用脚本：

```bash
# 站点（必填）
bash scripts/query.sh tw

# 站点 + 类目 + 排序 + 分页
bash scripts/query.sh tw 100630 3 1 10

# 账期（第 6 个参数）+ 额外筛选 JSON（第 7 个参数）
bash scripts/query.sh tw 100630 1 1 10 2026-05-26 '{"categoryLocation":2,"sales30dayMin":100,"recPriceMax":5}'
```

脚本参数顺序：`site [categoryId] [sortType] [pageNo] [pageSize] [timest] [filtersJson]`  
不传类目时，第 2 个参数可写空字符串 `""`。

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
- `data.data`: 当前页热搜词数组
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 热搜词核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| hotWordId / word / transCn / transEn | 词 ID、源语、中文、英文 |
| catId / catName | 类目 |
| searchIndex / recPrice | 近30天搜索指数、推荐出价 |
| itemCount / activeItemCount / dailyActiveRate | 产品数、有销量产品数、日动销率 |
| sales / sales30day / sales30dayGrowthRate | 日销量、月销量、月销量增长率 |
| gmv / gmv30day / itemAveragePrice | 日/月销售额、产品均价 |
| likeCount / ratingNum / timest | 点赞、评论、账期 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认站点；按需确认类目、本土/跨境、筛选区间与排序
2. 如指定账期，校验 `timest` 为 `yyyy-MM-dd`
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求（`pageSize` 不超过 100）
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
6. 解析 `data.data`，结合 `total` 判断是否需翻页
7. 输出中文热搜词解读与选词建议

## 输出建议

默认中文报告，包含：

- 查询条件：站点、类目、本土/跨境、筛选、排序、账期、分页
- **热搜词表**：中文词、源语/英文、搜索指数、月销量、月销量增速、月GMV、产品数、推荐出价、均价
- **选词机会**：高指数 + 增速好、或产品数适中/出价合理的词
- **结论**：推荐优先布局的 3–5 个词及理由

## 示例

**输入**：台湾站美妆保养，按搜索指数排序

**输出摘要**：

| 中文词 | 源语 | 搜索指数 | 30天销量 | 增速 | 30天GMV | 产品数 | 推荐出价 |
|--------|------|----------|----------|------|---------|--------|----------|
| … | … | … | … | … | … | … | … |

**观察**：（结合指数、增速与出价给出选词建议）
