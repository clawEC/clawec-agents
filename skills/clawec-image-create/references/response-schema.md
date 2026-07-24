# AI 图片生成 — 响应结构

## 通用 envelope

| 字段 | 类型 | 说明 |
|------|------|------|
| status | integer | `1` = 成功，`0` = 失败 |
| code | integer | 业务码；成功通常 `200`；`2001` = Token 无效；`2002` = 积分不足 |
| msg | string | 消息 |
| data | object | 业务数据 |
| pointInfo | object | 积分信息 `{ type, point }` |

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
| id | string | 选项 ID，提交生成时使用 |
| title | string | 展示名称 |

### models 扩展字段（Web 端使用，可能存在）

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
| url | string | 图片完整 URL（优先使用） |
| path | string | 相对路径，需拼接 Base URL |

---

## POST /aigc/ec_media/image/create

### 请求体 ImageCreateParam

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| prompt | string | 是 | 提示词 |
| model | string | 否 | 模型 ID |
| ratio | string | 否 | 比例 ID |
| size | string | 否 | 分辨率 ID |
| images | string[] | 否 | 参考图 URL 列表 |

### 响应 data

提交成功时 `data` 通常为空对象 `{}`；生成结果通过 logs 接口获取。

---

## GET /aigc/ec_media/image/create/logs

### PageListImageResultV2（data）

| 字段 | 类型 | 说明 |
|------|------|------|
| count | integer | 总记录数 |
| more | integer | `1` = 有更多，`0` = 无更多 |
| start | integer | 下一页索引 |
| items | array | 记录列表 |

### ImageResultV2（items 元素）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 记录 ID |
| urls | string[] | 生成的图片 URL；生成中可能为空数组 |
| fail | boolean | `true` 表示生成失败 |
| param | ImageCreateParam | 原始生成参数 |
| time | string | 创建时间 |

### param（ImageCreateParam）

| 字段 | 说明 |
|------|------|
| prompt | 提示词 |
| model | 模型 ID |
| ratio | 比例 ID |
| size | 分辨率 ID |
| images | 参考图 URL 数组 |

---

## GET /aigc/ec_media/image/log/delete

| 参数 | 说明 |
|------|------|
| id | 要删除的记录 ID |

成功时 `status: 1`。

---

## WebSocket 推送（可选）

- 地址：`wss://www.clawec.com/api/aigc/socket`
- 连接后发送：`{"type":"login","id":"<TOKEN>"}`
- 图片结果刷新：`{"type":"image_result_refresh"}` → 应重新请求 logs 接口
