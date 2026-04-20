---
name: kulala-http
description: |
  kulala.nvim skill for writing .http files in Neovim. Use this skill whenever:
  - User asks to create or edit .http files for API testing
  - User wants to test HTTP endpoints, REST APIs
  - User mentions kulala, REST Client, HTTP requests
  - User wants to send HTTP requests from Neovim
  - User needs to write OpenAPI import/export, GraphQL, gRPC requests
  Trigger especially when user mentions kulala.nvim or wants Neovim-based HTTP client functionality.
---

# Kulala.nvim HTTP 文件编写技能

kulala.nvim 是一个为 Neovim 设计的轻量级 HTTP 客户端插件，允许你在 Neovim 中直接发送 HTTP 请求并查看响应。

## 基础语法

### 简单 GET 请求

```http
GET https://api.example.com/users
```

### 带 Headers 的请求

```http
GET https://api.example.com/users
Content-Type: application/json
Authorization: Bearer {{token}}
```

### POST 请求 with Body

```http
POST https://api.example.com/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com"
}
```

### 带查询参数

```http
GET https://api.example.com/users?page=1&limit=10
```

### Request Variables (命名请求)

```http
# @name getUsers
GET https://api.example.com/users

### 获取之前请求的响应数据
# @ref getUsers
```

### 直接引用响应数据

登录后可直接在后续请求中引用响应字段：

```http
# @name loginUser
POST {{baseUrl}}/auth/login HTTP/1.1
Content-Type: application/json

{
  "password": "{{testPassword}}",
  "phone": "{{testPhone}}"
}

### 获取当前用户信息（直接引用 loginUser 响应中的 access_token）
# @name getMe
GET {{baseUrl}}/auth/me HTTP/1.1
Authorization: Bearer {{loginUser.response.body.access_token}}
```

## 变量类型

### 自定义变量

```http
@baseUrl = https://api.example.com
@token = my-secret-token
```

### 环境变量

```http
{{baseUrl}}    # 基础 URL
{{token}}      # 自定义变量
{{$guid}}      # 自动生成的 GUID
{{$randomInt}} # 随机整数
{{$timestamp}} # 当前时间戳
{{$uuid}}      # UUID
```

### DotEnv 支持

在 `.http` 文件同目录创建 `http-client.env.json`:

```json
{
  "dev": {
    "baseUrl": "http://localhost:3000",
    "apiKey": "dev-key"
  },
  "prod": {
    "baseUrl": "https://api.production.com",
    "apiKey": "prod-key"
  }
}
```

或 `.env` 文件:

```
BASE_URL=https://api.example.com
API_KEY=your-api-key
```

## 认证方式

### Bearer Token

```http
GET https://api.example.com/protected
Authorization: Bearer {{token}}
```

### Basic Auth

```http
GET https://api.example.com/protected
Authorization: Basic {{username}}:{{password}}
```

### API Key in Header

```http
GET https://api.example.com/data
X-API-Key: {{apiKey}}
```

## 请求类型

### Form Data

```http
POST https://api.example.com/upload
Content-Type: application/x-www-form-urlencoded

name=John&age=30
```

### Multipart Form Data

```http
POST https://api.example.com/upload
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="file"; filename="test.txt"

File content here
--boundary--
```

### GraphQL

```http
GRAPHQL https://api.example.com/graphql
Content-Type: application/json

{
  "query": "query { users { id name email } }"
}
```

### gRPC

```http
GRPC https://api.example.com:50051
Content-Type: application/grpc

service UserService {
  rpc GetUser (UserRequest) returns (UserResponse);
}
```

### WebSocket

```http
WEBSOCKET ws://api.example.com/ws
Upgrade: websocket
Connection: Upgrade
```

## Shared Blocks (共享块)

在文件顶部定义，所有请求共享:

```http
# @shared
@baseUrl = https://api.example.com
@token = default-token

# @shared
headers {
  Content-Type: application/json
  Authorization: Bearer {{token}}
}

### 请求1
GET {{baseUrl}}/users
```

## 动态引用响应数据

### 直接引用响应字段

最简洁的方式是在后续请求中直接引用之前请求的响应字段：

```http
# @name login
POST https://api.example.com/auth/login
Content-Type: application/json

{"username": "user", "password": "pass"}

### 获取用户信息（直接引用 login 响应中的 token）
GET https://api.example.com/user
Authorization: Bearer {{login.response.body.token}}
```

### 基于响应 Headers

```http
# @name login
POST https://api.example.com/auth/login
Content-Type: application/json

{"username": "user", "password": "pass"}

# 引用 login 响应中的 x-auth-token header
Authorization: Bearer {{login.response.headers.x-auth-token}}
```

## 常用 Neovim 快捷键

| 快捷键 | 功能 |
|--------|------|
| `<leader>r` | 发送当前请求 |
| `<leader>rr` | 重新发送上一个请求 |
| `<leader>rc` | 取消请求 |
| `<leader>rv` | 切换环境变量视图 |
| `<leader>re` | 查看响应 |
| `<leader>rs` | 打开请求选择器 |

## 最佳实践

### 1. 组织 .http 文件结构

```
.http/
├── users.http      # 用户相关 API
├── orders.http     # 订单相关 API
└── shared.http    # 共享配置和请求
```

### 2. 命名约定

```http
# @name listUsers          # 列表
# @name getUserById        # 获取单个
# @name createUser         # 创建
# @name updateUser         # 更新
# @name deleteUser         # 删除
```

### 3. 错误处理

```http
# @expectedStatus 201
POST https://api.example.com/users
```

### 4. 调试技巧

使用 `# @jq` 过滤响应:

```http
GET https://api.example.com/users
# @jq ".data[] | select(.active == true)"
```

### 5. 测试断言

```http
# @test
GET https://api.example.com/users

# @assert
response.status == 200
response.body.total > 0
```

## 导入/导出

### 从 Postman 导入

```bash
:KulalaImport postman_collection.json
```

### 导出为 OpenAPI

```bash
:KulalaExport openapi https://api.example.com
```

## CLI 使用 (CI/CD)

```bash
# 执行所有请求
kulala run requests.http --env dev

# 执行单个请求
kulala run requests.http --name getUsers

# 环境变量
kulala run requests.http --var baseUrl=https://api.example.com
```

## 快速参考

```http
### 基础请求模板
@baseUrl = {{baseUrl}}
@token = {{token}}

# @name <requestName>
<METHOD> {{baseUrl}}<endpoint>
Content-Type: application/json
Authorization: Bearer {{token}}

<request-body>

### 响应引用
# @ref <requestName>.response.body.<field>
# @ref <requestName>.response.headers.<header-name>
```
