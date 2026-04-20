# Kulala.nvim HTTP 文件参考

## 文件格式概述

`.http` 文件是纯文本文件，包含一个或多个 HTTP 请求。请求之间用 `###` 分隔。

## 标准 HTTP 请求格式

```
### 请求名称 (可选)
@name requestName
<METHOD> <URL>
<Header1>: <Value1>
<Header2>: <Value2>

<Request Body>
```

## 实际示例

### 1. 基础 CRUD 操作

```http
### 获取用户列表
# @name listUsers
GET https://api.example.com/users
Content-Type: application/json
Authorization: Bearer {{token}}

### 获取单个用户
# @name getUser
GET https://api.example.com/users/123
Authorization: Bearer {{token}}

### 创建用户
# @name createUser
POST https://api.example.com/users
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "name": "John Doe",
  "email": "john@example.com",
  "role": "admin"
}

### 更新用户
# @name updateUser
PUT https://api.example.com/users/123
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "name": "John Updated",
  "email": "updated@example.com"
}

### 删除用户
# @name deleteUser
DELETE https://api.example.com/users/123
Authorization: Bearer {{token}}
```

### 2. 带认证的完整流程

```http
# @shared
@baseUrl = https://api.example.com
@clientId = my-client-id
@clientSecret = my-secret

### 登录获取 Token
# @name login
POST {{baseUrl}}/auth/login
Content-Type: application/json

{
  "clientId": "{{clientId}}",
  "clientSecret": "{{clientSecret}}"
}

### 使用登录后的 token 访问受保护资源
# @ref login.response.body.accessToken
# @name protectedResource
GET {{baseUrl}}/protected
Authorization: Bearer {{accessToken}}
```

### 3. 分页和过滤

```http
### 带查询参数的列表请求
# @name listProducts
GET {{baseUrl}}/products
  ?page={{page}}
  &limit={{limit}}
  &category={{category}}
  &sort={{sort}}
Authorization: Bearer {{token}}

### 使用变量
@page = 1
@limit = 20
@category = electronics
@sort = price_asc
```

### 4. 文件上传

```http
### Multipart 文件上传
# @name uploadFile
POST https://api.example.com/upload
Authorization: Bearer {{token}}
Content-Type: multipart/form-data; boundary=----FormBoundary7MA4YWxkTrZu0gW

------FormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="document.pdf"
Content-Type: application/pdf

< ./uploads/document.pdf
------FormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="metadata"

{"description": "Annual report", "year": 2024}
------FormBoundary7MA4YWxkTrZu0gW--
```

### 5. GraphQL 请求

```http
### GraphQL Query
# @name graphQLUsers
GRAPHQL {{baseUrl}}/graphql
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "query": "query GetUsers($limit: Int) { users(limit: $limit) { id name email createdAt } }",
  "variables": {
    "limit": 10
  }
}

### GraphQL Mutation
# @name createGraphQLUser
GRAPHQL {{baseUrl}}/graphql
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "query": "mutation CreateUser($input: UserInput!) { createUser(input: $input) { id name email } }",
  "variables": {
    "input": {
      "name": "New User",
      "email": "new@example.com"
    }
  }
}
```

### 6. WebSocket 连接

```http
### WebSocket 连接
# @name wsConnection
WEBSOCKET ws://api.example.com/realtime
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Version: 13
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==

### 发送消息
# @ws-send wsConnection
{"type": "subscribe", "channel": "updates"}

### 接收消息
# @ws-receive wsConnection
```

### 7. gRPC 请求

```http
### gRPC 调用
# @name grpcGetUser
GRPC https://api.example.com:50051
Content-Type: application/grpc
Authorization: Bearer {{token}}

service UserService {
  rpc GetUser (UserRequest) returns (UserResponse);
}

message UserRequest {
  string user_id = 1;
}
```

### 8. 测试断言示例

```http
### 带断言的测试请求
# @test
# @name testUserCreation
POST {{baseUrl}}/users
Content-Type: application/json

{
  "name": "Test User",
  "email": "test-{{$guid}}@example.com"
}

# @assert-eq response.status 201
# @assert response.body.hasOwnProperty('id')
# @assert response.body.hasOwnProperty('email')

### 测试响应时间
# @max-response-time 500
```

### 9. 条件执行

```http
### 基于环境变量条件执行
# @if environment == "prod"
# @name prodHealthCheck
GET https://api.production.com/health
# @endif

### 基于变量存在性
# @name conditionalRequest
POST {{baseUrl}}/webhooks
Content-Type: application/json
{{#if webhookUrl}}
X-Webhook-URL: {{webhookUrl}}
{{/if}}
```

### 10. 错误处理和重试

```http
### 重试配置
# @retry 3
# @timeout 30s
# @name robustRequest
GET {{baseUrl}}/unstable-endpoint

### 错误预期
# @name expectNotFound
GET {{baseUrl}}/users/999
# @expectedStatus 404
```

## 环境变量文件格式

### http-client.env.json

```json
{
  "local": {
    "baseUrl": "http://localhost:3000",
    "token": "dev-token-12345"
  },
  "dev": {
    "baseUrl": "https://api.dev.example.com",
    "token": "dev-token-67890"
  },
  "staging": {
    "baseUrl": "https://api.staging.example.com",
    "token": "staging-token-abcdef"
  },
  "prod": {
    "baseUrl": "https://api.example.com",
    "token": "prod-token-xyz"
  }
}
```

### .env 文件格式

```
# Environment
ENVIRONMENT=dev

# API Settings
API_BASE_URL=https://api.dev.example.com
API_VERSION=v2

# Auth
API_KEY=your-api-key-here
CLIENT_SECRET=your-client-secret

# Feature Flags
ENABLE_CACHE=true
DEBUG_MODE=false
```

## Magic 变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `{{$guid}}` | 全局唯一 ID | `user-{{$guid}}` |
| `{{$uuid}}` | UUID v4 | `{{$uuid}}` |
| `{{$timestamp}}` | Unix 时间戳 | `{{$timestamp}}` |
| `{{$randomInt}}` | 0-1000 随机整数 | `{{$randomInt}}` |
| `{{$randomInt min max}}` | 指定范围随机 | `{{$randomInt 1 100}}` |
| `{{$date}}` | ISO 日期 | `2024-01-15` |
| `{{$time}}` | ISO 时间 | `10:30:00` |
| `{{$processEnv.VAR_NAME}}` | 环境变量 | `{{$processEnv.HOME}}` |

## 响应过滤 (JQ)

```http
### 提取特定字段
# @name getUserIds
GET {{baseUrl}}/users
# @jq ".data[].id"

### 过滤和转换
# @name filteredUsers
GET {{baseUrl}}/users
# @jq ".data[] | select(.active == true) | {id: .id, name: .name}"

### 计数
# @name countUsers
GET {{baseUrl}}/users
# @jq ".total"
```

## 常见错误排除

1. **请求不执行**: 确保请求前有空行分隔 headers 和 body
2. **变量未解析**: 检查 `{{variable}}` 语法，变量必须定义
3. **环境变量不工作**: 确认 `http-client.env.json` 格式正确且在正确目录
4. **认证失败**: 检查 token 格式 (Bearer 前缀)
5. **文件上传失败**: 确保 boundary 正确设置

## 参考链接

- [Kulala.nvim 官方文档](https://kulala.mwco.app/docs/usage)
- [REST Client VS Code 扩展](https://github.com/Huachao/vscode-restclient)
