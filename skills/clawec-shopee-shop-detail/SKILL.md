---
name: clawec-shopee-shop-detail
description: 通过 Clawec API 批量查询 Shopee 店铺详情（最多10个店铺ID，含销量销售额、动销率、粉丝、主营类目等）。在用户需要虾皮店铺详情、竞店分析、批量查店时使用。
---

# Shopee 店铺详情

## 关于 ClawEC

ClawEC 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

本技能调用 ClawEC 开放 API，用于按站点批量查询 Shopee 店铺详情与经营指标（最多 10 个）。

## 认证与基址

- **Base URL**: `https://www.clawec.com/api`
- **API Key**: 在 https://www.clawec.com/?source=q-github-agent  注册帐号     然后去https://www.clawec.com/api-key?source=q-github-agent  获取key
- **请求头**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <API_KEY>`

优先从环境变量 `CLAWEC_API_KEY` 读取密钥；未设置时向用户索取，勿硬编码。

## 接口

`POST /aigc/ec/shopee/data/shop/detail`

| 参数 | 位置 | 必填 | 说明 |
|------|------|------|------|
| site | body | 是 | 站点：`tw` `my` `id` `th` `ph` `sg` `vn` `br` |
| shopIds | body | 是 | 店铺 ID；最多 10 个，多个用**英文逗号**分隔 |
| timest | body | 否 | 查询账期，`yyyy-MM-dd`，只能选某一天；不传默认昨天 |

### site 站点对照

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

超过 10 个店铺 ID 时拆成多批请求；用户给出店铺链接时先提取店铺 ID 与站点再查询。

## 调用

**单个店铺：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/shop/detail" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","shopIds":"12345678"}'
```

**批量（逗号分隔，最多 10 个）：**

```bash
curl -s -X POST "https://www.clawec.com/api/aigc/ec/shopee/data/shop/detail" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAWEC_API_KEY" \
  -d '{"site":"tw","shopIds":"12345678,87654321","timest":"2026-05-26"}'
```

或使用脚本：

```bash
# 站点 + 店铺 ID（必填）
bash scripts/query.sh tw 12345678

# 批量 ID（逗号分隔）+ 账期
bash scripts/query.sh tw "12345678,87654321" 2026-05-26
```

## 响应结构

```json
{
  "status": 1,
  "data": {
    "success": true,
    "errorCode": "",
    "errorMessage": "",
    "data": [ ... ]
  }
}
```

- 顶层 `status`: `1` = 成功，`0` = 失败
- `data.success` / `errorCode` / `errorMessage`: 业务层成功与错误信息
- `data.data`: 店铺详情数组

### 详情核心字段（`data.data[]`）

| 字段 | 说明 |
|------|------|
| shopId / shopName / shopAddress | 店铺 ID、名称、地址 |
| shopType | `1`=本土店铺 `2`=跨境店铺 |
| location | `1`=虾皮优选 `2`=虾皮商城 `3`=其他 |
| itemCount / activeItemCount / salesRate | 产品数、有销量产品数、动销率（%） |
| sales / sales7day / sales30day | 日/周/月销量 |
| gmv / gmv7day / gmv30day | 日/周/月销售额 |
| mainCatName / ratingStar | 主营类目、评分 |
| followerCount / followingCount / ctime | 粉丝、关注中、开店时间 |
| site / date | 站点、日期 |

完整字段见 [references/response-schema.md](references/response-schema.md)。

## 工作流程

1. 确认站点 `site` 与店铺 ID 列表（最多 10 个；超限则分批）
2. 如指定账期，校验 `timest` 为 `yyyy-MM-dd`
3. 检查 `CLAWEC_API_KEY` 是否可用
4. 执行 API 请求
5. 顶层 `status !== 1`，或 `data.success === false`，或请求失败时，说明错误并提示检查密钥、站点与 `shopIds`
6. 解析 `data.data`，按用户需求整理对比或单店深度解读

## 输出建议

默认中文报告，包含：

- 查询条件：站点、店铺 ID、账期
- **基础信息**：店铺名、地址、本土/跨境、优选/商城、主营类目、开店时间、评分、粉丝
- **经营表现**：产品数、动销率、日/周/月销量与 GMV
- **结论**：单店或对比场景下给出 2–3 条可行动观察

## 示例

**输入**：台湾站店铺 `12345678`

**输出摘要**：

| 字段 | 值 |
|------|-----|
| 店铺名 | … |
| 类型 | 跨境店铺 |
| 主营类目 | … |
| 30天销量 | … |
| 30天GMV | … |
| 动销率 | … |
| 粉丝 | … |

**观察**：（结合销量结构、动销率与开店时间给出结论）
