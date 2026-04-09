# datatist 目录 LLM Wiki 改造计划

## Context

当前 datatist 目录包含工作相关的原始笔记，全部属于 "raw" 类型，未经过 LLM 编译整理。根据 Karpathy 的 LLM Wiki 方案，需要建立 raw/wiki/output 三层架构。

## 当前结构

```
datatist/
├── 会议纪要/
│   ├── 2026-03-26 - 易观.md
│   └── 2026-03-27 继续讨论和易观的合作.md
├── 面试记录/
│   └── 上海电商 - 戚爱强.md
├── 2026工作总结提交人.md
├── Wolf K8s操作经验.md
├── AI 增强工程师 面试问题.md
└── 工作总结模板.md
```

## 改造后目标结构

```
datatist/
├── raw/                          # 原始素材（只读）
│   ├── 会议纪要/
│   │   ├── 2026-03-26 - 易观.md
│   │   └── 2026-03-27 继续讨论和易观的合作.md
│   ├── 面试记录/
│   │   └── 上海电商 - 戚爱强.md
│   ├── 2026工作总结提交人.md
│   ├── Wolf K8s操作经验.md
│   ├── AI 增强工程师 面试问题.md
│   └── 工作总结模板.md
├── wiki/                         # LLM 编译的知识库
│   ├── 人员档案/                 # 面试过的人
│   ├── 合作项目/                 # 易观合作项目
│   ├── 工作规范/                 # 工作总结模板等
│   └── index.md                  # 主题索引
└── output/                       # 查询和分析结果
```

## 实施步骤

1. **创建目录结构**
   - 创建 `datatist/raw/` 目录
   - 创建 `datatist/wiki/` 目录及其子目录
   - 创建 `datatist/output/` 目录

2. **迁移现有文件到 raw/**
   - 移动所有现有文件到 `datatist/raw/` 下，保持原有子目录结构

3. **创建 wiki 层**
   - 创建 `wiki/index.md` 作为主题索引
   - 创建子目录结构

4. **更新 CLAUDE.md**
   - 记录 datatist 目录的特殊结构

## 关键文件

- `/Volumes/data/working/my-obsidian/CLAUDE.md` - 更新知识库组织规范
- `/Volumes/data/working/my-obsidian/datatist/` - 改造此目录

## 验证方式

- 确认 `ls datatist/` 显示 raw/wiki/output 三个目录
- 确认所有原始笔记在 `datatist/raw/` 下
- 确认 wiki 目录结构已建立
