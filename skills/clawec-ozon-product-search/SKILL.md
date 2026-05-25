---
name: clawec-ozon-product-search
description: 通过 Clawec API 搜索 Ozon 商品，返回价格、销量、评分、市场、链接与图片等。在用户需要 Ozon 搜品、俄罗斯及东欧跨境选品、竞品调研、关键词找货、Ozon 产品搜索时使用。
---

# Ozon 商品搜索

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于 Ozon 商品搜索与俄罗斯及东欧市场选品调研。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/ozon_search`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| keyword | body | 是 | 搜索关键词 |

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon_search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"keyword":"蓝牙耳机"}'
```

或使用脚本：

```bash
bash scripts/search.sh "蓝牙耳机"
```

## 响应结构

```json
{
  "status": 1,
  "data": [ ... ],
  "pointInfo": { "type": 0, "point": 0 }
}
```

- `status`: `1` = 成功，`0` = 失败
- `data`: 商品数组，失败或空结果时按实际返回处理
- `pointInfo`: 积分/扣点信息 `{ type, point }`

### 商品字段

| 字段 | 说明 |
|------|------|
| id | 商品 ID |
| name | 名称 |
| price | 价格 |
| cover | 封面图 URL |
| rating | 排名 |
| sales | 销量 |
| star | 评分 |
| images | 图片 URL 数组 |
| url | 商品链接 |
| market | 市场/站点 |

完整字段说明见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认搜索关键词
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. `status !== 1` 或请求失败时，说明错误并提示检查密钥与参数
5. 解析 `data`，按用户需求整理输出

## 输出建议

默认中文摘要，包含：

- 命中数量
- 商品对比表：名称、价格、销量、评分、排名、市场、链接
- 选品调研场景：可按价格/销量/评分排序，并按 `market` 分组观察

## 示例

**输入**：搜索「蓝牙耳机」

**输出摘要**：

| 名称 | 价格 | 销量 | 评分 | 排名 | 市场 | 链接 |
|------|------|------|------|------|------|------|
| ... | ... | ... | ... | ... | ... | ... |
