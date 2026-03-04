# 联系人与事件管理系统实现计划

## 1. 项目结构

```
my-secretary/
├── src/
│   └── my_secretary/
│       ├── __init__.py
│       ├── cli.py          # 命令行入口
│       ├── db.py           # 数据库操作
│       ├── models.py       # 数据模型
│       └── commands/       # 子命令
│           ├── __init__.py
│           ├── contact.py  # 联系人相关命令
│           └── event.py    # 事件相关命令
├── tests/
│   └── ...
├── pyproject.toml
├── uv.lock
└── Makefile
```

## 2. 数据库设计

### 联系人表 (contacts)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| name | TEXT | 姓名 |
| category | TEXT | 类别：work/friend/family (固定三类) |
| company | TEXT | 公司（可选） |
| position | TEXT | 职位（可选） |
| phone | TEXT | 电话（可选） |
| email | TEXT | 邮箱（可选） |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

### 事件表 (events)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| contact_id | INTEGER | 外键，关联联系人 |
| type | TEXT | 类型：用户自定义（email/chat/phone/meeting/微信/钉钉/线下等） |
| subject | TEXT | 主题 |
| content | TEXT | 内容摘要 |
| occurred_at | DATETIME | 发生时间 |
| created_at | DATETIME | 创建时间 |

## 3. CLI 命令设计

```bash
# 联系人命令
my-secretary contact add --name "张三" --category work --company "某公司" --email "zhangsan@example.com"
my-secretary contact list                              # 列出所有联系人
my-secretary contact list --category work               # 按类别筛选
my-secretary contact get <id>                          # 查看联系人详情
my-secretary contact update <id> --name "新名字"
my-secretary contact delete <id>

# 事件命令
my-secretary event add --contact 1 --type meeting --subject "项目讨论" --content "讨论了xxx"
my-secretary event list                                # 列出所有事件
my-secretary event list --contact 1                    # 某联系人的事件
my-secretary event list --type email                    # 按类型筛选
my-secretary event get <id>
my-secretary event update <id> --subject "新主题"
my-secretary event delete <id>

# 统计命令
my-secretary stats                     # 查看统计信息

# 搜索功能
my-secretary search "关键词"            # 搜索事件内容
```

## 4. 实现步骤

1. **项目初始化** - 创建 pyproject.toml，配置 uv
2. **数据库模块** - 实现 SQLite 连接和表初始化
3. **数据模型** - 定义 Contact 和 Event 类
4. **联系人命令** - 实现 contact 子命令
5. **事件命令** - 实现 event 子命令
6. **统计功能** - 实现基本统计
7. **测试** - 编写单元测试

## 5. 验证方式

- 运行 `uv run my-secretary --help` 查看帮助
- 添加测试联系人：`uv run my-secretary contact add --name "测试" --category work`
- 查看联系人列表：`uv run my-secretary contact list`
- 添加测试事件并查询
