# 商品图生成 — 响应结构

## 通用 envelope

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| code | integer | 业务码；`2001` = Token 无效；`2002` = 积分不足 |
| msg | string | 消息 |
| data | object / array | 业务数据 |
| pointInfo | object | 积分信息 `{ type, point }` |

---

## GET /aigc/ec_product_media/platform_options

### MarketResp（data 数组元素）

| 字段 | 类型 | 说明 |
|------|------|------|
| code | string | 平台代码，对应 `target_platform` |
| name | string | 平台名称 |
| regions | array | 市场列表 |

### RegionResp（regions 元素）

| 字段 | 类型 | 说明 |
|------|------|------|
| code | string | 市场代码，对应 `region` |
| name | string | 市场名称 |

---

## GET /aigc/ec_media/image/create/dic

### ImageCreateDic（data）

| 字段 | 类型 | 说明 |
|------|------|------|
| models | array | 模型列表 |
| sizes | array | 分辨率列表 |
| ratios | array | 比例列表 |

### TypeRespString（models / sizes / ratios 元素）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 选项 ID |
| title | string | 展示名称 |

### models 扩展字段

| 字段 | 类型 | 说明 |
|------|------|------|
| point | number | 每张图消耗积分 |
| level | integer | 所需会员等级 |
| levelText | string | 等级展示文案 |

---

## POST /upload/image

### 上传响应 data

| 字段 | 类型 | 说明 |
|------|------|------|
| url | string | 图片完整 URL |
| path | string | 相对路径 |

---

## POST /aigc/ec_media/image/create

### 请求体（商品图）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| prompt | string | 条件 | 提示词；与 images 至少一项 |
| target_platform | string | 是 | 目标平台 code |
| image_scene | string | 否 | `cover` / `cover_other` / `detail` |
| region | string | 否 | 目标市场 code |
| model | string | 否 | 模型 ID |
| ratio | string | 否 | 比例 ID |
| size | string | 否 | 分辨率 ID |
| images | string[] | 否 | 参考图 URL 列表 |

### image_scene

| 值 | 含义 |
|----|------|
| cover | 主图 |
| cover_other | 副图 |
| detail | 详情图 / A+ |

### 响应 data

提交成功时通常为空对象 `{}`；结果通过 logs 接口获取。

---

## GET /aigc/ec_media/image/create/logs/product

### PageListImageResultV2（data）

| 字段 | 类型 | 说明 |
|------|------|------|
| count | integer | 总记录数 |
| more | integer | `1` = 有更多 |
| start | integer | 下一页索引 |
| items | array | 记录列表 |

### ImageResultV2（items 元素）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 记录 ID |
| urls | string[] | 生成图片 URL |
| fail | boolean | 是否失败 |
| param | object | 原始参数 |
| time | string | 创建时间 |

### param 扩展字段（商品图）

| 字段 | 说明 |
|------|------|
| prompt | 提示词 |
| model / ratio / size | 模型与尺寸选项 ID |
| images | 参考图 URL |
| image_scene | 图片场景 |
| target_platform | 目标平台 |
| region | 目标市场 |

---

## GET /aigc/ec_media/image/log/delete

| 参数 | 说明 |
|------|------|
| id | 记录 ID |

---

## WebSocket 推送（可选）

- 地址：`wss://www.clawec.com/api/aigc/socket`
- 连接后发送：`{"type":"login","id":"<TOKEN>"}`
- 图片结果刷新：`{"type":"image_result_refresh"}`
