---
name: clawec-ozon-category-trend-snapshots
description: 通过 clawEC API 查询 Ozon 类目趋势快照。在用户需要 Ozon 类目趋势、类目快照分析时使用。
---

# Ozon类目趋势快照

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按一级类目 ID 查询类目趋势快照。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/category/trend-snapshots`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| categoryId | body | 是 | 一级类目ID。对照：17027494=住宅和花园, 17027491=运动与休闲, 17027489=美容和卫生, 15621032=鞋类, 15621031=服装, 17027486=家用电器, 17027482=建筑和装修, 15… |


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/category/trend-snapshots" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"categoryId": "15621042"}'
```

或使用脚本：

```bash
bash scripts/query.sh 15621042
```

## 响应结构

```json
{
  "status": 1,
  "data": { ... }
}
```

- `status`: `1` = 成功，`0` = 失败
- 成功时解析 `data` 按用户需求整理为中文摘要即可（无需卡片组件）


## 工作流程

1. 确认 categoryId（一级类目 ID）
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：类目 ID
- 类目趋势核心指标摘要
- 给出 1–2 条类目观察
