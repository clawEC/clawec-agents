---
name: clawec-amazon-asin-comment-query
description: 通过 Clawec API 按 ASIN 或商品链接查询亚马逊商品评论。在用户需要亚马逊评论分析、ASIN 评论抓取、差评调研、Review 分析、买家反馈洞察时使用。
---

# 亚马逊 ASIN 评论查询

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按 ASIN 或商品 URL 获取亚马逊商品评论数据。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/tool/amazon_asin_comment_query`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| url | body | 否* | 商品链接；有 `url` 时可不传 `asin`、`region` |
| asin | body | 否* | 商品 ASIN；无 `url` 时与 `region` 一起使用（由 API 拼接链接） |
| region | body | 否* | 站点区域代码（2 位大写字母）；有 `url` 时可不传 |

\* 必须提供 `url`，或同时提供 `asin` + `region`。

### region 取值

| 代码 | 站点 |
|------|------|
| NA | 北美（美国） |
| CA | 加拿大 |
| BR | 巴西 |
| UK | 英国 |
| DE | 德国 |
| FR | 法国 |
| JP | 日本 |
| SG | 新加坡 |
| AU | 澳大利亚 |

未指定 `region` 且使用 ASIN 查询时默认 `NA`。

## 调用

**按商品链接：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/tool/amazon_asin_comment_query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"url":"https://www.amazon.com/dp/B0XXXXXXXX"}'
```

**按 ASIN + 站点：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/tool/amazon_asin_comment_query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"asin":"B0XXXXXXXX","region":"NA"}'
```

或使用脚本：

```bash
# 商品链接
bash scripts/query.sh "https://www.amazon.com/dp/B0XXXXXXXX"

# ASIN + 区域（默认 NA）
bash scripts/query.sh B0XXXXXXXX NA
```

## 响应结构

```json
{
  "status": 1,
  "data": { ... }
}
```

- `status`: `1` = 成功，`0` = 失败
- `data`: 评论数据对象或列表，字段以实际返回为准

完整说明见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认查询方式：商品 `url`，或 `asin` + `region`
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. `status !== 1` 或请求失败时，说明错误并提示检查密钥、ASIN/链接与站点
5. 解析 `data`（若为嵌套结构，展开评论列表），按用户需求整理输出

## 输出建议

默认中文摘要，包含：

- 查询目标（ASIN / 链接）与站点
- 评论总量与星级分布（若 `data` 含统计字段）
- 评论列表表：星级、标题、正文摘要、日期、是否 Verified Purchase、有帮助数等（以实际字段为准）
- 分析场景：归纳高频好评/差评主题各 2–3 条，并标注可改进点

## 示例

**输入**：北美站 ASIN `B0D1XD1ZV3` 的评论

**输出摘要**：

| 星级 | 标题 | 摘要 | 日期 |
|------|------|------|------|
| 5 | ... | ... | ... |
| 1 | ... | ... | ... |

（其余字段与统计按 API 返回的 `data` 动态展示。）
