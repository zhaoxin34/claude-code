# CDP E2E 测试框架工程计划

## Context

需要在 `/Volumes/data/working/ai/matrix/cdp/e2e-test/` 目录下创建一个 Playwright 自动化测试框架工程。

**问题**：旧的测试用例（`e2e-test-case/playwright/`）使用元素 uid（如 e37, e48）定位，页面改动后极易失效，需要创建稳健的测试框架。

**目标**：创建测试框架工程骨架，包括页面对象模型设计、pytest 配置、Allure 报告集成

## 项目结构

```
cdp/e2e-test/
├── pyproject.toml           # uv 项目配置
├── Makefile                 # 构建命令
├── pytest.ini               # pytest 配置
├── conftest.py              # pytest 全局 fixture
├── src/
│   └── e2e/                 # 源代码
│       ├── __init__.py
│       ├── conftest.py      # 页面对象和 fixture
│       ├── pages/           # 页面对象模型
│       │   ├── __init__.py
│       │   ├── base.py      # 基础页面类
│       │   ├── login.py     # 登录页
│       │   ├── register.py  # 注册页
│       │   └── home.py      # 首页
│       ├── tests/           # 测试用例
│       │   ├── __init__.py
│       │   ├── test_login.py
│       │   ├── test_register.py
│       │   └── test_home.py
│       └── utils/           # 工具函数
│           ├── __init__.py
│           └── helpers.py
├── tests/                   # 测试入口（兼容 pytest 发现）
│   └── test_e2e.py
└── .env.example             # 环境变量示例
```

## 技术栈

- Python 3.11+
- pytest
- playwright (Python)
- allure-pytest

使用 uv 管理工程

## 关键文件说明

### 1. pyproject.toml
- 使用 uv 管理依赖
- 依赖：pytest, playwright, allure-pytest, pytest-playwright

### 2. conftest.py
- 提供 page fixture（Playwright 浏览器上下文）
- 提供 base_url 配置（http://localhost:3001）

### 3. 页面对象模型（pages/）
- 每个页面一个类，封装元素定位器和操作方法
- 使用语义化定位器（data-testid, role, text）而非 uid

### 4. 测试用例（tests/）
- 使用 pytest 风格
- 利用 allure-pytest 生成报告

## 实施步骤

### Step 1: 创建项目基础文件
- `pyproject.toml` - uv 配置和依赖
- `pytest.ini` - pytest 配置
- `Makefile` - 常用命令

### Step 2: 创建源代码结构
- `src/e2e/__init__.py`
- `src/e2e/conftest.py` - 页面 fixture
- `src/e2e/pages/base.py` - 基础页面类
- `src/e2e/pages/login.py`, `register.py`, `home.py` - 页面对象

### Step 3: 创建示例测试
- `tests/test_login.py` - 登录测试示例
- `tests/test_register.py` - 注册测试示例
- `tests/test_home.py` - 首页测试示例

### Step 4: 环境配置
- `.env.example` - 环境变量模板

## 验证方式

1. `make install` - 安装依赖和浏览器
2. `make test` - 运行测试
3. `make report` - 生成 Allure 报告
4. `make open-report` - 打开报告