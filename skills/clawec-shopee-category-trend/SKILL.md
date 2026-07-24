---
name: clawec-shopee-category-trend
description: 通过 Clawec API 查询 Shopee 类目趋势概览（多站点、月/季/年颗粒度，销量销售额、产品数、店铺品牌数时间序列）。在用户需要虾皮类目趋势、市场走势、跨站点类目对比、选品前趋势验证时使用。
---

# Shopee 类目趋势概览

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于查询 Shopee 类目在指定时间范围内的趋势概览（支持多站点）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/shopee/data/category/trend`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| sites | body | 是 | 站点列表（数组，支持多选）：`tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| catId | body | 是 | 类目 ID（一级类目见下表） |
| granularity | body | 是 | 统计颗粒度：`1`=自然月 `2`=自然季度 `3`=年 |
| startDate | body | 是 | 数据范围开始，`yyyy-MM-dd` |
| endDate | body | 是 | 数据范围结束，`yyyy-MM-dd` |
| productType | body | 否 | `0`=全部（默认）`1`=虾皮优选 `2`=虾皮商城 `3`=其他 |
| location | body | 否 | `0`=全部（默认）`1`=本地 `2`=跨境 |

### sites 站点对照

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

### catId 一级类目对照

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

**单站点 + 自然月：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/category/trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"sites":["tw"],"catId":100630,"granularity":1,"startDate":"2026-01-01","endDate":"2026-06-26"}'
```

**多站点对比：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/category/trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"sites":["tw","my","sg"],"catId":100630,"granularity":1,"startDate":"2026-01-01","endDate":"2026-06-26","location":2}'
```

或使用脚本：

```bash
# 站点(逗号分隔) + 类目 + 颗粒度(1月/2季/3年) + 开始日 + 结束日（均必填）
bash scripts/query.sh tw 100630 1 2026-01-01 2026-06-26

# 多站点 + 产品类型 + 本地/跨境
bash scripts/query.sh "tw,my,sg" 100630 1 2026-01-01 2026-06-26 0 2
```

脚本参数顺序：`sites catId granularity startDate endDate [productType] [location]`

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
- `data.data`: 趋势概览时间序列（按账期/站点展开）

### 趋势核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| date / site | 账期（如 `2026-01`）、站点 |
| catId / catName / level | 类目 ID、名称、级别（1/2/3） |
| itemCount / activeItemCount | 产品数、有销量产品数 |
| sales / gmv | 销量、销售额 |
| brandCount / shopCount / activeShopCount | 品牌数、店铺数、有销量店铺数 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认站点列表、类目、颗粒度（月/季/年）、起止日期
2. 按需确认产品类型、本地/跨境
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求（`sites` 必须以数组提交）
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
6. 按站点分组，按 `date` 排序，解读升降趋势
7. 输出中文类目趋势报告

## 输出建议

默认中文报告，包含：

- 查询条件：站点、类目、颗粒度、时间范围、筛选
- **趋势表**：账期、站点、销量、GMV、产品数、有销量产品数、店铺数、品牌数
- **走势解读**：各站点销量/GMV 升降；多站点时做横向对比
- **结论**：市场是否扩张、供给（产品/店铺）是否同步增长，给出 2–3 条选品建议

## 示例

**输入**：台湾站美妆保养，2026-01-01 ~ 2026-06-26，自然月

**输出摘要**：

| 账期 | 站点 | 销量 | GMV | 产品数 | 有销量产品 | 店铺数 |
|------|------|------|-----|--------|------------|--------|
| 2026-01 | tw | … | … | … | … | … |
| 2026-02 | tw | … | … | … | … | … |

**观察**：（结合销量与供给变化给出趋势结论）
