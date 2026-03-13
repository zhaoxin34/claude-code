# Slack 聊天系统 - 开发规范计划

## 背景

项目使用 Python FastAPI + React TypeScript，需要建立统一的开发规范以保证代码质量和团队协作效率。

**补充要求**：
- 前后端分离架构
- 后端采用分层架构设计
- Bot 接入预留接口（可接入多种 AI Agent）
- 结合 Claude Code 最佳实践

---

## 一、项目架构

### 1.1 前后端分离

```
anteam/
├── backend/           # Python FastAPI 后端
│   ├── src/
│   │   ├── api/       # 路由层
│   │   ├── service/  # 业务逻辑层
│   │   ├── repository/  # 数据访问层
│   │   ├── models/   # 数据模型
│   │   ├── schemas/  # Pydantic schemas
│   │   ├── core/     # 核心配置
│   │   └── main.py
│   ├── tests/
│   ├── Makefile
│   └── requirements.txt
│
├── frontend/         # React TypeScript 前端
│   ├── src/
│   ├── tests/
│   ├── package.json
│   └── vite.config.ts
│
└── CLAUDE.md         # Claude Code 项目配置
```

### 1.2 后端分层架构

```
┌─────────────────────────────────────┐
│           API Layer (api/)          │  ← 路由、请求验证
├─────────────────────────────────────┤
│        Service Layer (service/)     │  ← 业务逻辑
├─────────────────────────────────────┤
│    Repository Layer (repository/)   │  ← 数据访问
├─────────────────────────────────────┤
│          Model Layer (models/)      │  ← 数据模型
└─────────────────────────────────────┘
```

### 1.3 Bot 接入接口设计

```python
# 抽象 Bot 接口 - 可接入多种 AI Agent
class BaseBot(ABC):
    @abstractmethod
    async def handle_message(self, message: str, context: BotContext) -> str:
        pass

# 具体实现
class ClaudeBot(BaseBot):
    """Claude Agent Bot"""
    pass

class OpenAIBot(BaseBot):
    """OpenAI Bot - 预留"""
    pass

class GeminiBot(BaseBot):
    """Gemini Bot - 预留"""
    pass

# Bot 工厂
class BotFactory:
    def get_bot(self, bot_type: str) -> BaseBot:
        ...
```

---

## 开发规范内容

### 1. 后端开发规范 (Python/FastAPI)

#### 1.1 代码风格
- **格式化**: Black (行长度 100)
- **导入排序**: isort
- **类型检查**: mypy (strict mode)
- **代码检查**: flake8 + ruff

#### 1.2 API 设计规范
- RESTful 风格
- 使用 Pydantic v2 定义 Request/Response
- 统一错误响应格式
- OpenAPI 文档自动生成

#### 1.3 项目结构
```
src/
├── api/          # 路由定义
├── services/     # 业务逻辑
├── models/       # 数据模型 (SQLModel)
├── schemas/      # Pydantic schemas
├── db/           # 数据库配置
└── core/         # 核心配置
```

#### 1.4 数据库
- 使用 SQLModel (支持 Pydantic + SQLAlchemy)
- 数据库迁移: Alembic

#### 1.5 测试规范
- pytest + pytest-asyncio
- 覆盖率目标: 80%

---

### 2. 前端开发规范 (React + TypeScript)

#### 2.1 代码风格
- **格式化**: Prettier
- **代码检查**: ESLint (Airbnb config)
- **类型检查**: TypeScript (strict)

#### 2.2 项目结构
```
src/
├── components/   # 组件
├── pages/        # 页面
├── api/          # API 调用
├── hooks/        # 自定义 Hooks
├── stores/       # 状态管理
└── types/        # 类型定义
```

#### 2.3 组件规范
- 函数组件 + Hooks
- 使用 TypeScript 泛型
- 组件 Props 类型定义

#### 2.4 状态管理
- Redux Toolkit (客户端状态)
- React Query (服务端状态，可选)

