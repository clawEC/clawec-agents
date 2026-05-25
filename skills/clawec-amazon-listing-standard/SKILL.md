---
name: clawec-amazon-listing-standard
description: Writes Amazon marketplace listing copy in fluent, natural English with full keyword integration across title, bullets, and description to improve discoverability and conversion. Use when creating or rewriting Amazon listings, 亚马逊 listing 文案, bullet points, title/description, 埋词, or SEO keywords. Every run must output Title, Bullet Points, and Product Description in one reply unless the user explicitly requests only part; no emojis or decorative symbols in bullets; do not invent specs (battery hours, weights, certifications) not supplied by the user. 
---

# Amazon Listing 写作（标准版）

## 何时使用本技能

在用户需要**英文亚马逊 listing 文案**（标题、要点、商品描述）、强调**关键词覆盖**与**可读性**时使用。与通用上架规范技能配合：本技能聚焦**文案生成与埋词执行**，不替代类目合规与图片规范自检。

## 硬性输出要求（必须遵守）

- **三段缺一不得提交**：除非用户在当次对话中**明确声明**只要标题 / 只要要点 / 只要描述之一，否则**同一条回复内必须依次给出** **Title**、**Bullet Points**（条数按用户指定或默认 5）、**Product Description**，且描述须有实质内容（至少 2–3 个完整英文段落），不得仅用一两句话敷衍。
- **禁止 Emoji 与装饰性符号**：要点与标题、描述中**不得**使用 Emoji、颜文字、过多特殊符号（如 🔋💰、花哨框线）；用纯英文标点与句式即可。
- **禁止编造可量化规格**：用户未提供具体数字时，**不得**捏造续航小时数、承重、尺寸、认证编号等；可写定性利益（如 *reliable battery for all-day use*），并在 **Assumptions** 或句末括号内提示卖家按实拍/规格书核对后再替换为准确数据。
- **中文关键词与英文正文**：默认面向**英文站点**正文为英文。用户只给中文词（如「蓝牙耳机」）时，在英文稿中使用对应自然检索词（如 *Bluetooth earbuds*, *wireless earbuds*），并在 **Keywords coverage** 或 **Assumptions** 中用一行说明中文词与英文对应关系，确保埋词意图不丢。

## 输入项（必须先确认或请用户填写）

生成文案前，向用户确认下列字段（可在对话中逐条收集，或让用户一次性粘贴模板）：

| 字段 | 必填 | 默认 / 说明 |
|------|------|----------------|
| **商品关键词** | 是 | 核心词、长尾词、场景词等；可列表或逗号分隔。所有提供的关键词须在成稿中**可查见**（见下文「100% 埋词」规则）。 |
| **商品特性的条数** | 否 | 默认 **5** 条要点（亚马逊常见上限为 5）。若用户指定其他条数（如 3），按用户要求。 |
| **商品品牌** | 否 | 若提供，在标题与合理位置自然出现；未提供则省略或占位说明勿编造品牌。 |
| **商品类目** | 否 | 用于语调与场景词选择（如 Home、Electronics）；未提供则依据关键词推断并简短注明假设。 |
| **商品卖点** | 否 | 卖家提供的核心卖点优先写入要点与描述；未提供则从关键词与常识推断，避免夸大与违禁承诺。 |

**一键粘贴模板（可发给用户）**：

```
商品关键词（必填）：
商品特性的条数（默认 5）：
商品品牌（选填）：
商品类目（选填）：
商品卖点（选填）：
```

## 核心目标

1. **关键词埋词率**：用户给出的每一条**独立关键词**（按用户提供的最小粒度计：逗号/换行/编号分项为多条）在「标题 + 全部要点 + 描述」合计中至少出现一次；允许合理词形变化（复数、时态、常见搭配）但检索意图须一致。若某词无法自然嵌入，在输出末尾用「**Keywords coverage**」列表标注该词及其出现位置引号片段；原则上应避免标注过多——优先改写句子直至全部自然覆盖。
2. **语言**：地道、简洁的购物场景英文；避免中式直译、堆砌标点、全大写标题；符合亚马逊买家阅读习惯（好处优先；**仅在用户已提供时使用**具体数字与规格）。
3. **转化**：每条要点突出一条清晰利益；标题在前部放置最强检索词与品牌（如有）；描述补充场景与剩余关键词，不重复堆叠同句；语气偏清晰说明，避免国内种草风口号堆砌。

## 输出结构

按顺序输出，使用清晰小标题（**默认全套必选**，见上文「硬性输出要求」）：

1. **Assumptions**（可选）：类目、中英文关键词对应、或缺失规格时的假设（一两句）。
2. **Title**：单行，符合常见字符习惯（冗长类目以用户后台上限为准，倾向精炼）。
3. **Bullet Points**：编号列表，条数 = 用户指定或默认 5；每条以利益或场景开头，自然含关键词；**无 Emoji**。
4. **Product Description**：默认纯英文段落（2–3 段以上）；除非用户要求，否则不用 HTML；用于长尾场景与剩余关键词，篇幅明显长于要点区。
5. **Keywords coverage**：列出用户每条关键词（含中文词）在稿中的对应英文短语或出现位置说明；无争议时可写「All provided keywords integrated.」。

## 合规与禁忌（摘要）

- 不用「最好」「第一」「治愈」「保证疗效」等违规或绝对化表述；不引用竞品品牌。
- 不添加站外链接、联系方式、或亚马逊禁止的促销话术。
- 不确定的认证/参数不要编造；缺失规格用中性表述或提示卖家核实；**禁止**为凑卖点而虚构续航、容量、防水等级等数值。