---
name: clawec-ozon-brand-products
description: 通过 clawEC API 查询 Ozon 品牌商品销售数据（最多10个品牌）。在用户需要品牌商品销售、品牌货盘分析时使用。
---

# Ozon品牌商品销售数据

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按品牌名称查询商品销售数据（最多 10 个品牌）。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/brand/products`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| brandNames | body | 是 | 品牌名称，单次最多可传10个，多个使用英文逗号分隔 |

超过 10 个品牌时拆成多批请求。

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/brand/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"brandNames": "Nike,Adidas"}'
```

或使用脚本：

```bash
bash scripts/query.sh "Nike,Adidas"
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

1. 确认 brandNames（最多 10 个，英文逗号分隔）
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：品牌名称
- 品牌商品销售核心指标
- 给出 1–2 条货盘观察
