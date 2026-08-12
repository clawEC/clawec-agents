---
name: clawec-shopee-item-search
description: 通过 clawEC API 查询Shopee商品列表。在用户需要 Shopee商品搜索、Shopee 相关数据查询时使用。
---

# Shopee商品搜索

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于查询Shopee商品列表。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/shopee/data/item/search`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点名称：tw=台湾, my=马来西亚, id=印度尼西亚, th=泰国, ph=菲律宾, sg=新加坡, vn=越南, br=巴西；默认 `tw` |
| categoryId | body | 是 | 类目ID。一级类目对照：100001=保健, 100009=时尚配饰, 100010=家用电器, 100011=男装服饰, 100012=男士鞋, 100013=手机平板与配件, 100015=旅行&行李箱, 100016=女士包, …；默认 `100001` |
| productType | body | 否 | 产品类型：1=虾皮优选 2=虾皮商城 3=其他 0=全部（默认0）；默认 `0` |
| isBorder | body | 否 | 地点：1=本土 2=跨境 0=全部（默认0）；默认 `0` |
| ctimeStart | body | 否 | 上架时间范围-开始，yyyy-MM-dd；默认 `2025-01-01` |
| ctimeEnd | body | 否 | 上架时间范围-结束，yyyy-MM-dd；默认 `2026-05-27` |
| sales30dayMin | body | 否 | 近30天销量范围-最小值；默认 `100` |
| sales30dayMax | body | 否 | 近30天销量范围-最大值；默认 `10000` |
| gmv30dayMin | body | 否 | 近30天销售额范围-最小值；默认 `1000` |
| gmv30dayMax | body | 否 | 近30天销售额范围-最大值；默认 `100000` |
| priceMin | body | 否 | 价格范围-最小值；默认 `10` |
| priceMax | body | 否 | 价格范围-最大值；默认 `1000` |
| sortType | body | 否 | 排序维度：1=近30天销量 2=近30天销售额 3=价格（默认1）；默认 `1` |
| sortOrder | body | 否 | 排序方向：asc=升序 desc=降序（默认desc）；默认 `desc` |
| timest | body | 否 | 查询账期，yyyy-MM-dd，只能选某一天；不传默认昨天；默认 `2026-07-13` |
| pageNo | body | 否 | 分页页码，从1开始，最大100000；不传默认1；默认 `1` |
| pageSize | body | 否 | 分页大小，最大10；不传默认10；默认 `10` |

### site / sites 取值

| 代码 | 站点 |
|------|------|
| tw | 台湾 |
| my | 马来西亚 |
| id | 印度尼西亚 |
| th | 泰国 |
| ph | 菲律宾 |
| sg | 新加坡 |
| vn | 越南 |
| br | 巴西 |

`sites` 为多选站点列表时，传 JSON 数组字符串，例如 `["tw","my"]`。


## 调用

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/search" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site": "tw", "categoryId": "100001", "productType": "0", "isBorder": "0", "ctimeStart": "2025-01-01", "ctimeEnd": "2026-05-27", "sales30dayMin": "100", "sales30dayMax": "10000", "gmv30dayMin": "1000", "gmv30dayMax": "100000", "priceMin": "10", "priceMax": "1000", "sortType": "1", "sortOrder": "desc", "timest": "2026-07-13", "pageNo": "1", "pageSize": "10"}'
```

筛选参数较多时，推荐直接传 JSON body（或 `@payload.json`）。
或使用脚本：

```bash
bash scripts/query.sh '{"site": "tw", "categoryId": "100001", "productType": "0", "isBorder": "0", "ctimeStart": "2025-01-01", "ctimeEnd": "2026-05-27", "sales30dayMin": "100", "sales30dayMax": "10000", "gmv30dayMin": "1000", "gmv30dayMax": "100000", "priceMin": "10", "priceMax": "1000", "sortType": "1", "sortOrder": "desc", "timest": "2026-07-13", "pageNo": "1", "pageSize": "10"}'

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

1. 确认 site、categoryId；参数较多时用 JSON 传入
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件与关键参数
- Shopee商品搜索核心指标摘要（以返回字段为准）
- 给出 1–2 条可行动观察
