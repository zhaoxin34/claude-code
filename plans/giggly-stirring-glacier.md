# 计划：增加设置pane相对大小的Lua API

## 背景/问题

目前只有 `wezterm.action.AdjustPaneSize` 可以调整pane大小，但存在以下限制：
1. 只能调整当前活跃pane的大小
2. 是快捷键操作，不是Lua API方法
3. 不能指定pane id来调整任意pane的大小

用户需要：在pane对象上添加一个相对大小调整的API，可指定任意pane id。

## 关键文件

1. **Lua API定义**: `lua-api-crates/mux/src/pane.rs` - 添加新方法
2. **Mux实现**: `mux/src/tab.rs` - `adjust_pane_size` 方法（需支持通过pane_id调用）
3. **Codec**: `codec/src/lib.rs` - 已有 `AdjustPaneSize` 结构体（包含pane_id）

## 实现方案

### API设计

```lua
pane:adjust_size(direction, amount)
-- direction: "Left" | "Right" | "Up" | "Down"
-- amount: 调整的单元格数（正数扩大，负数缩小）
```

### 实现步骤

1. **修改 `lua-api-crates/mux/src/pane.rs`**
   - 添加 `adjust_size(direction, amount)` 方法
   - 通过pane id获取对应tab，调用tab的adjust_pane_size

2. **修改 `mux/src/tab.rs`**
   - 添加 `adjust_pane_size_by_id(pane_id, direction, amount)` 方法
   - 复用现有的 `adjust_pane_size` 逻辑，通过pane_id定位到对应pane

### 复用现有代码

- Codec中已有 `AdjustPaneSize { pane_id, direction, amount }` 结构体
- CLI `adjust-pane-size` 已有通过pane_id调整的实现逻辑
- 只需将其暴露为Lua API

## 验证方案

1. 运行 `cargo check` 确保编译通过
2. 编写Lua测试脚本验证API可用性
3. 测试指定不同pane id时的行为
