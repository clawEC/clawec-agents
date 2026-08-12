---
name: clawec-shopee-item-detail
description: 通过 clawEC API 批量获取Shopee商品详情。在用户需要 Shopee商品详情、Shopee 相关数据查询时使用。
---

# Shopee商品详情

## 关于 clawEC

clawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 clawEC 开放 API，用于批量获取Shopee商品详情。


## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。


## 接口

`POST /aigc/ec/shopee/data/item/detail`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点名称：tw=台湾, my=马来西亚, id=印度尼西亚, th=泰国, ph=菲律宾, sg=新加坡, vn=越南, br=巴西 |
| itemIds | body | 是 | 商品ID，多个使用英文逗号分隔，最多10个 |
| timest | body | 否 | 查询账期，yyyy-MM-dd，只能选某一天；不传默认昨天 |

注意：`itemIds` 商品ID，多个使用英文逗号分隔，最多10个

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
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/item/detail" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site": "tw", "itemIds": "123456"}'
```

或使用脚本：

```bash
bash scripts/query.sh tw 123456
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

1. 确认 site、itemIds
2. 检查 `CLAWEC_API_KEY` 是否可用
3. 执行 API 请求
4. 失败时说明错误并提示检查密钥与关键参数
5. 解析返回数据，整理为中文摘要

## 输出建议

- 查询条件与关键参数
- Shopee商品详情核心指标摘要（以返回字段为准）
- 给出 1–2 条可行动观察
