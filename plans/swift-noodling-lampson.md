# 更新 my-secretary SKILL.md 和创建查询脚本

## 背景

用户希望：
1. 更新 `.claude/skills/my-secretary/SKILL.md` 添加画像功能描述
2. 创建 sh 脚本封装查询，方便 AI 调用时汇总信息

## 实现方案

### 1. 更新 SKILL.md

在现有 SKILL.md 中添加画像功能章节：

```markdown
## 画像管理

# 查看画像（通过姓名搜索）
my-secretary profile get-by-name "张三"

# 通过姓名搜索联系人并查看画像（sh 脚本）
./scripts/profile_lookup.sh "张三"
```

### 2. 创建查询脚本 `scripts/profile_lookup.sh`

功能：接受姓名参数，搜索联系人并返回完整画像信息（供 AI 汇总）

```bash
#!/bin/bash
# 用法: ./profile_lookup.sh "张三"

NAME="$1"
if [ -z "$NAME" ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

# 1. 搜索联系人
CONTACT=$(uv run my-secretary contact list --search "$NAME" | head -20)

# 2. 遍历搜索结果，获取每个联系人的画像信息
# 这里需要先获取 contact_id，然后调用 profile get
```

### 3. 添加新命令 `profile get-by-name`

在 `commands/profile.py` 中添加：

```python
@profile_app.command("get-by-name")
def get_by_name(name: str = typer.Argument(..., help="Contact name")):
    """Search contact by name and view profile"""
    # 搜索联系人
    contacts = db.list_contacts(search=name)
    if not contacts:
        console.print(f"[yellow]No contact found matching '{name}'[/yellow]")
        return

    # 如果只有一个，直接显示画像
    if len(contacts) == 1:
        get(contacts[0].id)
        return

    # 如果多个，让用户选择
    console.print(f"[yellow]Found {len(contacts)} contacts:[/yellow]")
    for c in contacts:
        console.print(f"  {c.id}: {c.name} ({c.category}) - {c.company or '-'}")

    console.print("\n请使用 ID 查询: my-secretary profile get <id>")
```

## 关键文件

1. `.claude/skills/my-secretary/SKILL.md` - 更新文档
2. `scripts/profile_lookup.sh` - 新建脚本
3. `src/my_secretary/commands/profile.py` - 添加 get-by-name 命令

## 验证

1. 添加测试画像数据
2. 运行 `./scripts/profile_lookup.sh "张三"` 验证输出
3. 测试 `my-secretary profile get-by-name "张三"`
