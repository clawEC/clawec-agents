---
name: clawec-amazon-backend-search-terms
description: Produces Amazon Seller Central backend Search Terms—related words and phrases that fit the product but are poor for visible listing copy—so indexing can capture extra shopper queries. Use for 亚马逊后台搜索词, Search Terms, backend keywords, 隐藏关键词, 非前台检索词, or generic keyword field filling. Terms are AI suggestions; seller must paste into Search Terms per current Seller Central limits and local policy, avoid trademarks you do not own, and avoid duplicating the same tokens already heavily used in title and bullets to save space. Default English tokens for US/UK-style marketplaces unless input specifies locale; map Chinese product names to English search tokens. No invented search-volume stats; no emojis in the paste-ready string.
---

# 亚马逊后台搜索词（Search Terms）

## 何时使用本技能

在用户需要为**亚马逊卖家后台「Search Terms / 搜索词」**字段准备一批**与产品强相关、但不太适合写进标题/五点/描述前台**的词汇与短语时使用。这类词通常包含：**同义词、品类周边说法、细分场景表达、兼容/配件向说法、次要属性词**等——用于补充前台未写满或写进去会显得冗长、重复的检索面。

**不替代**卖家后台实时政策与字符/字节上限；成稿后须由卖家按当前站点**帮助中心**核对后再保存。

## 输入项（与表单一致）

| 字段 | 必填 | 说明 |
|------|------|------|
| **商品名称或者关键字** | 是 | 可为商品叫法、核心中文/英文词、品类、用途关键词等；信息越多越好，但单字段即可开工。 |

**一键粘贴模板**：

```
商品名称或者关键字（必填）：
```

## 核心原则（与前台 Listing 分工）

1. **适合后台**：前台不好意思堆叠、或会拉低可读性的词；与标题**高度重复**的词尽量不占后台额度（把额度留给**增量**检索词）。
2. **不适合强塞后台**：竞品品牌、无关大热词、虚假医疗功效词、ASIN、纯促销语（如 “free shipping today”）；**非本店品牌**商标词。
3. **语言与站点**：默认生成 **空格分隔的英文词组**（Amazon US/UK 常见写法）；若输入明确日本/欧盟等，可在 **Assumptions** 声明并按该站习惯输出（或多语言分行）。
4. **诚实边界**：不编造「官方规定外秘技」；不承诺设置后一定展示——**索引与排名由平台规则与多项因素决定**。

## 硬性输出要求

- 必须给出两类内容：**（A）一行可直接粘贴的 Search Terms 字符串**（仅空格分隔，无多余标点占额度—除非该站政策允许且用户要求）；**（B）分行说明表**（每条短语 + 一句「为何放后台、不建议上前台」），便于运营审核。
- 控制总长度在**常见后台上限思维**内：若用户未提供当地限额，在 **Assumptions** 中写「请按 Seller Central 当前字段限制截断」；优先保留**离前台重复度低、增量大**的词。
- **禁止 Emoji**；禁止在输出中伪造「搜索量、官方排名」。
- **中文名称**：主交付仍为英文 token；可在表末附「输入中文 → 对应英文词根」对照。

## 输出结构

1. **Assumptions**（可选）：站点、类目敏感边界、是否从输入推断了材质/场景（推断须保守）。
2. **Search Terms（paste-ready）**：单行字符串。
3. **Line-by-line rationale**：表格或编号列表。
4. **Dedup note**（建议固定简短）：提醒对照已准备好的标题/五点，删掉**完全重复**的无增量词后再粘贴。
5. **Compliance reminder**：勿填无权使用的品牌；勿填违规宣称；以官方当年规则为准。

## 合规与禁忌（摘要）

- 不含竞品品牌、不蹭未经授权商标。
- 不含违禁品类宣称（疗效、绝对化「治愈」等）。
- 不把后台词当作代替前台质量：前台仍需清晰合规 copy。
