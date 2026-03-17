---
name: python-best-practice
description: 创建生产级 Python 项目的最佳实践技能。当用户想要创建一个新的 Python 项目、初始化 Python 项目、设置 Python 开发环境时，必须使用此技能。确保项目使用 uv 包管理、标准的 src/tests 目录结构、完整的工具链配置（类型检查、格式化、测试、Git hooks）。
metadata:
  author: zhaoxin
  version: "1.0"
---

## 项目结构

创建以下标准目录结构：

```
project-name/
├── src/
│   └── project_name/    # 包名使用 kebab-case 转 snake_case
│       └── __init__.py
├── tests/
│   ├── unit/
│   └── integration/
├── pyproject.toml
├── Makefile
├── .gitignore
└── README.md
```

## pyproject.toml 配置

创建完整的 pyproject.toml，包含：

```toml
[project]
name = "project-name"
version = "0.1.0"
description = "项目描述"
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-asyncio>=0.21",
    "ruff>=0.1",
    "black>=23.0",
    "mypy>=1.0",
]

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"

[tool.ruff]
target-version = "py311"

[tool.black]
target-version = ["py311"]

[tool.mypy]
python_version = "3.11"
strict = true
```

## Makefile 配置

创建 Makefile 包含以下命令：

```makefile
# Colors
YELLOW := $(shell tput setaf 3)
BLUE := $(shell tput setaf 4)
GREEN := $(shell tput setaf 2)
NC := $(shell tput sgr0)

.PHONY: help install install-dev lint format typecheck test clean coverage

help: ## Show this help message
	@echo ""
	@echo "$(BLUE)Python Project$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make $(YELLOW)<target>$(NC)"
	@echo ""
	@echo "$(GREEN)Installation:$(NC)"
	@echo "  install         Install dependencies with uv"
	@echo "  install-dev    Install with dev dependencies"
	@echo ""
	@echo "$(GREEN)Code Quality:$(NC)"
	@echo "  lint           Run ruff check"
	@echo "  format         Run black formatter"
	@echo "  typecheck      Run mypy type check"
	@echo ""
	@echo "$(GREEN)Testing:$(NC)"
	@echo "  test           Run pytest"
	@echo "  coverage       Run tests with coverage"
	@echo ""
	@echo "$(GREEN)Maintenance:$(NC)"
	@echo "  clean          Clean cache files"
	@echo ""

install: ## Install dependencies
	uv sync

install-dev: ## Install with dev dependencies
	uv sync --all-extras

lint: ## Run ruff check
	uv run ruff check src/ tests/

format: ## Run black formatter
	uv run black src/ tests/

typecheck: ## Run mypy type check
	uv run mypy src/

test: ## Run pytest
	uv run pytest

coverage: ## Run tests with coverage
	uv run pytest --cov=src --cov-report=term-missing

clean: ## Clean cache files
	rm -rf .pytest_cache .mypy_cache .ruff_cache build dist *.egg-info
```

## Git Hooks 配置

创建 `hooks/` 目录和以下 hook：

### pre-commit

```bash
#!/bin/bash
# Pre-commit hook

# Run tests
uv run pytest || exit 1

# Run lint
uv run ruff check src/ tests/ || exit 1
```

### post-push（可选）

```bash
#!/bin/bash
# Post-push hook
```

配置 hooks：
```bash
git config core.hooksPath "$(pwd)/hooks"
```

## .gitignore 配置

创建标准的 .gitignore：

```
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
dist/
*.egg-info/
.venv/
venv/
.env
.eggs/
*.egg
.pytest_cache/
.mypy_cache/
.ruff_cache/
.coverage
htmlcov/
.idea/
.vscode/
*.swp
*.swo
```

## 初始化步骤

1. 创建目录结构
2. 创建 pyproject.toml
3. 创建 Makefile
4. 创建 .gitignore
5. 创建 README.md
6. 初始化 git（如果需要）
7. 安装依赖：`uv sync`
8. 配置 Git hooks（使用绝对路径）

## 注意事项

- 所有命令使用 `uv run` 执行（如 `uv run pytest`）
- 包名使用 kebab-case，模块名使用 snake_case
- 源代码放在 `src/` 目录下，不允许放在根目录
- 测试代码放在 `tests/` 目录下
- 优先使用 SQLite 作为数据库
- Git hooks 使用绝对路径配置
