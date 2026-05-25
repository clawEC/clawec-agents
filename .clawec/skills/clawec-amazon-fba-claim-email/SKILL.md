---
name: clawec-amazon-fba-claim-email
description: Drafts factual, professional FBA reimbursement and seller-support case messages from an order-issue narrative to help sellers pursue rightful claims within Amazon policy. Use for FBA索赔邮件, FBA reimbursement email, 库存赔偿, 丢失货件, 损坏理赔, 少件, 错发, Seller Central case copy, or 保障店铺利益 when opening or replying to Amazon support. Outputs are draft wording only; success depends on policy, evidence, and Amazon decision; agent must not encourage false claims or forged documents. Default case message in English (Amazon global support); optional 中文摘要 if user needs internal handoff.
---

# FBA 索赔邮件

## 何时使用本技能

在卖家需要通过**卖家中心 Case / 邮件类沟通**就 **FBA 相关问题**（如丢件、货损、入库差异、错发少发、与平台政策相符的赔偿诉求等）提交**清晰、可核查**的说明时使用。本技能产出**草稿文本**，**不保证**批准或金额；最终以前台政策与审核为准。

## 输入项（与表单一致）

| 字段 | 必填 | 说明 |
|------|------|------|
| **订单问题描述** | 是 | 应用**事实**陈述：发生了什么、大致时间、数量或金额、已采取的步骤、手头凭证类型（跟踪号、签收、照片、装箱单等）。信息不足时在草稿中用 `[待填写：…]` 占位并列出待补材料。 |

**一键粘贴模板**：

```
订单问题描述（必填）：
```

## 核心原则

1. **冷静、客观、可扫描**：首段一句话概括诉求；下列时间线或编号事实；避免辱骂、情绪化与无根据指控。
2. **对齐渠道**：不同问题走 **Inventory / Reimbursements / Shipments / Orders** 等路径—若用户提供线索则点名 case 类型；否则在 **Routing note** 中提示核对 Seller Central 当前入口。
3. **诉求明确**：一句话写清期望结果（如按政策调查、补赔、更正库存），不编造平台未承诺的「必须赔款××美金」。
4. **诚信边界**：仅基于用户描述组织语言；**不虚构**破损、丢失或未发生的损失；若描述含糊，标注需核实项而非帮编假情节。

## 硬性输出要求

同一回复内按顺序给出：

1. **Assumptions & gaps**：从描述中推断的案件类型；**尚缺**的订单号/FNSKU/shipment ID/日期等（用占位符列出）。
2. **Case title / Subject line**（英文，简洁）：适合粘贴为 case 标题或邮件主题。
3. **Case body**（英文正文）：分段完整草稿，可直接粘贴到 Seller Central；含礼貌开头、事实、附件列表、请求动作、案号引用占位 `[CASE_ID若已有]`。
4. **附件清单（Checklist）**：建议随案提交的文件/截图类型（用户自行脱敏）。
5. **中文摘要**（可选 3–6 句）：便于团队内部留档，**不替代**提交给亚马逊的英文正文。
6. **无 Emoji**；不承诺「一定成功」。

若用户明确要求**仅用中文**写给第三方工具翻译，可改为主交付中文稿并附「建议译回英文再提交」提示。

## 合规与禁忌

- 不指导伪造记录、重复索赔已结案项目、或利用政策漏洞欺诈。
- 不包含客户隐私（买家姓名地址等）在可传播的示例中；用户输入若含隐私，正文概括化。