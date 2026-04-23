# CDP 项目实施计划

## Context

用户需要在 `/Volumes/data/working/ai/matrix/cdp` 目录下创建CDP（Customer Data Platform）项目，第一期仅实现登录和注册功能。技术架构完全参考已有的 `/Volumes/data/working/ai/matrix/ecommerce` 项目。数据库已创建（MySQL: `mysql -u root -proot -h 127.0.0.1 cdp`）。

## 技术架构（参考 ecommerce）

### 后端（FastAPI + Python）
- 框架: FastAPI >= 0.109.0, Python >= 3.10
- 数据库: SQLAlchemy 2.0 + pymysql + alembic
- 认证: JWT (python-jose) + 密码加密 (passlib/bcrypt)
- 项目结构: `src/app/` 下模块化结构（api, models, schemas, services, repositories）

### 前端（React + TypeScript）
- 框架: React 18.2 + TypeScript 5.4 + Vite 5.2
- UI组件: Ant Design 5.15
- 路由: react-router-dom 6
- 状态管理: Zustand 4.5
- 表单: react-hook-form + zod

### 数据库
- 已有数据库: `cdp` (MySQL)
- 只需创建 users 表（参考 ecommerce 的 users 表）

---

## 实施步骤

### 阶段1: 后端项目搭建

1. **创建项目目录结构**
   ```
   cdp/backend/
   ├── src/app/
   │   ├── api/v1/
   │   │   ├── __init__.py
   │   │   ├── auth.py        # 认证接口
   │   │   └── health.py      # 健康检查
   │   ├── core/
   │   │   ├── __init__.py
   │   │   └── security.py    # JWT/密码加密
   │   ├── models/
   │   │   ├── __init__.py
   │   │   └── user.py        # 用户模型
   │   ├── schemas/
   │   │   ├── __init__.py
   │   │   └── auth.py        # 认证schema
   │   ├── services/
   │   │   ├── __init__.py
   │   │   └── auth_service.py
   │   ├── repositories/
   │   │   ├── __init__.py
   │   │   └── user_repo.py
   │   ├── main.py
   │   ├── config.py
   │   ├── database.py
   │   └── dependencies.py
   ├── alembic/
   │   ├── env.py
   │   └── versions/
   ├── tests/
   ├── Makefile
   ├── requirements.txt
   └── .env
   ```

2. **创建 requirements.txt**（精简版，仅包含auth相关依赖）
   ```
   fastapi>=0.109.0
   uvicorn[standard]>=0.27.0
   sqlalchemy>=2.0.0
   pymysql>=1.1.0
   alembic>=1.13.0
   python-jose[cryptography]>=3.3.0
   passlib[bcrypt]>=1.7.4
   bcrypt>=4.1.0
   pydantic>=2.5.0
   pydantic-settings>=2.1.0
   python-multipart>=0.0.9
   pytest>=8.0.0
   httpx>=0.26.0
   ```

3. **创建配置文件**
   - `.env`: 数据库连接、密钥等
   - `config.py`: 配置类

4. **创建数据库模型**
   - 只需 `User` 模型（参考 ecommerce）

5. **创建认证服务和API**
   - `AuthService`: 注册、登录、token验证
   - `auth.py`: POST /register, POST /login, GET /health

6. **创建 Makefile**（包含 install, dev, test, lint, format, type-check, migrate）

7. **执行数据库迁移**
   - 初始化 alembic
   - 生成初始迁移
   - 执行迁移创建 users 表

### 阶段2: 前端项目搭建

1. **创建项目目录结构**
   ```
   cdp/frontend/
   ├── src/
   │   ├── api/
   │   │   ├── axios.ts
   │   │   ├── modules/user.ts
   │   │   └── types.ts
   │   ├── components/layout/
   │   │   ├── MainLayout.tsx
   │   │   ├── Header.tsx
   │   │   └── Footer.tsx
   │   ├── pages/
   │   │   ├── Login.tsx
   │   │   ├── Register.tsx
   │   │   └── Home.tsx
   │   ├── stores/
   │   │   └── authStore.ts
   │   ├── hooks/
   │   │   └── useAuth.ts
   │   ├── types/
   │   │   └── user.ts
   │   ├── App.tsx
   │   └── main.tsx
   ├── index.html
   ├── package.json
   ├── vite.config.ts
   ├── tsconfig.json
   ├── Makefile
   └── .env.example
   ```

2. **创建 package.json**（精简版，仅包含核心依赖）

3. **创建登录/注册页面**
   - 复用 ecommerce 的 Login.tsx, Register.tsx 设计
   - 适配 CDP 的 API 端点

4. **创建简单的首页**（登录/注册后可跳转）

5. **配置 Vite 代理**（代理到 localhost:8001）

6. **创建 Makefile**（包含 install, dev, build, lint, format, type-check, test）

### 阶段3: 验证测试

1. **后端验证** (端口: 8001)
   - 启动后端: `make dev`
   - 测试健康检查: `curl http://localhost:8001/health`
   - 测试注册: `curl -X POST http://localhost:8001/api/v1/auth/register`
   - 测试登录: `curl -X POST http://localhost:8001/api/v1/auth/login`

2. **前端验证** (端口: 3001)
   - 启动前端: `make dev`
   - 使用 playwright-cli 访问登录/注册页面

3. **E2E测试**
   - 在 `cdp/e2e-test-case/` 创建测试用例
   - 测试注册 → 登录完整流程
   - 执行测试验证

---

## 关键技术细节

- 后端端口: 8001
- 前端端口: 3001
- 注册流程: 简化版（无需短信验证码，直接注册）
- E2E测试目录: `cdp/e2e-test-case/`

---

## 关键文件参考

| 功能 | ecommerce 参考路径 |
|------|-------------------|
| 后端主入口 | `ecommerce/backend/src/app/main.py` |
| 认证服务 | `ecommerce/backend/src/app/services/auth_service.py` |
| 用户模型 | `ecommerce/backend/src/app/models/user.py` |
| 登录页面 | `ecommerce/frontend/src/pages/Login.tsx` |
| 注册页面 | `ecommerce/frontend/src/pages/Register.tsx` |
| authStore | `ecommerce/frontend/src/stores/authStore.ts` |
| axios配置 | `ecommerce/frontend/src/api/axios.ts` |

---

## 验证清单

- [ ] 后端 `http://localhost:8001/health` 接口返回正常
- [ ] 后端 `POST /api/v1/auth/register` 注册成功
- [ ] 后端 `POST /api/v1/auth/login` 登录成功并返回JWT
- [ ] 前端 `http://localhost:3001/login` 可访问
- [ ] 前端 `http://localhost:3001/register` 可访问
- [ ] Playwright CLI E2E 测试注册流程通过
- [ ] Playwright CLI E2E 测试登录流程通过
