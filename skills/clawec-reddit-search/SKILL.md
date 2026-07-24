---
name: clawec-reddit-search
description: 通过 Clawec API 按关键词搜索 Reddit 帖子与讨论，用于社区舆情、用户需求与选品灵感调研。在用户需要 Reddit 搜索、社区话题调研、英文用户讨论、关键词舆情、subreddit 内容发现时使用。
---

# Reddit 搜索

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按关键词检索 Reddit 社区内容与讨论。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/reddit_search`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| keyword | body | 是 | 搜索关键词 |

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/reddit_search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"keyword":"wireless earbuds"}'
```

或使用脚本：

```bash
bash scripts/search.sh "wireless earbuds"
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
- `data`: 搜索结果对象或列表，字段以实际返回为准
- `extra`: 附加信息字符串（若有）
- `pointInfo`: 积分/扣点信息 `{ type, point }`

### 常见帖子字段（`data` 内，以实际返回为准）

| 字段 | 说明 |
|------|------|
| title | 帖子标题 |
| subreddit | 所属子版块 |
| score | 投票得分 |
| num_comments | 评论数 |
| url / permalink | 帖子链接 |
| created / created_utc | 发布时间 |
| author | 作者（若返回） |
| selftext / body | 正文摘要（若返回） |

完整说明见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认搜索关键词（英文或目标市场常用表述）
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. `status !== 1` 或请求失败时，说明错误并提示检查密钥与关键词
5. 解析 `data`，按用户需求整理输出

## 输出建议

默认中文摘要，包含：

- 关键词与命中概况（条数或结构说明）
- 帖子列表表：标题、子版块、得分、评论数、链接
- 选品/调研场景：归纳 2–5 条用户痛点、需求或产品提及；标注高互动帖
- 说明数据来源为 Reddit 公开讨论，需结合语境判断，勿当作销量数据

## 示例

**输入**：搜索「phone case」

**输出摘要**：

| 标题 | 子版块 | 得分 | 评论数 | 链接 |
|------|--------|------|--------|------|
| ... | r/... | ... | ... | ... |

**观察**：（摘录讨论中的需求、抱怨或推荐品类）