---

### 3. Git 工作流规范

- 分支策略: Trunk-Based (main 分支开发)
- 提交规范: Conventional Commits
- Hooks: pre-commit (lint + format check)

---

### 4. Claude Code 开发最佳实践

#### 4.1 CLAUDE.md 项目配置

在项目根目录创建 `CLAUDE.md`，包含：
- 项目概述
- 技术栈说明
- 代码规范摘要
- 常用命令 (Makefile)
- 目录结构说明
- 注意事项

#### 4.2 Claude Code Rules

在 `.claude/rules/` 目录下创建：
- `backend.rules` - 后端开发规则
- `frontend.rules` - 前端开发规则
- `git.rules` - Git 提交规则

#### 4.3 开发流程 Hooks

每次完成编码后执行：

1. **代码简化** (可选): 调用 simplify skill
2. **格式化**: Black + isort (后端) / Prettier (前端)
3. **类型检查**: mypy (后端) / tsc --noEmit (前端)
4. **代码检查**: ruff (后端) / ESLint (前端)
5. **测试**: pytest / vitest
6. **Git 提交**: conventional commits

#### 4.4 Makefile 命令

```makefile
# 开发
make dev          # 启动开发服务器
make test         # 运行测试
make lint         # 代码检查
make format       # 代码格式化
make type-check   # 类型检查

# CI
make ci           # 运行所有检查 (lint + type-check + test)
```

---

## 实施阶段

### 第一阶段：基础设施 (优先完成)

| 步骤 | 内容 | 产出 |
|------|------|------|
| 1 | 创建项目目录结构 | backend/, frontend/ |
| 2 | 创建 .gitignore | git 忽略配置 |
| 3 | 创建 CLAUDE.md | Claude Code 项目配置 |
| 4 | 创建 .claude/rules/ 规则文件 | 开发规范 |

### 第二阶段：后端配置

| 步骤 | 内容 | 产出 |
|------|------|------|
| 5 | 后端 Python 环境配置 | pyproject.toml, requirements.txt |
| 6 | 后端 Makefile | lint/format/test 命令 |
| 7 | 配置 pre-commit hooks | 自动检查 |
| 8 | 创建 OpenAPI 文档 | openapi.yaml |

### 第三阶段：前端配置

| 步骤 | 内容 | 产出 |
|------|------|------|
| 9 | 前端 React 环境 | package.json, vite.config.ts |
| 10 | ESLint + Prettier + TypeScript | 前端 lint/format 命令 |
| 11 | 前端 Makefile | 统一命令入口 |

### 第四阶段：验证

| 步骤 | 内容 |
|------|------|
| 12 | 验证开发环境 (make dev, make test, make ci) |

---

## 待确认

- [x] GitFlow vs Trunk-Based 选择 - **Trunk-Based**
- [x] 前端状态管理具体方案 - **Redux Toolkit**
- [x] OpenAPI 文档 - **需要**

---

# 用户认证功能实现计划

## 背景

实现 Slack 聊天系统的用户认证功能，包括用户注册、登录和 JWT 认证。

## 实现方案

### 1. 创建数据库配置

**文件**: `backend/src/db/database.py`

- 创建 SQLModel 引擎配置
- 使用 SQLite 作为开发数据库
- 创建 get_session 依赖函数

### 2. 创建用户模型

**文件**: `backend/src/models/user.py`

```python
class User(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    email: str = Field(unique=True, index=True)
    username: str = Field(unique=True, index=True)
    hashed_password: str
    full_name: str | None = None
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
```

### 3. 创建 Pydantic Schemas

**文件**: `backend/src/schemas/user.py`

- `UserCreate` - 注册请求
- `UserLogin` - 登录请求
- `UserResponse` - 用户响应（不包含密码）
- `Token` - JWT token 响应
- `TokenData` - token 数据

### 4. 创建认证服务

**文件**: `backend/src/service/auth_service.py`

