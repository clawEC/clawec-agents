---
name: clawec-1688-product-search
description: 通过 Clawec API 搜索 1688 商品，返回价格、销量、链接、卖家信息与 AI 建议。在用户需要 1688 搜品、货源调研、供应链比价、跨境选品、关键词找货、1688 产品搜索时使用。
---

# 1688 产品搜索

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于 1688 货源搜索与供应链调研。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`GET /aigc/tool/1688_product_search_lite`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| keyword | query | 是 | 搜索关键词 |
| page | query | 否 | 页码，默认 1 |
| table | query | 否 | 默认 0 |

## 调用

```bash
curl -s -G "https://www.clawec.com/api/aigc/tool/1688_product_search_lite" \
  --data-urlencode "keyword=蓝牙耳机" \
  --data-urlencode "page=1" \
  --data-urlencode "table=0" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY"
```

或使用脚本：

```bash
bash scripts/search.sh "蓝牙耳机" 1 0
```

## 响应结构

```json
{
  "status": 1,
  "data": [ ... ]
}
```

- `status`: `1` = 成功，`0` = 失败
- `data`: 商品数组，失败或空结果时按实际返回处理

### 商品字段

| 字段 | 说明 |
|------|------|
| name | 名称 |
| price | 价格 |
| sale | 销量 |
| cover | 封面图 URL |
| url | 商品链接 |
| id | 产品 ID |
| _1688Id | 1688 ID |
| aiSuggest | AI 建议 |
| features | 特点 `[{ label, value }]` |
| sellerInfo | 卖家 `{ name, url }` |
| purchaseCondition | 购买条件 `[{ label, value }]` |

完整字段说明见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认搜索关键词；需要翻页时确认 `page`
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. `status !== 1` 或请求失败时，说明错误并提示检查密钥与参数
5. 解析 `data`，按用户需求整理输出

## 输出建议

默认中文摘要，包含：

- 命中数量与当前页码
- 商品对比表：名称、价格、销量、卖家、链接
- 展示 `aiSuggest`（若有）
- 货源调研场景：可按价格/销量排序，并给出 2–3 条选品观察

## 示例

**输入**：搜索「硅胶手机壳」，第 1 页

**输出摘要**：

| 名称 | 价格 | 销量 | 卖家 | 链接 |
|------|------|------|------|------|
| ... | ... | ... | ... | ... |

**AI 建议**：（摘录各商品 `aiSuggest` 中的要点）
