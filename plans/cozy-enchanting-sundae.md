# Zellij Pane Skill (`zellij-pane`)

## Context

用户需要创建一个与 Zellij 终端复用器交互的 skill，用于 AI 与人类协同完成交互式任务（如 `docker exec -it xxx -- bash`）。当前 `zellij action` 命令较为底层，使用不便，需要封装成更易用的形式。

**需求明确：**
- Skill 名称：`zellij-pane`
- Pane 生命周期：Claude 完全控制
- 使用场景：批量执行 + 实时交互
- 密码输入：支持安全隐藏输入
- 完成判断：检测特定退出提示
- Scrollback：只查看当前屏幕

## 技术方案

### 文件结构
```
zellij-pane/
├── SKILL.md                    # 技能定义
└── scripts/
    └── zellij-helper.sh         # 封装脚本
```

### 核心功能

| 功能 | Zellij 命令 | 说明 |
|------|------------|------|
| 创建 pane | `new-pane [-d <direction>]` | direction: right/down |
| 发送文本 | `write-chars <text>` | 写入文本（不含回车） |
| 发送按键 | `send-keys <key>` | Enter, Ctrl+C, Ctrl+D 等 |
| 发送密码 | `write` (隐蔽) | 使用 `zellij action write` 不回显 |
| 等待提示 | `dump-screen` + grep | 轮询检测退出提示 |
| 关闭 pane | `close-pane` | 关闭当前 pane |
| 焦点切换 | `focus-next-pane`, `move-focus` | 切换焦点 |

### 关键实现

1. **Pane ID 管理**：创建时捕获返回的 `terminal_<id>`，后续操作指定 `--pane-id`

2. **安全输入**：使用 `write` 而非 `write-chars`，避免命令在日志中暴露

3. **退出检测**：轮询 `dump-screen` 直到检测到特定字符串（如 `exit`、`logout`、特定提示符）

4. **超时保护**：交互模式设置超时，避免无限等待

### SKILL.md 结构

```yaml
---
name: zellij-pane
description: 当用户需要与 Zellij 终端复用器交互、操作 pane、执行命令时使用...
---
```

**使用流程：**
1. 用户触发 skill
2. Claude 使用 `zellij-helper.sh` 创建 pane
3. 发送命令并处理输出
4. 交互完成后关闭 pane

### 验证方案

1. 测试创建/关闭 pane
2. 测试发送命令并获取输出
3. 测试交互模式（docker exec -it）
4. 测试密码安全输入