- `verify_password()` - 验证密码
- `get_password_hash()` - 密码哈希
- `create_access_token()` - 创建 JWT
- `verify_token()` - 验证 token

### 5. 创建用户仓库

**文件**: `backend/src/repository/user_repository.py`

- `get_user_by_email()` - 通过邮箱获取用户
- `get_user_by_username()` - 通过用户名获取用户
- `create_user()` - 创建用户
- `get_user()` - 通过 ID 获取用户

### 6. 创建认证 API

**文件**: `backend/src/api/auth.py`

- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录 (返回 JWT)
- `GET /api/auth/me` - 获取当前用户信息

### 7. 创建应用入口

**文件**: `backend/src/main.py`

- FastAPI 应用初始化
- 包含 health check 端点
- 注册 auth router

### 8. 创建依赖注入

**文件**: `backend/src/api/deps.py`

- `get_db` - 数据库会话依赖
- `get_current_user` - 当前用户依赖

## 验证方案

1. 启动后端服务: `make dev`
2. 测试注册: `POST /api/auth/register`
3. 测试登录: `POST /api/auth/login`
4. 测试认证: `GET /api/auth/me` (带 JWT token)
5. 运行测试: `make test`
6. 运行代码检查: `make ci`

---

# Omega 管理后台实现计划

## 背景

为 Slack 聊天系统实现管理后台（代号：**Omega**），用于维护用户、频道等资源。

## 需求确认

- **实现方式**: 同项目 `/admin` 路由（frontend/src/pages/admin/）
- **用户管理**: 完整 CRUD（查看、创建、编辑、删除）
- **访问权限**: 超级用户专属（需要 is_superuser=True）

## 实现方案

### 1. Backend - 扩展用户管理 API

**新增文件:**
- `backend/src/api/admin.py` - Admin API 路由
- `backend/src/schemas/user_admin.py` - Admin 用的 User schemas

**需要实现的端点:**
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/admin/users | 获取用户列表 |
| GET | /api/admin/users/{id} | 获取单个用户 |
| POST | /api/admin/users | 创建用户 |
| PUT | /api/admin/users/{id} | 更新用户 |
| DELETE | /api/admin/users/{id} | 删除用户 |

**修改文件:**
- `backend/src/main.py` - 注册 admin router

### 2. Backend - 添加超级用户权限验证

**修改文件:**
- `backend/src/api/deps.py` - 添加 `get_current_superuser` 依赖

### 3. Frontend - Omega 管理页面

**新增文件:**
- `frontend/src/pages/admin/AdminPage.tsx` - 管理后台主页
- `frontend/src/pages/admin/UserManagePage.tsx` - 用户管理页面
- `frontend/src/pages/admin/UserFormModal.tsx` - 用户编辑弹窗
- `frontend/src/api/admin.ts` - Admin API 调用
- `frontend/src/stores/adminSlice.ts` - Redux slice for admin

**修改文件:**
- `frontend/src/App.tsx` - 添加 /admin 路由
- `frontend/src/stores/index.ts` - 注册 admin slice

### 4. 验证方案

1. 启动服务: `make dev-backend dev-frontend`
2. 访问 `http://localhost:3000/admin`
3. 测试非超级用户访问应被拒绝
4. 创建超级用户测试完整 CRUD
5. 运行 `make ci` 确保代码质量

## 关键文件路径

- `backend/src/api/admin.py`
- `backend/src/schemas/user_admin.py`
- `backend/src/api/deps.py`
- `backend/src/main.py`
- `frontend/src/pages/admin/`
- `frontend/src/api/admin.ts`
- `frontend/src/stores/adminSlice.ts`

---

# 工作空间 (Workspace) 实现计划

## 背景

根据 `docs/Slack 风格聊天系统 - 简化版技术方案.md`，MVP 第二步是实现工作空间功能。

## 需求分析

