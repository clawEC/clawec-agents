---
name: clawec-shopee-item-hotword
description: 通过 Clawec API 查询 Shopee 商品热搜词（引流词/同类目热词，含搜索指数、近30天销量销售额、推荐出价）。在用户需要虾皮热搜词、引流词分析、同类目热词、SEO/广告选词时使用。
---

# Shopee 商品热搜词

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按商品 ID 查询 Shopee 引流词或同类目热词（最多 10 个商品）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/shopee/data/item/hotword`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点：`tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| itemIds | body | 是 | 商品 ID；最多 10 个，多个用**英文逗号**分隔 |
| type | body | 是 | `1`=引流词 `2`=同类目热词 |
| timest | body | 否 | 查询账期，`yyyy-MM-dd`，只能选某一天；不传默认昨天 |

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

超过 10 个商品 ID 时拆成多批请求。

## 调用

**引流词：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/hotword" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","itemIds":"1234567890","type":1}'
```

**同类目热词 + 账期：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/hotword" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","itemIds":"1234567890,1234567891","type":2,"timest":"2026-05-26"}'
```

或使用脚本：

```bash
# 站点 + 商品 ID + 类型(1引流词/2同类目热词)（均必填）
bash scripts/query.sh tw 1234567890 1

# 批量 ID + 同类目热词 + 账期
bash scripts/query.sh tw "1234567890,1234567891" 2 2026-05-26
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
- `data.data`: 热搜词列表

### 热搜词核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| hotWordName | 热搜词 |
| searchIndex | 搜索指数 |
| itemCount | 产品数 |
| sales30day / gmv30day | 近 30 天销量 / 销售额 |
| recPrice | 推荐出价 |
| site / timest | 站点、日期 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认站点、商品 ID 列表（最多 10 个）、词类型（引流词 / 同类目热词）
2. 如指定账期，校验 `timest` 为 `yyyy-MM-dd`
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥与参数
6. 解析 `data.data`，按搜索指数或销量排序并给出选词建议

## 输出建议

默认中文报告，包含：

- 查询条件：站点、商品 ID、类型（引流词/同类目热词）、账期
- **热搜词表**：热搜词、搜索指数、产品数、近30天销量、近30天GMV、推荐出价
- **选词机会**：高搜索指数 + 转化体量尚可、或竞品产品数适中的词
- **结论**：推荐优先布局的 3–5 个词及理由（标题/广告词区分引流词与同类目热词）

## 示例

**输入**：台湾站商品 `1234567890`，引流词

**输出摘要**：

| 热搜词 | 搜索指数 | 产品数 | 30天销量 | 30天GMV | 推荐出价 |
|--------|----------|--------|----------|---------|----------|
| 连衣裙 | … | … | … | … | … |
| … | … | … | … | … | … |

**观察**：（结合指数、体量与出价给出选词建议）
