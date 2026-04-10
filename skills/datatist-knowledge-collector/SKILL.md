---
name: datatist-knowledge-collector
description: 当用户想收集知识文档到 knowledge-base 时使用。触发方式：用户说"导入这个文件"、"把这个文档加入知识库"、"收集这个URL的内容"、"抓取这个网页"或类似表达。自动判断内容属于哪个子目录（architecture/dependencies/incidents/runbooks/logs）并导入。
allowed-tools: Read,Write,Edit,Bash,mcp__chrome-devtools__navigate_page,mcp__chrome-devtools__take_snapshot,mcp__chrome-devtools__get_network_request
---

# datatist-knowledge-collector

将文件或 URL 内容导入到 `knowledge-base/` 知识库中，包括图片资源。

## Knowledge-base 目录结构

```
knowledge-base/
├── architecture/       # 系统架构文档
│   └── images/          # 架构图片（架构图、拓扑图等）
├── dependencies/        # 服务依赖关系
│   └── images/          # 依赖图、调用链图
├── incidents/           # 历史故障记录
│   └── images/          # 故障截图、监控图
├── runbooks/            # 操作手册 / wiki
│   └── images/          # 操作截图、流程图
└── logs/                # 日志样例
    └── images/          # 日志截图、错误截图
```

## 工作流程

### 场景1：文件导入

当用户提供一个文件路径时：

1. **读取文件内容**
2. **检查关联文件**：如果文件引用了其他文件（如 import、include、链接），也读取关联内容
3. **判断内容归属**：分析内容属于哪个子目录
4. **内容清洗**：
   - 保留：客观事实、技术细节、设计决策、假设条件、可验证数据
   - 删除：主观判断（如"我认为"、"我觉得"、"这是最好的方案"）
5. **处理图片**（如有）：
   - 复制图片到对应子目录的 `images/` 下
   - 更新文档中的图片引用路径
6. **写入目标位置**

### 场景2：URL 导入

当用户提供 URL 时：

1. 使用 Chrome MCP `navigate_page` + `take_snapshot` 获取页面内容
2. 提取页面标题和主体内容
3. **下载页面中的图片**：
   - 分析页面中所有图片的 URL
   - 使用 `get_network_request` 获取图片内容
   - 保存到对应 `images/` 目录
   - 更新文档中的图片引用为本地路径
4. 同场景1的第3-5步

### 图片处理规则

| 图片类型 | 存放位置 | 命名规则 |
|----------|----------|----------|
| 架构图 | `architecture/images/` | `{文档名}-{序号}.{ext}` |
| 依赖图 | `dependencies/images/` | `{文档名}-{序号}.{ext}` |
| 故障截图 | `incidents/images/` | `{时间戳}-{描述}.{ext}` |
| 操作截图 | `runbooks/images/` | `{操作名}-{序号}.{ext}` |
| 日志截图 | `logs/images/` | `{系统名}-{场景}-{序号}.{ext}` |

## 内容清洗规则

### 保留内容
- 技术选型：框架、库、语言版本
- 架构设计：组件关系、数据流
- 配置参数：端口、路径、环境变量
- 数字证据：性能指标、错误码、版本号
- 设计决策：如"采用 XXX 方案，因为 YYY"
- 假设条件：如"假设 ZZZ 成立"
- 图片本身（通过 AI 分析图片内容）

### 删除内容
- 所有"我认为"、"我觉得"、"相信"、"可能"等主观表达
- 个人评价："好的"、"差的"、"不推荐的"
- 情感词汇："很棒"、"糟糕"、"完美"
- 但：保留设计者的原意表达，如"我们选择 A 而非 B，因为..."

## 文件命名

根据内容类型命名：
- `architecture/` 下：`{系统名}-{组件}.md`，如 `order-service-architecture.md`
- `dependencies/` 下：`{服务名}-dependencies.md`
- `incidents/` 下：`{时间戳}-{问题简述}.md`，如 `20240115-payment-timeout.md`
- `runbooks/` 下：`{操作名}-runbook.md`
- `logs/` 下：`{系统名}-{场景}-sample.md`

## 示例

### 示例1：文件导入

用户输入：`datatist-knowledge-collector /Users/zhaoxin/project/docs/api-design.md`

处理：
```
1. 读取 /Users/zhaoxin/project/docs/api-design.md
2. 分析内容 → 属于 architecture（API 设计文档）
3. 清洗内容：删除"这个设计很优雅，我认为..."等主观内容
4. 检查并复制图片到 architecture/images/
5. 保存到 knowledge-base/architecture/api-design.md
```

### 示例2：URL 导入

用户输入：`datatist-knowledge-collector https://confluence.example.com/pages/viewpage.action?pageId=123`

处理：
```
1. 读取页面内容
2. 分析内容 → 可能属于 architecture 或 runbooks
3. 下载页面图片到对应 images/ 目录
4. 清洗内容
5. 保存到对应目录，更新图片引用
```

## 输出

导入完成后，输出：
- 目标文件路径
- 收集的图片列表
- 内容摘要（保留的关键信息）
- 删除了哪些主观内容（简要说明）
