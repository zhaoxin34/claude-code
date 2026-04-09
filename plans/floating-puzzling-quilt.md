# K8S 运维 Subagent 实现计划

## Context

用户需要一个 K8S 运维 subagent，通过自然语言对话自动完成：
1. 登录跳板机 (Jumpserver)
2. 选择环境 (test/uat4 等)
3. 在 K8S 上执行运维操作 (查看 pod/logs、发布应用等)

**环境信息已熟悉：**
- 跳板机：69.235.155.204:2222，用户名 zhaoxin
- 环境：test (172.31.7.167), uat4 (120.133.76.20)
- Zellij 交互：通过 floating pane 发送命令和获取输出
- K8S：v1.17.3，namespace 包括 wolf, bigdata, ai, tool, store 等

---

## 目录结构

项目位置：`/Volumes/data/working/datatist/datatist-ops-k8s/k8s-ops-agent/`

```
k8s-ops-agent/
├── src/
│   └── k8s_ops_agent/
│       ├── __init__.py
│       ├── cli.py              # CLI 入口 (click)
│       ├── session/
│       │   ├── __init__.py
│       │   ├── zellij_manager.py    # Zellij pane 管理
│       │   └── jumpserver_login.py  # 跳板机登录
│       ├── parser/
│       │   ├── __init__.py
│       │   ├── intent_parser.py     # 意图解析
│       │   └── kubectl_builder.py   # kubectl 命令构建
│       ├── executor/
│       │   ├── __init__.py
│       │   └── kubectl_executor.py   # kubectl 命令执行
│       └── state/
│           ├── __init__.py
│           └── state_manager.py     # 状态持久化
├── tests/
│   └── ...
├── config/
│   └── environments.yaml        # 环境配置
├── Makefile
└── README.md
```

---

## 核心组件设计

### 1. ZellijPaneManager

管理多个 floating pane：
- `create_pane(env)` - 创建 pane 并执行 SSH 登录
- `write_to_pane(pane_id, text)` - 发送文本
- `send_key(pane_id, key)` - 发送按键 (Enter/Ctrl 等)
- `dump_screen(pane_id)` - 获取屏幕输出
- `close_pane(pane_id)` - 关闭 pane

### 2. JumpServerLogin

跳板机登录流程：
1. 创建 floating pane，执行 SSH 登录
2. 等待菜单出现，发送 `p` 查看主机
3. 发送 `//uat` 搜索环境
4. 发送环境 ID 登录

### 3. IntentParser

自然语言解析，支持模式匹配：
- `查看 xxx namespace 的 pod` → `kubectl get pods -n xxx`
- `查看 xxx pod 的日志` → `kubectl logs xxx -n xxx`
- `扩容 xxx 到 N 副本` → `kubectl scale deployment xxx --replicas=N`

### 4. StateManager

JSON 文件持久化状态：
- 当前环境
- 每个环境的 pane_id
- 最后更新时间

---

## 凭证管理

**跳板机密码**：暂时使用 ~/.env 中的明文密码
**未来改进**：使用 keyring 系统存储

---

## 使用方式

```bash
# 连接环境
k8s-ops-agent connect uat4

# 自然语言操作
k8s-ops-agent exec "查看 wolf namespace 的 pod"
k8s-ops-agent exec "查看 wolf api pod 最近100行日志"
k8s-ops-agent exec "扩容 nacos 到 3 副本"

# 断开连接
k8s-ops-agent disconnect uat4
```

---

## 关键文件

- 参考项目 Python 代码风格：`k8s_package_center/script/merge_yaml.py`
- 参考 Makefile 规范：`k8s_package_center/Makefile`
- 参考环境配置：`k8s_package_center/project/idc-uat4/idc-uat4.config.merged.yaml`

---

## 实现步骤

1. 创建项目目录结构
2. 实现 ZellijPaneManager (zellij action 封装)
3. 实现 JumpServerLogin (跳板机登录流程)
4. 实现 IntentParser (自然语言解析)
5. 实现 KubectlBuilder (命令构建)
6. 实现 KubectlExecutor (命令执行)
7. 实现 StateManager (状态持久化)
8. 实现 CLI 入口 (click)
9. 编写 Makefile
10. 编写 tests

---

## 验证方式

1. `make format` 格式化代码
2. `make type-check` 类型检查
3. `make lint` 代码检查
4. `make test` 运行测试
5. 手动测试：
   - `k8s-ops-agent connect uat4` 连接环境
   - `k8s-ops-agent exec "查看 wolf namespace 的 pod"` 执行操作
   - `k8s-ops-agent disconnect uat4` 断开连接
