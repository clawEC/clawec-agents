---
name: clawec-amazon-advertising
description: Plans, structures, and optimizes Amazon Sponsored Products, Sponsored Brands, and Sponsored Display campaigns—keyword strategy, match types, bidding, budgets, placement, and reporting interpretation. Use when the user mentions 亚马逊广告投放, Amazon PPC, Sponsored Ads, SP/SB/SD, 广告优化, ACOS/TACOS, 关键词投放, or Seller Central/Vendor advertising. Outputs are operational guidance and copy/structure suggestions; the agent does not fabricate account metrics or guarantee performance. Default output 中文 unless the user requests English.
---

# 亚马逊广告投放

## 何时使用本技能

在用户需要**规划或优化亚马逊站内付费广告**（Seller Central / Advertising Console / DSP 入门层面的策略讨论）时：包括**广告类型选择、关键词与匹配方式、出价与预算、投放位、否定词、结构拆分、报表读法、常见异常排查**等。本技能提供**可执行的框架与文案/结构建议**，不替代后台实际数据与 A/B 验证。

## 输入项（按需收集）

| 字段 | 必填 | 说明 |
|------|------|------|
| **站点与业务模式** | 建议 | 如美国 FBA、欧洲多站点、Vendor 等。 |
| **类目与 SKU/ASIN** | 建议 | 新品/老品、是否多变体。 |
| **当前目标** | 建议 | 拉新、利润、清库存、冲排名、防御品牌词等（可并存，需标优先级）。 |
| **已知约束** | 可选 | 日预算、目标 ACOS/TACOS 区间、库存与利润率底线。 |
| **已有数据** | 可选 | 近 7/14/30 天搜索词报告、广告位、转化摘要（可粘贴摘要，勿泄露完整账号密钥）。 |

若信息不全，先列出**假设**并给出**最小可行行动**，再说明需补哪些数据。

## 核心能力范围

1. **广告类型**：Sponsored Products、Sponsored Brands（含 Store 落地）、Sponsored Display（再营销/受众类）的**典型适用场景与组合**。
2. **关键词与结构**：自动/手动、广泛/词组/精确、**否定关键词**分层；SKU 级与广告组级拆分的利弊。
3. **出价与预算**：动态出价策略选择思路、placement bid 调整逻辑、预算耗尽与曝光异常的**排查顺序**。
4. **创意与落地**：标题/品牌素材要点（合规：不夸大、不违规承诺）；Listing 与广告一致性的检查点。
5. **指标**：ACOS、TACOS、CPC、CTR、CVR、NTB 等**如何联动解读**（定性，不编造具体行业基准数字）。

## 硬性输出要求

- **禁止编造**账号内的花费、销售额、排名、市场份额等；无数据时写「需从广告报告导出验证」。
- **结构化输出**，建议包含：目标与优先级 → 推荐结构草图 → 关键词/否定词策略 → 出价与预算建议 → 监控节奏（如日/周检项）→ 风险与合规提醒。
- **无 Emoji**（除非用户明确要求）。

## 合规与禁忌

- 不指导规避平台政策、操纵点击或虚假转化。
- 健康、金融、儿童等敏感类目避免绝对化功效与不当表述；广告素材须符合站点与类目政策。
