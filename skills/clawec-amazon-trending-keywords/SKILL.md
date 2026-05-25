---
name: clawec-amazon-trending-keywords
description: Suggests Amazon-style high-intent and discovery keywords from user product context to help improve listing visibility and attract shoppers. Use for 亚马逊流行词推荐, Amazon keyword ideas, 热词, 引流词, search terms, backend keywords brainstorming. Outputs are AI-derived candidates, not live search-volume data—remind sellers to validate in Brand Analytics or trusted tools. No emojis in the keyword list unless user asks for annotation style.
---

# 亚马逊流行词推荐

## 何时使用本技能

在用户需要根据**产品信息**批量获得**亚马逊向的流行词 / 检索词候选**（用于标题、埋词、Search Terms、广告拓词思路）时使用。本技能产出的是**基于语境推理的候选词表**，**不能**等同官方实时搜索量或「当前平台排名第一的热词」；落地前应用卖家后台或第三方工具做**相关性**与**竞争度**核验。

## 输入项（与表单一致，两项均必填）

| 字段 | 必填 | 说明 |
|------|------|------|
| **产品信息** | 是 | 品类、材质、用途、人群、竞品差异、核心中文或英文词等；越具体，推荐越贴 SKU。 |
| **个数** | 是 | 需要输出的**关键词条数**（正整数）。若用户填非法或非数字，先澄清 or 默认 **10** 并在 **Assumptions** 中声明。 |

**一键粘贴模板**：

```
产品信息（必填）：
个数（必填）：
```

## 核心目标

1. **亚马逊语境**：词汇符合买家在亚马逊上的搜索习惯（名词短语、属性组合、场景词、兼容/尺寸类长尾等），避免纯新闻热点或站外梗词。
2. **覆盖面**：在条数限制内混合 **核心词、修饰词长尾、场景/人群词、问题意图变体**（如 *for …*, *with …*），减少彼此完全重复。
3. **可运营**：每条词**单独成行**，便于复制到表格；必要时用极短英文括号标注「适合标题 / 适合要点 / 适合后台 ST」之类标签（仅当用户未禁止且有助于执行）。

## 硬性输出要求

- **输出条数 = 用户给定个数**（去重后仍尽量凑满；若产品过窄实在无法合规凑满，在末尾说明缺口原因并给出可通过工具扩展的方向）。
- **语言**：默认 **英文** 关键词（Amazon US/UK 等）；若产品信息明确日本/德国等站，可输出对应语言分区或中英对照一行，并在 **Assumptions** 中写明站点假设。
- **禁止**：杜撰具体「月搜索量」「排名第几」等数据；可写「高意向 / 长尾 / 品牌防御周边」等**定性**标签。
- **中文产品信息**：先理解语义，再给出**英文检索词**为主列表；可在表末加一列或附录「中文意图 → 推荐英文」对照（可选）。

## 输出结构

按需选用下列结构（保持清晰小标题）：

1. **Assumptions**（可选）：推断的站点、类目、是否成人/敏感类目（仅用中性表述）。
2. **Recommended keywords**（主表）：编号 1…N，每行一条；或 Markdown 表格列：`# | Keyword | Note (optional)`。
3. **How to validate**（固定简短一段）：建议用卖家后台品牌分析、ABA、或自有选品工具核对搜索量与相关性；上新后看广告搜索词报告迭代。
4. **Keywords coverage**（可选）：若用户同时粘贴了「必须包含的词根」，列表说明每条词根被哪些行覆盖。

## 合规与禁忌

- 不用竞品品牌名做「蹭流量」推荐；不引导违规操纵评论或排名。
- 敏感类目（医疗声明等）避免推荐带治愈、疗效承诺的词组。
