---
name: clawec-google-trend
description: 通过 Clawec API 查询 Google Trends 关键词搜索热度与趋势，支持多词对比与按国家/地区筛选。在用户需要谷歌趋势、搜索热度对比、市场兴趣变化、关键词趋势调研、选品前需求验证时使用。
---

# 谷歌趋势

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于查询 Google Trends 关键词兴趣趋势。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/google_trend`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| keyword | body | 是 | 关键词；多个词用**英文逗号**分隔，如 `phone case,phone holder` |
| region | body | 否 | 地区，ISO 3166-1 alpha-2 两位大写国家代码（见下表） |

### region 常用取值

| 代码 | 市场 |
|------|------|
| US | 美国 |
| UK | 英国 |
| JP | 日本 |
| DE | 德国 |
| FR | 法国 |
| IT | 意大利 |
| ES | 西班牙 |
| CA | 加拿大 |

理论上支持 Google Trends 覆盖的全部国家/地区，使用标准两位大写代码。未指定 `region` 时由 API 按默认范围返回（以实际行为为准）。

## 调用

**单词 + 美国：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/google_trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"keyword":"wireless earbuds","region":"US"}'
```

**多词对比：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/google_trend" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"keyword":"phone case,phone holder","region":"US"}'
```

或使用脚本：

```bash
# 关键词 + 地区（默认 US）
bash scripts/query.sh "wireless earbuds" US

# 多词对比（逗号分隔，脚本内原样传入 keyword）
bash scripts/query.sh "phone case,phone holder" UK
```

## 响应结构

```json
{
  "status": 1,
  "code": 0,
  "msg": "",
  "data": { ... },
  "extra": "",
  "pointInfo": { "type": 0, "point": 0 }
}
```

- `status`: `1` = 成功，`0` = 失败
- `code` / `msg`: 业务状态码与说明（以实际返回为准）
- `data`: 趋势数据对象，字段以实际返回为准
- `extra`: 附加信息字符串（若有）
- `pointInfo`: 积分/扣点信息 `{ type, point }`

### 常见趋势字段（`data` 内，以实际返回为准）

| 字段 | 说明 |
|------|------|
| keyword / keywords | 查询词或词列表 |
| region | 地区代码 |
| timeline / interest_over_time | 时间序列兴趣指数 |
| related_queries | 相关搜索（上升/热门） |
| related_topics | 相关主题 |
| averages / comparison | 多词对比时的相对热度 |

完整说明见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认关键词（单词或多词逗号分隔）与目标 `region`
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. `status !== 1` 或请求失败时，说明错误并提示检查密钥、关键词格式与地区代码
5. 解析 `data`，对比多词趋势并给出中文解读

## 输出建议

默认中文摘要，包含：

- 查询关键词、地区、时间范围（若 `data` 含时间轴）
- **趋势概览**：各词相对热度、近期升降（结合时间序列）
- **多词对比**：指出当前更高/更稳的词及可能原因（季节性、品类差异等）
- **相关发现**：摘录 `related_queries` / `related_topics` 中有选品价值的词
- 选品场景：2–5 条可行动观察；说明趋势为搜索兴趣而非销量

## 示例

**输入**：美国市场对比 `phone case` 与 `phone holder`

**输出摘要**：

| 关键词 | 近期趋势 | 相对热度 | 备注 |
|--------|----------|----------|------|
| phone case | 平稳略升 | 较高 | ... |
| phone holder | 季节性波动 | 较低 | ... |

**相关搜索（示例）**：…

**观察**：（结合趋势与相关词给出选品建议）
