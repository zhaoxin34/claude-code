# 合并 Wezterm PR #7673 计划

## 背景

用户想要合并 PR #7673（添加 per-pane title bars 功能），但没有合并 PR 的经验。

**PR 信息：**
- 作者：fireboy1919
- 标题分支：`feat/pane-border-status`
- 目标分支：`main`
- 状态：MERGEABLE（可以合并）
- 改动：+586 行，-7 行

## 合并方案

有三种方式可以合并这个 PR：

### 方式 1：通过 GitHub UI 合并（推荐新手）
直接在 GitHub 网页上点击 "Merge pull request" 按钮。

**优点**：简单，不需要命令行操作
**缺点**：更改会直接进入 upstream，不经过你的 fork

### 方式 2：通过 gh CLI 合并
```bash
gh pr merge 7673 --repo wezterm/wezterm --admin --merge
```

**优点**：一行命令完成
**缺点**：同上，直接合并到 upstream

### 方式 3：拉到本地测试后合并（推荐）
1. 从 upstream 拉取 PR 分支到本地
2. 在本地测试
3. 推送到自己的 fork
4. 通过 PR 或者直接推送

**优点**：可以先测试代码，确保没问题再合并
**缺点**：步骤稍多

## 推荐步骤

由于这是你第一次合并 PR，建议按以下步骤：

1. **拉取 PR 到本地测试**
   ```bash
   # 确保本地 main 是最新的
   git fetch upstream
   git checkout main
   git merge upstream/main

   # 创建本地分支并拉取 PR
   git fetch upstream pull/7673/head:pr-7673
   git checkout pr-7673
   ```

2. **运行测试验证**
   ```bash
   cargo test -p wezterm-gui
   cargo check
   ```

3. **推送到你的 fork**
   ```bash
   git push origin pr-7673
   ```

4. **在 GitHub 上创建 PR**（如果你想先测试）
   或者直接合并到 upstream

## 关于 Claude Code 的 GitHub App

Claude Code 的 GitHub App **不能**帮你合并 PR，它主要用于：
- 代码审查
- 回答关于仓库的问题
- 帮你理解代码

合并 PR 仍然需要你通过 GitHub 网页、gh CLI 或 git 命令完成。

## 确认结果

用户选择：**拉到本地测试后合并**

## 具体执行步骤

### 步骤 1: 确保本地 main 分支最新
```bash
cd /Volumes/data/working/life/wezterm
git fetch upstream
git checkout main
git merge upstream/main
```

### 步骤 2: 拉取 PR 分支到本地
```bash
git fetch upstream pull/7673/head:pr-7673
git checkout pr-7673
```

### 步骤 3: 运行测试验证
```bash
# 快速类型检查
cargo check

# 运行相关测试
cargo test -p wezterm-gui
```

### 步骤 4: 推送到你的 fork
```bash
git push origin pr-7673
```

### 步骤 5: 在 GitHub 上创建 PR 或合并
- 方案 A：在你的 fork 上创建 PR，然后合并到 upstream
- 方案 B：直接在 upstream 上合并（需要权限）

## 验证方法

1. `cargo check` - 确保代码能编译
2. `cargo test -p wezterm-gui` - 运行 GUI 相关测试
