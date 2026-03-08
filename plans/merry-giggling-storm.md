# 计划：Repository 根目录支持与 Sync 命令

## Context

**问题**: 知识库中的文件被删除或更名后，memory 中的记录还是老的，会产生脏数据。

**解决方案**:
1. 给 Repository 增加 `root_path` 属性，用于指定仓库的根目录
2. 导入时只能导入这个目录下的文件
3. 文件路径存储为相对路径
4. 去掉 `ingest` 命令，新增 `sync` 命令
5. `sync` 命令能自动处理删除和更名的文件

---

## 实现步骤

### 1. 修改 Repository 实体
**文件**: `src/memory/entities/repository.py`

- 添加 `root_path: Path` 字段（**必填**）
- 添加 `pattern: str | None` 字段（可选，用于过滤文件，如 `*.md`）

### 2. 修改 RepositoryManager
**文件**: `src/memory/service/repository.py`

- `create_repository()` 增加 `root_path`（必填）和 `pattern` 参数
- 修改 `delete_repository()` 同步删除物理文件（可选）

### 3. 修改 Document 实体
**文件**: `src/memory/entities/document.py`

- 将 `source_path` 改为始终存储相对路径
- 添加 `relative_path` 字段明确表示相对路径

### 4. 修改 CLI 命令
**文件**: `src/memory/interfaces/cli.py`

- **移除** `ingest` 命令
- **新增** `sync` 命令:
  - 必须指定 `--repository`（因为需要知道根目录）
  - 扫描仓库根目录下的所有文件
  - 对比现有记录：
    - **新增**: 文件存在但记录中没有 → 导入
    - **更新**: 文件存在且 MD5 变化 → 更新
    - **删除**: 记录中有但文件不存在 → 删除记录
    - **重命名**: 记录中有相似内容但路径变化 → 更新路径

### 5. 修改 IngestionPipeline
**文件**: `src/memory/pipelines/ingestion.py`

- 修改 `ingest_document()` 支持更新现有文档
- 增加 `delete_document()` 方法
- 支持相对路径处理

### 6. 修改 repo 命令
**文件**: `src/memory/interfaces/cli.py`

- `repo create` 增加 `--root-path` 和 `--pattern` 选项

---

## 关键文件

| 文件 | 修改内容 |
|------|----------|
| `src/memory/entities/repository.py` | 添加 root_path, pattern 字段 |
| `src/memory/entities/document.py` | 添加 relative_path 字段 |
| `src/memory/service/repository.py` | create_repository 增加参数 |
| `src/memory/pipelines/ingestion.py` | 支持更新和删除 |
| `src/memory/interfaces/cli.py` | 移除 ingest，新增 sync |

---

## 验证方式

1. 创建一个带根目录的仓库：`memory repo create myrepo --root-path /path/to/docs`（root_path 必填）
2. 运行 sync 命令：`memory sync --repository myrepo`
3. 测试新增文件自动导入
4. 测试删除文件 → sync 自动清理记录
5. 测试文件更名 → sync 自动更新记录
