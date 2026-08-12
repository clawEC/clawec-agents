---
name: clawec-tiktok-market-category-analysis
description: 通过 clawEC API Tiktok类目市场分析 判断类目规模、竞争度、是否值得进入。在用户需要 Tiktok类目市场分析、TikTok 相关数据查询时使用。
---

# Tiktok类目市场分析

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于Tiktok类目市场分析 判断类目规模、竞争度、是否值得进入。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/tiktok/data/market/category_analysis`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| analysisType | body | 是 | 分析类型：basic_metrics=基础指标，sales_trends=销售趋势，price_distribution=价格分布 |
| region | body | 是 | 目标市场/国家码，如 US、UK、ID、VN、TH、MY、PH、SG |
| categoryId | body | 否 | 一级类目ID。对照：10=家居用品, 11=厨房用品, 12=纺织品与软装, 13=家用电器, 3=男装与内衣, 2=女装与内衣, 6=鞋类, 7=箱包, 14=美容与个护, 15=电脑与办公设备, 16=手机与电子产品, 18=母婴… |
| categoryPath | body | 否 | 类目路径，一级到三级，如 [100,200,300] |

### region 常用取值

| 代码 | 市场 |
|------|------|
| US | 美国 |
| UK | 英国 |
| ID | 印尼 |
| VN | 越南 |
| TH | 泰国 |
| MY | 马来西亚 |
| PH | 菲律宾 |
| SG | 新加坡 |


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/tiktok/data/market/category_analysis" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"analysisType": "basic_metrics", "region": "US"}'
```

或使用脚本：

```bash
bash scripts/query.sh basic_metrics US
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

1. 确认 analysisType、region
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件与关键参数
- Tiktok类目市场分析核心指标摘要（以返回字段为准）
- 给出 1–2 条可行动观察
