---
name: clawec-amazon-report-hijacker
description: Drafts professional Amazon Seller Central case messages to report unauthorized sellers or listing violations commonly referred to as 跟卖, addressed to Seller Support with store name and ASIN. Use for 举报跟卖, 跟卖投诉, hijacker report, unauthorized seller, listing infringement case, or Seller Support escalation when policy allows. Output is template text only; Amazon decides based on policy, Brand Registry tools, and evidence. Agent must not encourage false reports, competitor harassment, or forged proof.
---

# 举报跟卖邮件（Seller Support 案例稿）

## 何时使用本技能

在卖家拟通过 **Amazon Seller Central → Seller Support / 适用举报入口** 就**特定 ASIN 上的跟卖/未经授权销售等行为**提交说明时使用（具体可走的路径以账户权限、是否 Brand Registry、问题类型为准）。本技能只生成**英文案例正文与主题草稿**（亚马逊全球支持常用英文）；**不保证**下架或处罚结果。

## 输入项（与表单一致，两项均必填）

| 字段 | 必填 | 说明 |
|------|------|------|
| **跟卖者的店铺名** | 是 | Listing 上显示的卖家名称或店铺标识（与用户截图一致）；若有多名跟卖，可分条描述或让用户分次生成。 |
| **ASIN** | 是 | 被跟卖的商品 ASIN（B0 开头等格式）；一信一案可只写一个 ASIN，多个 ASIN 在正文中编号列出。 |

**一键粘贴模板**：

```
跟卖者的店铺名（必填）：
ASIN（必填）：
```

## 核心原则

1. **事实与政策**：仅基于用户提供的**真实信息**撰写；陈述可验证项（ASIN、卖家显示名、观察到的 offers 情况），避免辱骂与无证指控（如「必是假货」若无依据请改为「请求依政策核查」）。
2. **渠道提示**：不同情形可能对应 **Report a Violation、Brand Registry、Project Zero、Transparency** 等工具；若仅适用 Seller Support Case，正文保持**一案一焦点**，附件与证据类型在 checklist 中列出。
3. **合规边界**：滥用举报可能导致**己方账户风险**；不在稿中教唆捏造销量损失、伪造聊天记录或冒充权利。

## 硬性输出要求

同一回复内按顺序给出：

1. **Routing note**（简短）：根据用户是否提到品牌备案/商标，提示应优先核对的**官方入口**；若信息不足，写「需用户自扫路径」而非瞎编。
2. **Case title / Subject**（英文）：简洁含 ASIN 关键词。
3. **Case body**（英文）：可粘贴至 Seller Support 的正文—含礼貌开头、ASIN、跟卖者店铺名、时间线占位、已采取措施、请求平台动作、附件说明占位。
4. **Evidence checklist**：建议准备的截图/订单号/品牌证书等（用户脱敏后上传）。
5. **中文操作摘要**（3–6 句）：团队内部用，说明草稿用途与限制。
6. **无 Emoji**；句中可用 `[ORDER_ID]`、`[DATE_FIRST_NOTICED]` 等占位符补全用户未填项。

## 合规与禁忌

- **禁止虚假举报**、打击竞品、无权利基础却声称侵权。  
- 不保证「删跟卖」话术；不写违法威胁第三方内容。