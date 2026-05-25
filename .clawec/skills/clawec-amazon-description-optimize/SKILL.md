---
name: clawec-amazon-description-optimize
description: Rewrites and optimizes Amazon product descriptions for fluent English, high keyword integration, clear feature emphasis, and stronger appeal and conversion. Use for 亚马逊商品描述生成和优化, listing description, 描述优化, 商品详情文案, 埋词. No emojis or decorative symbols; do not invent specs absent from user text; default English marketplace; map Chinese keywords to natural English search phrases. Before delivery, verify no sticky words (missing spaces between English words).
---

# 亚马逊商品描述生成和优化

## 何时使用本技能

在用户需要**只针对商品描述（Product Description）**做生成、扩写或重写时使用：**高效精炼**、**高埋词率**、**突出商品特色**、提升吸引力与购买转化率。与 `clawec-amazon-listing-standard` 分工：本技能**不默认输出标题与五点**，只聚焦描述区块（除非用户额外要求）。

## 输入项（与表单一致，三项均必填）

| 字段 | 必填 | 说明 |
|------|------|------|
| **商品标题** | 是 | 锚定产品身份、品类与术语；优化后的描述须与标题**无事实冲突**（品名、核心品类、关键属性一致）。 |
| **关键字** | 是 | 待埋入描述的核心词、长尾词、场景词；每条独立词须在**成稿描述中至少出现一次**（允许合理词形变化，检索意图一致）。 |
| **商品描述** | 是 | 用户提供的**现有描述、要点草稿或素材**；在其基础上精炼、重组、扩写并提高埋词与自然度，**不删除用户已写明的真实规格**；若原文极短，可合理扩写但仍不得编造用户未给出的数字与认证。 |

**一键粘贴模板（对齐表单）**：

```
商品标题（必填）：
关键字（必填）：
商品描述（必填）：
```

## 硬性输出要求（必须遵守）

- **主交付物为「优化后的 Product Description」**：默认输出 **2–4 个完整英文段落**（纯文本；除非用户明确要求 HTML/AE 格式）。段落宜短、可扫读，避免空洞排比与国内种草口号。
- **禁止 Emoji 与装饰性符号**：正文中不得使用 Emoji、颜文字、花哨符号。
- **禁止编造可量化规格**：用户未在「标题 / 关键字 / 商品描述」中给出的续航、尺寸、容量、认证编号等，**不得**新编；若需强调卖点而缺数据，用定性表述并提示卖家用规格书补全。
- **中文关键词与英文正文**：默认**英文站点**描述为英文；中文关键字在稿中用对应自然英文检索词表达，并在 **Keywords coverage** 或 **Assumptions** 中一行说明对应关系。
- **成稿前自检英文词边界**：禁止出现黏词（如 `Earbudswith`、`soundwithout`）；每个英文单词之间须有应有空格。

## 核心目标

1. **埋词**：用户提供的每一条**独立关键字**（按逗号 / 换行 / 编号分项）在成稿描述中全覆盖；优先自然句内分布，避免同一句机械堆叠。
2. **精炼**：删冗余、合并重复信息；首段尽快交代「是什么、适合谁、核心好处」。
3. **特色与转化**：每段有清晰焦点（如场景、材质、兼容、使用方式）；结尾可轻量引导想象使用场景，避免违禁承诺与绝对化用语。

## 输出结构

按顺序给出：

1. **Assumptions**（可选一两句）：站点语言假设、中英文词对应、或从标题推断的类目前提。
2. **Optimized Product Description**：即上架用描述正文。
3. **Keywords coverage**：逐条列出用户关键字（含中文）在稿中的英文对应或引用片段；无争议时可写「All provided keywords integrated.」
4. **Change note**（可选一句）：相对用户原始描述，做了哪些方向的加强（如结构、埋词、去冗），**不写**长篇对比除非用户要求。

## 合规与禁忌（摘要）

- 不用「最好」「第一」「治愈」「保证治愈」等表述；不引用竞品品牌；无站外链接与联系方式。
- 标题中已有而描述中要避免直接复制整句标题；可呼应关键词但保持描述独立阅读价值。
