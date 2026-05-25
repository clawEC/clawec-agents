---
name: clawec-tiktok-category-opportunity
description: 通过 Clawec API 对 TikTok 品类/关键词做机会分析（机会分、带货达人趋势、30天销量销售额、雷达多维评分）。在用户需要 TikTok 品类机会分析、类目选品、关键词机会评估、达人带货趋势与雷达分解读时使用。
---

# TikTok 品类机会分析

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API「产品搜索并总结 v2」，输出品类/关键词层面的机会评分与趋势摘要。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/product_search_v2`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| keyword | body | 是 | 品类/关键词（可多个相关词由 API 展开为 `keywordList`） |
| target_platform | body | 是 | **固定传 `tiktok`** |
| region | body | 是 | 目标市场（TikTok 站点代码，见下表） |
| table | body | 否 | 是否下发表格数据：`0` 否，`1` 是；默认 `0` |

### region 取值（TikTok）

| 代码 | 市场 |
|------|------|
| ID | 印度尼西亚 |
| VN | 越南 |
| MY | 马来西亚 |
| TH | 泰国 |
| PH | 菲律宾 |
| US | 美国 |
| SG | 新加坡 |
| BR | 巴西 |
| MX | 墨西哥 |
| GB | 英国 |
| ES | 西班牙 |
| FR | 法国 |
| DE | 德国 |
| IT | 意大利 |
| JP | 日本 |

未指定 `region` 时默认 `ID`。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/product_search_v2" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"keyword":"wireless earbuds","target_platform":"tiktok","region":"ID","table":0}'
```

或使用脚本（脚本内已固定 `target_platform=tiktok`）：

```bash
# 关键词 + 市场（默认 ID）
bash scripts/analyze.sh "wireless earbuds" ID

# 需要表格数据时
bash scripts/analyze.sh "wireless earbuds" US 1
```

## 响应结构

```json
{
  "status": 1,
  "data": {
    "keywordList": [ ... ]
  },
  "pointInfo": { "type": 0, "point": 0 }
}
```

- `status`: `1` = 成功，`0` = 失败
- `data.keywordList`: 关键词机会分析列表
- `pointInfo`: 积分/扣点信息 `{ type, point }`

### keywordList 核心字段

| 字段 | 说明 |
|------|------|
| keyword / keywordCn | 原始关键词 / 中文名 |
| oppScore / oppScoreDesc | 市场机会综合分及解读（越高机会越大） |
| searchRank / searchRankDesc | 最新月核心指标（带货达人数）及说明 |
| rankTrends | 近 12 个月趋势 `{ x: 月份, y: 数值 }` |
| soldCnt30d / soldCnt30dGrowthRate | 近 30 天销量及环比 |
| soldAmt30d / soldAmt30dGrowthRate | 近 30 天销售额及环比 |
| radar | 雷达多维分（市场需求、评价、新品、销售、供给等） |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认分析关键词与目标 `region`（TikTok 市场代码）
2. 确认是否需要 `table=1` 下发结构化表格
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 请求体中 **`target_platform` 固定传 `tiktok`**
5. `status !== 1` 或请求失败时，说明错误并提示检查密钥、关键词与市场代码
6. 遍历 `data.keywordList`，按 `oppScore` 排序并解读趋势与雷达分
7. 输出中文机会分析报告

## 输出建议

默认中文报告，包含：

- 分析关键词、市场（`region`）、返回关键词数量
- **机会榜**：`keywordCn`、机会分、带货达人数、30 天销量/销售额及环比
- **趋势**：对头部词的 `rankTrends` 用 1–2 句话概括升降（结合 `rankTrendsDesc`、`rankTrendsPointName`）
- **雷达**：列出 `radar.propertyList` 各维度得分，指出强项与短板
- **结论**：推荐优先关注的 1–3 个词及理由；若机会分接近，说明需结合供给/新品分综合判断

## 示例

**输入**：印尼市场分析品类关键词「phone case」

**输出摘要**：

| 关键词 | 机会分 | 带货达人数 | 30天销量 | 销量环比 | 销售额环比 |
|--------|--------|------------|----------|----------|------------|
| phone case | 85 | ... | ... | UP 1.2% | DOWN -0.5% |
| ... | ... | ... | ... | ... | ... |

**雷达（示例）**：市场需求 78、市场销售 82、市场供给 65 …

（详细解读见各词的 `oppScoreDesc` 与 `radar.radarDescription`。）
