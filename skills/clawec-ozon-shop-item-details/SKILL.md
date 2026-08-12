---
name: clawec-ozon-shop-item-details
description: 通过 clawEC API 查询 Ozon 店铺商品明细。在用户需要店铺货盘、店铺商品列表时使用。
---

# Ozon店铺商品明细

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于按店铺名称或 ID 查询店铺商品明细。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/ozon/data/shop/item-details`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| pageNo | body | 否 | 分页页码，从1开始，最大10000；不传默认1；默认 `1` |
| pageSize | body | 否 | 分页大小，最大15；不传默认15；默认 `15` |
| shopKeyword | body | 是 | 店铺名称或ID。支持按店铺名称或店铺ID查询 |
| categoryId | body | 否 | 一级类目ID。0 或不传表示全部类目。对照：17027494=住宅和花园, 17027491=运动与休闲, 17027489=美容和卫生, 15621032=鞋类, 15621031=服装, 17027915=家具, 17027486…；默认 `0` |


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/ozon/data/shop/item-details" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"shopKeyword": "123456", "pageNo": "1", "pageSize": "15", "categoryId": "0"}'
```

或使用脚本：

```bash
bash scripts/query.sh 123456 1 15 0
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

1. 确认 shopKeyword；可选 pageNo、pageSize、categoryId
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：店铺、类目、分页
- 商品列表明细摘要
- 给出 1–2 条货盘观察
