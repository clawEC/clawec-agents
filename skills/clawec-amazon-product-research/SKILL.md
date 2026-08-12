---
name: clawec-amazon-product-research
description: 通过 clawEC API 按销量、BSR、价格等多维条件筛选亚马逊商品。在用户需要亚马逊选品分析、商品调研、product research 时使用。
---

# 亚马逊选品分析

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于根据销量、销额、BSR、价格、评分等多维度条件筛选亚马逊商品。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/amazon/data/product/research`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| marketplace | body | 是 | 市场编码 US=美国 UK=英国 ES=西班牙 FR=法国 DE=德国 IT=意大利 CA=加拿大 JP=日本 |
| month | body | 否 | 查询月份，格式yyyyMM，示例：202507 |
| keyword | body | 否 | 关键字 |
| includeSellers | body | 否 | 包含卖家 |
| excludeSellers | body | 否 | 排除卖家 |
| matchType | body | 否 | 匹配方式，1词组匹配 2模糊匹配 3精准匹配，默认2 |
| excludeKeywords | body | 否 | 排除的关键字 |
| minPrice | body | 否 | 最低价格 |
| maxPrice | body | 否 | 最高价格 |
| minRating | body | 否 | 最低评分值 |
| maxRating | body | 否 | 最高评分值 |
| minRatings | body | 否 | 最低评分数 |
| maxRatings | body | 否 | 最高评分数 |
| minRatingsCv | body | 否 | 最低月新增评分数 |
| maxRatingsCv | body | 否 | 最高月新增评分数 |
| minSellers | body | 否 | 最小卖家数量 |
| maxSellers | body | 否 | 最大卖家数量 |
| minProfit | body | 否 | 最小毛利率 |
| maxProfit | body | 否 | 最大毛利率 |
| minBsr | body | 否 | 大类BSR最高排名 |
| maxBsr | body | 否 | 大类BSR最低排名 |
| minBsrCv | body | 否 | BSR最低增长数 |
| maxBsrCv | body | 否 | BSR最高增长数 |
| minBsrCr | body | 否 | BSR最低增长率 |
| maxBsrCr | body | 否 | BSR最高增长率 |
| minUnits | body | 否 | 最低月销量 |
| maxUnits | body | 否 | 最高月销量 |
| minAmzUnit | body | 否 | 最低月子体销量 |
| maxAmzUnit | body | 否 | 最高月子体销量 |
| minRevenue | body | 否 | 最低月销售额 |
| maxRevenue | body | 否 | 最高月销售额 |
| minRevenueCr | body | 否 | 月销售额最低增长率 |
| maxRevenueCr | body | 否 | 月销售额最高增长率 |
| minUnitsCr | body | 否 | 月销量最低增长率 |
| maxUnitsCr | body | 否 | 月销量最高增长率 |
| weightUnit | body | 否 | 重量单位，默认g |
| minWeights | body | 否 | 最小重量 |
| maxWeights | body | 否 | 最大重量 |
| minVariations | body | 否 | 最低变体数 |
| maxVariations | body | 否 | 最高变体数 |
| filterSub | body | 否 | 是否筛选子类目，Y：是，只有在指定类目时才会生效 |
| minSubBsrRank | body | 否 | 最小子类排名，只有filterSub=Y时才生效 |
| maxSubBsrRank | body | 否 | 最大子类排名，只有filterSub=Y时才生效 |
| includeBrands | body | 否 | 包含品牌 |
| excludeBrands | body | 否 | 排除品牌 |
| nodeIdPaths | body | 否 | 类目节点 nodeIdPath 列表。类目节点 id 路径，格式为 父节点ID:子节点ID。   家电-家电保修：2619525011:2242350011 家电-洗碗机：2619525011:3741271 家电-垃圾处理机：261… |
| nodeIdPathEqual | body | 否 | true为类目精确查询 false为查询当前及子类目，默认false |
| availableMonth | body | 否 | 上架月份 |
| dimensionType | body | 否 | 尺寸类型集合，逗号分隔 |
| minFba | body | 否 | FBA最低运费 |
| maxFba | body | 否 | FBA最高运费 |
| minLqs | body | 否 | 最低Listing页面质量分 |
| maxLqs | body | 否 | 最高Listing页面质量分 |
| sellerNation | body | 否 | 卖家所属地，多条件查询用逗号隔开 |
| badgeBS | body | 否 | 是否有热销标识Best Seller，Y：是 |
| badgeAC | body | 否 | 是否有热销标识Amazon's Choice，Y：是 |
| badgeNR | body | 否 | 是否有新品标识New Release，Y：是 |
| fulfillment | body | 否 | 配送方式，多条件查询用逗号隔开，AMZ/FBA/FBM |
| variation | body | 否 | 是否查询变体asin，N:含变体 Y:不含变体 |
| page | body | 否 | 页码，从1开始，默认1 |
| size | body | 否 | 每页条数，默认50，最大100 |
| order | body | 否 | 排序 |


### marketplace 取值

| 代码 | 市场 |
|------|------|
| US | 美国 |
| UK | 英国 |
| ES | 西班牙 |
| FR | 法国 |
| DE | 德国 |
| IT | 意大利 |
| CA | 加拿大 |
| JP | 日本 |

## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/amazon/data/product/research" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"marketplace": "US", "month": "202507", "keyword": "wireless earbuds", "page": "1", "size": "50"}'
```

筛选参数较多时，推荐直接传 JSON body（或 `@payload.json`）。
或使用脚本：

```bash
bash scripts/query.sh '{"marketplace":"US","month":"202507","keyword":"wireless earbuds","page":"1","size":"50"}'

bash scripts/query.sh @payload.json
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

1. 确认 marketplace（必填）及其他筛选条件；参数较多时用 JSON 传入
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件：市场与主要筛选条件
- 商品列表核心字段：价格、评分、销量、销额、BSR、品牌等
- 给出 2–3 条选品机会观察
