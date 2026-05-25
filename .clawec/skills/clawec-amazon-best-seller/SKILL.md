---
name: clawec-amazon-best-seller
description: 通过 Clawec API 查询亚马逊 Best Sellers 销售排行榜，可按类目筛选。在用户需要亚马逊畅销榜、销售排行、Best Seller 榜单、类目热销、竞品榜调研时使用。
---

# 亚马逊销售排行

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于获取亚马逊 Best Sellers 畅销榜数据。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/tool/amazon_best_seller`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| cat | body | 否 | 类目代码；用户未指定类目时传空字符串 `""` |

### cat 可选值

只能传空或下表中的代码之一：

| 代码 | 类目 |
|------|------|
| `""` | 不限类目（全站/默认畅销榜） |
| lawn-garden | 庭院与园艺 |
| fashion | 时尚 |
| amazon-devices | Amazon 设备 |
| music | 音乐 |
| musical-instruments | 乐器 |
| sports-collectibles | 运动与收藏品 |
| office-products | 办公用品 |
| books | 图书 |
| appliances | 家电 |
| baby-products | 母婴 |
| pet-supplies | 宠物用品 |
| home-garden | 家居与园艺 |

用户用中文描述类目时，映射到上表代码后再请求；无法映射时传 `""` 并说明已按全类目查询。

## 调用

**不限类目（默认）：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/tool/amazon_best_seller" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"cat":""}'
```

**指定类目：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/tool/amazon_best_seller" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"cat":"books"}'
```

或使用脚本：

```bash
# 不限类目
bash scripts/rank.sh

# 指定类目
bash scripts/rank.sh books
```

## 响应结构

```json
{
  "status": 1,
  "data": { ... }
}
```

- `status`: `1` = 成功，`0` = 失败
- `data`: 畅销榜数据对象或列表，字段以实际返回为准

完整说明见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认用户是否指定类目；未指定则 `cat` 传 `""`
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. `status !== 1` 或请求失败时，说明错误并提示检查密钥与 `cat` 是否在可选范围内
5. 解析 `data`（若为嵌套结构，展开商品列表），按用户需求整理输出

## 输出建议

默认中文摘要，包含：

- 查询类目（或「全类目」）
- 榜单 Top N：排名、名称、价格、销量、评分、链接等（以 `data` 实际字段为准）
- 选品/竞品场景：归纳头部价格带、品牌集中度或差异化机会 2–3 条

## 示例

**输入**：查询「图书」类目畅销榜

**输出摘要**：

| 排名 | 名称 | 价格 | 销量 | 评分 | 链接 |
|------|------|------|------|------|------|
| 1 | ... | ... | ... | ... | ... |
| 2 | ... | ... | ... | ... | ... |

（其余字段按 API 返回的 `data` 动态展示。）
