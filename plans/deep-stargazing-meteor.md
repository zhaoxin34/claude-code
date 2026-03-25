# Pane Title Bar 内容溢出修复计划

## Context

当 `pane_border_status = Top` 时，pane title bar 会占用顶部1行的空间。当前代码虽然在 `get_pos_panes_for_tab` 中减少了 `PositionedPane.height`（用于背景绘制），但在渲染终端内容时仍然使用完整的 `dims.viewport_rows`，导致最后一行内容溢出到相邻的pane（刚好半行）。

## 问题分析

**文件**: `wezterm-gui/src/termwindow/render/pane.rs:317-320`

```rust
let stable_range = match current_viewport {
    Some(top) => top..top + dims.viewport_rows as StableRowIndex,  // 问题：应该 -1
    None => dims.physical_top..dims.physical_top + dims.viewport_rows as StableRowIndex,
};
```

`dims.viewport_rows` 来自 `pane.get_dimensions()`，返回终端的实际行数，没有考虑 pane title bar 占据的1行。

## 修复方案

在 `paint_pane` 函数中，当 `pane_border_status != Off` 时，计算可见行数时减去1行：

1. **文件**: `wezterm-gui/src/termwindow/render/pane.rs`
   - 在 `LineRender` 结构体中添加一个字段 `visible_rows: usize`
   - 在创建 `LineRender` 时计算 `visible_rows = dims.viewport_rows - 1`（当启用pane title bar时）
   - 在计算 `stable_range` 时使用 `visible_rows` 而不是 `dims.viewport_rows`

2. **或者更简单的方案**：
   - 直接在 `stable_range` 计算处添加条件判断
   - 当 `pane_border_status != Off` 时，使用 `dims.viewport_rows.saturating_sub(1)`

## 需要修改的文件

- `wezterm-gui/src/termwindow/render/pane.rs`

## 验证方法

1. 开启多个pane，设置 `pane_border_status = "Top"`
2. 观察上下相邻的pane边界，确认内容不会溢出半行
3. 检查鼠标点击位置是否正确（之前已修复）
4. 运行 `cargo test` 确保没有回归
