# 计划：修改 tabline 显示自定义标题

## 背景

用户希望在 tabline 插件中，如果存在 `custom_title` (通过 `pane:set_user_var` 设置)，则显示自定义标题，否则显示当前目录 (cwd)。

## 关键文件

- `/Users/zhaoxin/.config/wezterm/config/tabline.lua`

## 实现方案

在 `tabline.lua` 中添加一个函数来获取自定义标题或 cwd（只显示最后一层目录），并在 tab_active 中使用。

### 修改内容

1. 在 tabline.lua 顶部添加函数 `get_tab_title`:
```lua
local function get_tab_title(tab)
  local pane = tab.active_pane
  local user_vars = pane:get_user_vars()
  local custom_title = user_vars.custom_title

  -- 优先使用自定义标题
  if custom_title and custom_title ~= '' then
    return custom_title
  end

  -- 否则使用 cwd，只显示最后一层目录
  local cwd = pane:get_current_working_dir()
  if cwd then
    -- 从 /path/a/b 只提取 b
    return cwd:match("([^/]+)$") or cwd
  end
  return ''
end
```

2. 修改 tab_active 配置:
```lua
tab_active = {
  'index',
  { 'parent', padding = 0 },
  '/',
  { get_tab_title, padding = { left = 0, right = 1 }, max_length = 40 },
  { 'zoomed', padding = 0 },
},
```

3. tab_inactive 保持原有配置不变

## 验证方式

1. 重启 WezTerm
2. 使用 `Leader + r` 设置自定义标题
3. 观察 tabline 是否显示自定义标题而不是 cwd
4. 重置 custom_title (设为空) 后应显示回 cwd
