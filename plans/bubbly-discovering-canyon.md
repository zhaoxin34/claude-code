# 给活动窗口添加边框 - 实现计划

## 背景

用户想要给 macOS 上当前活动的窗口添加一个可见的边框。高亮当前窗口是一个常见的生产力需求，可以帮助用户快速识别焦点所在的窗口。

## 可行性分析

- **Hammerspoon 原生不支持**窗口边框 API
- **推荐方案**：使用 `hs.canvas` 在活动窗口周围绘制矩形叠加层
- **替代方案**：如果使用 yabai，可以利用 yabai 的边框功能（需要额外配置）

## 实现方案

### 创建新模块 `modules/windowBorder.lua`

```lua
local obj = {}

-- 配置
obj.borderWidth = 6           -- 边框宽度 (用户选择: 粗)
obj.borderColor = {          -- 边框颜色 (用户选择: 紫色 #8000FF)
    red = 0.5, green = 0, blue = 1.0, alpha = 1
}
obj.autoHideDelay = 1.5     -- 自动隐藏延迟（秒）

obj.canvas = nil
obj.hideTimer = nil

-- 显示边框
function obj:showBorder()
    local win = hs.window.focusedWindow()
    if not win then return end

    -- 隐藏之前的边框
    self:hideBorder()

    local frame = win:frame()
    local screen = win:screen()
    local screenFrame = screen:frame()

    -- 计算相对于屏幕的坐标
    local x = frame.x
    local y = screenFrame.h - frame.y - frame.h

    -- 创建 canvas
    self.canvas = hs.canvas.new({
        x = x - self.borderWidth,
        y = y - self.borderWidth,
        w = frame.w + self.borderWidth * 2,
        h = frame.h + self.borderWidth * 2
    })

    self.canvas:behaviorCanJoinAllSpaces("normal")
    self.canvas:level("floating")

    self.canvas[1] = {
        type = "rectangle",
        strokeColor = self.borderColor,
        strokeWidth = self.borderWidth,
        fillColor = { alpha = 0 }
    }

    self.canvas:show()

    -- 设置自动隐藏定时器
    if self.hideTimer then self.hideTimer:stop() end
    self.hideTimer = hs.timer.doAfter(self.autoHideDelay, function()
        self:hideBorder()
    end)
end

-- 隐藏边框
function obj:hideBorder()
    if self.canvas then
        self.canvas:delete()
        self.canvas = nil
    end
end

-- 初始化
function obj:init()
    -- 监听窗口焦点变化
    hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function()
        self:showBorder()
    end)

    -- 监听窗口移动/调整大小
    hs.window.filter.default:subscribe(hs.window.filter.windowMoved, function()
        self:showBorder()
    end)
end

return obj
```

### 修改 `init.lua`

在 `init.lua` 中加载新模块：

```lua
local windowBorder = require("modules.windowBorder")
windowBorder:init()
```

## 关键文件

- 新建：`/Users/zhaoxin/.hammerspoon/modules/windowBorder.lua`
- 修改：`/Users/zhaoxin/.hammerspoon/init.lua`

## 功能特性

1. **自动显示** - 窗口获得焦点时自动显示边框
2. **自动隐藏** - 1.5秒后自动隐藏（或可配置为保持显示）
3. **跟随窗口** - 窗口移动时边框跟随
4. **多空间兼容** - 边框可以在所有 Space 显示

## 测试方法

1. 重载 Hammerspoon 配置：`hs.reload()`
2. 切换不同应用窗口，观察边框是否正确显示
3. 调整 `borderWidth` 和 `borderColor` 自定义样式
