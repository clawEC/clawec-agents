---
name: clawec-ozon-product-traffic-keywords
description: 通过 clawEC API 查询 Ozon 商品流量词。在用户需要商品流量词、自然/广告词分析时使用。
---

# Ozon商品流量词查询

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按商品 ID 查询流量词（最多 10 个商品）。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/product/traffic-keywords`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| pageNo | body | 否 | 分页页码，从1开始，最大10000；不传默认1；默认 `1` |
| pageSize | body | 否 | 分页大小，最大15；不传默认15；默认 `15` |
| itemIds | body | 是 | 商品ID。最多可传10个，多个使用英文逗号分隔 |
| keywordType | body | 否 | 关键词类型：全部(ALL)、主题标签(THEME_TAG)、自然流量(NATURAL)、广告流量(AD_CPC)、订单广告(AD_ORDER)、特殊广告(AD_SPECIAL)；默认 `ALL` |
| keyword | body | 否 | 关键词俄文或中文，支持模糊查询 |
| sortField | body | 否 | 排序字段，默认 SEARCH_INDEX。SEARCH_INDEX=搜索指数, SEARCH_INDEX_GROWTH_RATE=搜索指数增长率, CONVERSION_INDEX=转化指数, CART_CONVERSION_RATE…；默认 `SEARCH_INDEX` |
| sortDirection | body | 否 | 排序方向，默认 DESC；默认 `DESC` |

超过 10 个商品 ID 时拆成多批请求。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/product/traffic-keywords" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"itemIds": "123456789", "pageNo": "1", "pageSize": "15", "keywordType": "ALL", "sortField": "SEARCH_INDEX", "sortDirection": "DESC"}'
```

或使用脚本：

```bash
bash scripts/query.sh 123456789 1 15 ALL "" SEARCH_INDEX DESC
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

1. 确认 itemIds（最多 10 个）；可选分页、keywordType、keyword、排序
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：商品 ID、词类型、分页
- 流量词列表与核心指数
- 给出 1–2 条词库观察
