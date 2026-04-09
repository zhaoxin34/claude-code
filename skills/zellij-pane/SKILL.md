---
name: zellij-pane
description: 当用户需要与 Zellij 终端复用器交互、操作 pane、执行命令时使用此技能。特别适合 Claude 与人类协同完成交互式任务，如 docker exec -it xxx -- bash
allowed-tools: Bash(zellij:*)
---

# Zellij Pane Skills

## 概述

这个 skill 封装了 Zellij 终端复用器的底层命令，提供更易用的接口。主要功能包括：

- 创建新的 pane（包括浮动 pane）
- 向 pane 发送文本和按键
- 安全发送密码（不回显）
- 获取 pane 输出内容
- 等待特定提示符
- 关闭 pane

## 使用方法

### 1. 创建 pane

```bash
# 创建右侧 pane
pane_info=$(zellij-pane.sh create right)
pane_id=$(echo "$pane_info" | jq -r '.pane_id')

# 创建下方 pane
pane_info=$(zellij-pane.sh create down)
pane_id=$(echo "$pane_info" | jq -r '.pane_id')

# 创建浮动 pane（带名称和自定义尺寸）
pane_info=$(zellij-pane.sh create float mypane 150 60 1% 5%)
pane_id=$(echo "$pane_info" | jq -r '.pane_id')
```

### 2. 发送命令

```bash
# 发送普通命令（不含回车）
zellij-pane.sh send-text "$pane_id" "ls -la"

# 发送命令并执行（send-text + Enter）
zellij-pane.sh send-command "$pane_id" "ls -la"

# 发送命令并执行（分步）
zellij-pane.sh send-keys "$pane_id" "Enter"

# 发送 Ctrl+C 中断
zellij-pane.sh send-keys "$pane_id" "Ctrl+c"
```

### 3. 安全输入（密码）

```bash
# 使用 write 而非 write-chars，避免命令在日志中暴露
zellij-pane.sh write "$pane_id" "my_secret_password"
```

### 4. 获取输出

```bash
# 获取当前屏幕内容（不含 scrollback）
zellij-pane.sh dump-screen "$pane_id"
```

### 5. 等待提示符

```bash
# 轮询等待特定字符串出现
zellij-pane.sh wait-for "$pane_id" "root@container" --timeout 60
```

### 6. 关闭 pane

```bash
zellij-pane.sh close-pane "$pane_id"
```

## 使用示例

### 进入 Docker 容器并执行命令

```bash
#!/bin/bash

# 创建新 pane
pane_info=$(zellij-pane.sh create right)
pane_id=$(echo "$pane_info" | jq -r '.pane_id')

# 进入容器
zellij-pane.sh send-text "$pane_id" "docker exec -it mycontainer bash"
zellij-pane.sh send-keys "$pane_id" "Enter"

# 等待登录提示
zellij-pane.sh wait-for "$pane_id" "root@"

# 执行命令
zellij-pane.sh send-text "$pane_id" "ps aux | grep java"
zellij-pane.sh send-keys "$pane_id" "Enter"

# 获取输出
sleep 1
zellij-pane.sh dump-screen "$pane_id"

# 关闭 pane
zellij-pane.sh close-pane "$pane_id"
```

### 交互式密码输入

```bash
#!/bin/bash

pane_info=$(zellij-pane.sh create down)
pane_id=$(echo "$pane_info" | jq -r '.pane_id')

# 连接 SSH
zellij-pane.sh send-text "$pane_id" "ssh user@hostname"
zellij-pane.sh send-keys "$pane_id" "Enter"

# 等待密码提示
zellij-pane.sh wait-for "$pane_id" "password:"

# 安全输入密码（不在日志中暴露）
zellij-pane.sh write "$pane_id" "my_secret_password"
zellij-pane.sh send-keys "$pane_id" "Enter"

# 继续交互...
```

## 注意事项

1. **Pane ID 管理**：创建 pane 后会返回 `terminal_<id>` 格式的 ID，后续操作需要指定此 ID

2. **命令异步**：发送命令是异步的，如需获取命令结果，需要适当等待（sleep）后再 dump-screen

3. **只读当前屏幕**：dump-screen 只读取当前屏幕可见内容，不包含 scrollback

4. **超时保护**：wait-for 命令有默认超时（60秒），可自定义

5. **关闭 pane**：完成任务后应该关闭 pane，释放资源
