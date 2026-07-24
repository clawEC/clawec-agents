---
name: clawec-shopee-item-ranking
description: 通过 Clawec API 查询 Shopee 商品榜单（热销榜/飙升榜，天周月，总榜/跨境/本土）。在用户需要虾皮商品榜、热销榜、飙升榜、类目爆品、站点榜单选品时使用。
---

# Shopee 商品榜单

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按站点与类目查询 Shopee 商品热销榜 / 飙升榜。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/shopee/data/item/ranking`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点：`tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| categoryId | body | 是 | 类目 ID（一级类目见下表） |
| sortField | body | 是 | `1`=热销榜 `2`=飙升榜 |
| period | body | 是 | `1`=天榜 `2`=周榜 `3`=月榜 |
| date | body | 否 | 榜单日期，`yyyy-MM-dd`；不传默认昨天 |
| borderType | body | 否 | `0`=总榜单（默认）`1`=跨境榜单 `2`=本土榜单 |
| productType | body | 否 | `1`=虾皮优选 `2`=虾皮商城 `3`=其他 `0`=全部（默认） |
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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","categoryId":100630,"sortField":1,"period":3,"borderType":0,"pageNo":1,"pageSize":10}'
```

跨境飙升周榜示例：

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/ranking" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","categoryId":100630,"sortField":2,"period":2,"borderType":1,"date":"2026-07-01"}'
```

或使用脚本：

```bash
# 站点 + 类目 + 榜单类型(1热销/2飙升) + 周期(1天/2周/3月)（均必填）
bash scripts/query.sh tw 100630 1 3

# 指定榜单类型、产品类型、分页、日期
bash scripts/query.sh tw 100630 1 3 0 0 1 10 2026-07-01
```

脚本参数顺序：`site categoryId sortField period [borderType] [productType] [pageNo] [pageSize] [date]`

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
- `data.data`: 当前页榜单商品数组
- `data.total` / `pageNo` / `pageSize`: 分页元数据

### 榜单核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| itemId / itemName / itemImg | 商品 ID、标题、图片 |
| itemLocalPath / itemBorderPath | 本土 / 跨境商品链接 |
| site / catId / catName | 站点、类目 |
| shopName / productTypeName / shopTypeName | 店铺、商品类型名、店铺类型名 |
| price / ctime | 价格、上架时间 |
| sales / sales7day / sales30day / totalSales | 日/周/月/累计销量 |
| gmv / gmv7day / gmv30day | 日/周/月销售额 |
| ratingStar / likeCount / commentCount | 评分、点赞、评论 |
| timest | 更新账期 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认站点、类目、榜单类型（热销/飙升）、周期（天/周/月）
2. 按需确认总榜/跨境/本土、产品类型、榜单日期
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求（`pageSize` 不超过 10）
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
6. 解析 `data.data`，结合 `total` 判断是否需翻页
7. 输出中文榜单解读

## 输出建议

默认中文报告，包含：

- 查询条件：站点、类目、热销/飙升、天/周/月、总榜或跨境/本土、日期、分页
- **榜单表**：排名序号、标题、价格、对应周期销量/GMV、评分、店铺类型、链接（优先展示与 `borderType` 匹配的链接）
- **机会观察**：热销榜看体量与价格带；飙升榜看增速潜力与上架时间
- **结论**：推荐关注的 1–3 个商品及理由

## 示例

**输入**：台湾站美妆保养月热销总榜

**输出摘要**：

| 排名 | 标题 | 价格 | 30天销量 | 30天GMV | 评分 | 店铺类型 | 链接 |
|------|------|------|----------|---------|------|----------|------|
| 1 | … | … | … | … | … | 跨境店铺 | … |
| … | … | … | … | … | … | … | … |

**观察**：（结合榜单类型与销量结构给出 2–3 条选品建议）