### 需要实现的功能
| 功能 | 描述 |
|------|------|
| 创建工作空间 | 用户可以创建新的工作空间 |
| 列出工作空间 | 用户可以查看自己加入的工作空间列表 |
| 加入工作空间 | 用户可以加入已有工作空间 |
| 工作空间成员 | 工作空间与用户的多对多关系 |

### 数据模型
```
workspaces - 工作空间
workspace_members - 工作空间成员 (关联表)
```

## 实现方案

### 1. Backend - 数据模型

**新建文件:** `backend/src/models/workspace.py`

```python
class Workspace(SQLModel, table=True):
    """Workspace model."""
    __tablename__ = "workspaces"

    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    description: str | None = None
    owner_id: int = Field(foreign_key="users.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

class WorkspaceMember(SQLModel, table=True):
    """Workspace member model."""
    __tablename__ = "workspace_members"

    id: int | None = Field(default=None, primary_key=True)
    workspace_id: int = Field(foreign_key="workspaces.id")
    user_id: int = Field(foreign_key="users.id")
    role: str = Field(default="member")  # owner, admin, member
    joined_at: datetime = Field(default_factory=datetime.utcnow)
```

### 2. Backend - Schemas

**新建文件:** `backend/src/schemas/workspace.py`

- `WorkspaceCreate` - 创建请求
- `WorkspaceUpdate` - 更新请求
- `WorkspaceResponse` - 工作空间响应
- `WorkspaceMemberResponse` - 成员响应
- `WorkspaceListResponse` - 列表响应

### 3. Backend - Repository

**新建文件:** `backend/src/repository/workspace_repository.py`

- `get_workspace` - 获取单个工作空间
- `get_user_workspaces` - 获取用户所有工作空间
- `create_workspace` - 创建工作空间
- `add_member` - 添加成员
- `remove_member` - 移除成员
- `is_member` - 检查是否成员

### 4. Backend - API

**新建文件:** `backend/src/api/workspace.py`

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /api/workspaces | 列出用户的工作空间 |
| POST | /api/workspaces | 创建工作空间 |
| GET | /api/workspaces/{id} | 获取工作空间详情 |
| PUT | /api/workspaces/{id} | 更新工作空间 |
| DELETE | /api/workspaces/{id} | 删除工作空间 |
| POST | /api/workspaces/{id}/join | 加入工作空间 |
| DELETE | /api/workspaces/{id}/members/{user_id} | 移除成员 |

**修改文件:** `backend/src/main.py` - 注册 workspace router

### 5. Frontend - API Client

**新建文件:** `frontend/src/api/workspace.ts`

- `getWorkspaces()` - 获取工作空间列表
- `createWorkspace(data)` - 创建工作空间
- `joinWorkspace(id)` - 加入工作空间

### 6. Frontend - Types

**新建文件:** `frontend/src/types/workspace.ts`

### 7. Frontend - Page

**新建文件:** `frontend/src/pages/workspace/WorkspacePage.tsx`

- 工作空间列表展示
- 创建工作空间按钮
- 加入工作空间功能

### 8. Frontend - Routing

**修改文件:** `frontend/src/App.tsx`

- 添加 `/workspaces` 路由
- 在首页添加"工作空间"链接

## 关键文件路径

- `backend/src/models/workspace.py`
- `backend/src/schemas/workspace.py`
- `backend/src/repository/workspace_repository.py`
- `backend/src/api/workspace.py`
- `backend/src/main.py`
- `frontend/src/api/workspace.ts`
- `frontend/src/types/workspace.ts`
- `frontend/src/pages/workspace/WorkspacePage.tsx`
- `frontend/src/App.tsx`

## 验证方案

1. 启动服务: `make dev-backend dev-frontend`
2. 测试 API:
   - POST /api/workspaces (创建)
   - GET /api/workspaces (列表)
   - POST /api/workspaces/{id}/join (加入)
3. 测试前端: 访问 http://localhost:3000/workspaces
4. 运行 `make ci` 确保代码质量
