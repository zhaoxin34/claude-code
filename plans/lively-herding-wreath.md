# 计划：Neovim 选中代码发送到右侧 Claude pane

## 需求
在 Neovim 可视模式选中代码后，按 `Ctrl+\` 自动复制选中文本并发送到右侧的 Claude pane。

## 实现方案

### 核心逻辑
1. 在 Neovim 中创建 Lua 函数，绑定 `Ctrl+\` 快捷键
2. 可视模式下获取选中文本
3. 使用 `pbpaste` 读取剪贴板内容（用户先用 Ctrl+C 复制）
4. 聚焦到右侧 pane
5. 发送文本 + 提示语

### 关键点
- Zellij 没有直接向指定 pane 发送文本的命令，需要：先 `move-focus right` 聚焦，再 `write-chars` 发送
- 需要处理文本中的特殊字符（如换行符）

### 修改文件
- `nvim/lua/config/keymaps.lua` 或创建新文件 `nvim/lua/config/send_to_claude.lua`

### 实现步骤
1. 创建 Lua 函数 `send_selection_to_claude()`
2. 在可视模式下使用 `v` 模式绑定 `Ctrl+\`
3. 函数逻辑：
   - 执行 `zellij action move-focus right` 聚焦右侧
   - 执行 `zellij action write-chars "$(pbpaste)"` 发送剪贴板内容
   - 执行 `zellij action write-chars "\n\n解释这段代码:\n"` 发送提示语

## 验证
1. 在 Neovim 中打开任意代码文件
2. 可视模式选中一段代码
3. 按 Ctrl+\
4. 验证右侧 Claude pane 收到文本并开始解释
