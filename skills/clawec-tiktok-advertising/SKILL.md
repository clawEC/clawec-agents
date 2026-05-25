---
name: clawec-tiktok-advertising
description: Structures TikTok for Business campaigns—objectives, placements, audiences, creative formats (In-Feed, Spark Ads, etc.), bidding, budgets, and measurement hooks. Use when the user mentions TikTok广告投放, TikTok Ads Manager, 信息流广告, Spark Ads, 达人合作引流, or TikTok Shop ad scenarios at a planning level. Outputs are campaign architecture and creative/testing guidance; does not fabricate CPM/CVR benchmarks or account results. Default output 中文 unless the user requests English.
---

# TikTok 广告投放

## 何时使用本技能

在用户需要**规划或优化 TikTok 商业广告**（TikTok Ads Manager、信息流、Spark Ads、品牌挑战等层面的策略）时：包括**营销目标与事件映射、版位与受众、创意节奏与钩子、测试矩阵、预算分配、学习期与扩量思路**。本技能侧重**结构与方法论**；具体像素/事件、Shop 政策细节以官方文档与账户实际配置为准。

## 输入项（按需收集）

| 字段 | 必填 | 说明 |
|------|------|------|
| **推广目的** | 建议 | 认知、流量、应用安装、线索、转化、店铺成交等。 |
| **市场与语言** | 建议 | 投放国家/地区、素材语言与本地化程度。 |
| **产品与落地** | 建议 | 独立站、应用商店、TikTok Shop、表单等；落地页速度与移动端体验。 |
| **素材与达人** | 可选 | 是否有 UGC/达人授权（Spark）、现有视频条数与风格。 |
| **约束** | 可选 | 日预算、CPA/ROAS 目标区间、品牌调性禁区。 |

## 核心能力范围

1. **目标与事件**：从业务目标反推**可优化事件**（浏览、加购、购买等）及数据回传注意点（定性）。
2. **受众与定向**：兴趣/行为/自定义受众/相似受众的**典型用法**；冷启动与再营销分层。
3. **创意**：前 3 秒钩子、原生感、竖屏安全区、**创意疲劳**与迭代节奏；A/B 测试维度（钩子、字幕、CTA、时长）。
4. **Campaign 结构**：预算集中 vs 拆分测试、广告组变量控制、学习期内的**少动原则**与何时重置判断（原则性描述）。
5. **合规**：行业限制、敏感内容、音乐版权与素材授权提示（不替代法务审核）。

## 硬性输出要求

- **禁止编造**行业平均 CPM、点击率、转化率或竞品投放数据；可写「需以账户实测为准」。
- **结构化输出**：目标 → 推荐结构（Campaign/Ad Group/Ad）→ 受众与版位建议 → 创意与测试计划 → 预算与扩量节奏 → 监控指标清单。
- **无 Emoji**（除非用户明确要求）。

## 合规与禁忌

- 不指导伪造互动、买量作弊或绕过平台审核。
- 涉及医疗、金融、博彩等受限行业时提示**前置审核与本地化资质**，避免绝对承诺式文案。
