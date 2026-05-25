---
name: clawec-amazon-title-optimize
description: Optimizes Amazon product titles and product descriptions for high-relevance core and high-volume search terms, strong keyword coverage, and clearer ranking signals while keeping copy concise and uniqueness-focused. Use for 亚马逊标题优化, title SEO, 核心热词, 埋词, listing title and description rewrite, or search ranking-oriented copy. No emojis; do not invent numeric specs, sizes, or certifications; default English marketplace; map Chinese keywords to natural English phrases; verify no sticky English words before delivery.
---

# 亚马逊标题优化

## 何时使用本技能

在用户仅需提供**商品核心关键词**、却要同时得到**高相关热词布局**与**高埋词率**的**标题 + 商品描述**时使用：语言简洁、突出差异化与检索意图，服务于搜索可见度与点击率（具体排名受平台算法与运营多因素影响，文案侧只做合规优化）。

## 输入项（与表单一致）

| 字段 | 必填 | 说明 |
|------|------|------|
| **商品的核心关键词** | 是 | 一条或多条核心词、品类词、场景词（列表、逗号或换行分隔均可）。标题与描述须**全覆盖**这些词的最小粒度条目（允许词形与常见搭配变化，检索意图一致）。 |

**一键粘贴模板**：

```
商品的核心关键词（必填）：
```

当用户只填关键词、无 SKU 细节时，**不得**编造续航、尺寸、认证等数字；可用中性差异化表述（如设计取向、典型使用场景）并在 **Assumptions** 中标明「仅基于关键词推断，卖家需用实拍与规格书替换」。

## 硬性输出要求（必须遵守）

- **同一回复内必须包含**：**Optimized Title**（一行或平台允许的主标题形态）+ **Optimized Product Description**（默认 **2–4 段**英文正文，精炼、可扫读），除非用户**明确声明**只要其中一项。
- **标题**：靠前放置最强检索与品类信号；控制冗余连接词与重复堆词；符合常见大小写习惯；避免全大写与非常规符号堆砌。
- **描述**：补充长尾与场景，与标题**关键词互补**（避免整句复制标题）；突出简洁的**独特卖点**（从关键词与合理场景推断，不写虚假参数）。
- **禁止 Emoji 与装饰性符号**；**成稿前自检英文词边界**，禁止黏词（如 `Earbudswith`）。
- **中文核心词**：默认产出**英文**标题与描述；在 **Assumptions** 或 **Keywords coverage** 中说明中文词与英文检索短句的对应。

## 核心目标

1. **高相关核心 / 热词**：在标题前部与描述首段优先安置品类与意图最强的词；次要词自然落入描述。
2. **高埋词率**：用户给出的每条独立核心词在「标题 + 描述」合计中至少出现一次；优先改写句子直至自然纳入。
3. **简洁与独特性**：句子短、信息密度高；用差异化角度（人群、场景、解决了什么痛点）区分同质化品类，避免空洞形容词堆叠。

## 输出结构

按顺序给出：

1. **Assumptions**（建议保留）：基于关键词推断的品类、人群或站点假设；若缺实物规格，注明待卖家核实项。
2. **Optimized Title**
3. **Optimized Product Description**
4. **Keywords coverage**：逐条对应用户核心词（含中文）在稿中的英文表达或位置说明；全覆盖时可写「All provided keywords integrated.」

## 合规与禁忌（摘要）

- 禁用「最好」「第一」「100% cure」等违规或绝对化表述；不插入竞品品牌、外链与联系方式。
- 不为埋词而加入未经验证的认证、具体电量/防水等级等数字。
