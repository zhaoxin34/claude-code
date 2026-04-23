# CDP Backend 日志系统实现计划

## Context

CDP Backend 项目目前**没有配置任何日志系统**，代码中没有使用 Python `logging` 模块。这使得：
- 无法追踪 HTTP 请求的详细信息
- 无法记录业务事件（登录、注册）
- 难以排查问题和监控系统

需要添加结构化日志系统，支持控制台和文件输出、滚动删除。

## 实现方案

### 文件变更清单

| 操作 | 文件路径 | 说明 |
|-----|---------|-----|
| 新建 | `src/app/core/logging.py` | 日志核心配置、JSON/Plain 格式化器、RotatingFileHandler |
| 新建 | `src/app/middleware/logging_middleware.py` | HTTP 请求日志中间件 |
| 新建 | `.env.example` | 环境变量配置示例 |
| 修改 | `src/app/config.py` | 添加日志相关配置项 |
| 修改 | `src/app/main.py` | 初始化日志系统、注册中间件 |
| 修改 | `src/app/services/auth_service.py` | 添加登录/注册业务事件日志 |
| 修改 | `.env` | 添加日志配置（可选，不存在时使用 .env.example） |

---

### 日志配置项（.env / .env.example）

```env
# ==================== 日志配置 ====================

# 日志级别: DEBUG, INFO, WARNING, ERROR
LOG_LEVEL=INFO

# 日志格式: json, plain
LOG_FORMAT=json

# 日志输出: console, file, both
LOG_OUTPUT=both

# 日志目录（相对于项目根目录）
LOG_DIR=logs

# 日志文件名
LOG_FILE=app.log

# 日志文件最大大小（字节），默认 10MB
LOG_MAX_BYTES=10485760

# 保留日志文件数量
LOG_BACKUP_COUNT=5
```

---

### 1. 新建 `src/app/core/logging.py`

- `setup_logging()`: 配置根日志器，支持控制台和文件双输出
- `RotatingFileHandler`: 按大小滚动，保留 `LOG_BACKUP_COUNT` 个备份
- `JSONFormatter`: 生产环境 JSON 格式
- `PlainFormatter`: 开发环境易读格式
- `get_logger(name)`: 获取日志器
- Context vars: `set_request_id()` / `get_request_id()` / `set_user_id()` / `get_user_id()`

### 2. 新建 `src/app/middleware/logging_middleware.py`

- `LoggingMiddleware(BaseHTTPMiddleware)`: 中间件类
- 每个请求生成唯一 `request_id`（UUID）
- 请求开始/结束记录详细信息
- 响应头添加 `X-Request-ID`

### 3. 修改 `src/app/config.py`

在 `Settings` 类添加：
```python
# Logging
LOG_LEVEL: str = "INFO"
LOG_FORMAT: str = "json"           # json | plain
LOG_OUTPUT: str = "both"           # console | file | both
LOG_DIR: str = "logs"
LOG_FILE: str = "app.log"
LOG_MAX_BYTES: int = 10485760      # 10MB
LOG_BACKUP_COUNT: int = 5
```

### 4. 新建 `.env.example`

完整配置示例：
```env
# Application
APP_NAME="CDP API"
DEBUG=True
API_V1_PREFIX="/api/v1"

# Database
DATABASE_URL="mysql+pymysql://root:root@127.0.0.1:3306/cdp"

# Security
SECRET_KEY="your-secret-key-change-in-production"
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Server
HOST="0.0.0.0"
PORT=8001

# ==================== 日志配置 ====================
# 日志级别: DEBUG, INFO, WARNING, ERROR
LOG_LEVEL=INFO

# 日志格式:
#   - json: 结构化JSON格式，适合生产环境收集分析
#   - plain: 人类可读格式，带颜色高亮，适合开发调试
LOG_FORMAT=json

# 日志输出:
#   - console: 仅输出到控制台
#   - file: 仅输出到文件
#   - both: 同时输出到控制台和文件
LOG_OUTPUT=both

# 日志文件配置（LOG_OUTPUT=file 或 both 时生效）
LOG_DIR=logs              # 日志目录（相对于 backend 目录）
LOG_FILE=app.log          # 日志文件名
LOG_MAX_BYTES=10485760    # 单个日志文件最大大小（字节），默认 10MB
LOG_BACKUP_COUNT=5         # 保留的备份文件数量，超过后自动删除旧文件
```

### 5. 修改 `src/app/main.py`

```python
from app.core.logging import setup_logging
from app.middleware.logging_middleware import LoggingMiddleware

setup_logging()

app = FastAPI(...)
app.add_middleware(LoggingMiddleware)
```

### 6. 修改 `src/app/services/auth_service.py`

添加业务事件日志：
- `create_user()`: 记录 `user.registered`
- `authenticate()`: 记录 `user.login` / `user.login.failed`

---

## 日志输出示例

### LOG_FORMAT=plain（开发环境）
```
2026-04-21 17:30:00.123 | INFO     | app.middleware.logging    | [a1b2c3d4] | [None]    | HTTP request started
2026-04-21 17:30:00.456 | INFO     | app.services.auth         | [a1b2c3d4] | [1]       | User logged in successfully
```

### LOG_FORMAT=json（生产环境）
```json
{"timestamp": "2026-04-21T09:30:00.123456Z", "level": "INFO", "logger": "app.services.auth", "message": "User logged in successfully", "request_id": "550e8400-e29b-41d4-a716-446655440000", "user_id": 1, "event": "user.login", "username": "testuser"}
```

### 日志文件滚动
```
logs/
├── app.log          # 当前日志文件
├── app.log.1        # 最新备份
├── app.log.2        # 第二新备份
├── app.log.3        # ...
├── app.log.4
└── app.log.5        # 最旧备份（达到 LOG_BACKUP_COUNT 上限后被删除）
```

---

## 验证方案

1. **启动服务**: `cd cdp/backend && make dev`
2. **测试日志文件**: `tail -f logs/app.log` 观察日志写入
3. **测试滚动**: 写入大量日志直到文件超过 `LOG_MAX_BYTES`，验证 `.log.1` 备份生成
4. **测试备份数量**: 超过 `LOG_BACKUP_COUNT` 后验证旧文件被自动删除
5. **发送测试请求**:
   - `POST /api/v1/auth/register` - 应看到 `user.registered` 日志
   - `POST /api/v1/auth/login` - 应看到 `user.login` 日志
6. **验证配置生效**: 修改 `.env` 中 `LOG_LEVEL=DEBUG` 和 `LOG_FORMAT=plain`，重启后验证
