# 运维规范模板 - Namespace 与 PVC

## 背景

为了规范化 datatist 公司的运维工作，通过分析 dev-wolf 现有配置，归纳出 Namespace 和 PVC 的标准 annotations/labels 规范，用于指导新服务上架。

---

## 一、Namespace 规范模板

### metadata.annotations 必须字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `auther` | 创建者用户名 | `zhaoxin` |
| `auther.mail` | 创建者邮箱 | `xin.zhao@datatist.com` |
| `corp` | 公司标识 | `datatist` |
| `package` | 产品/服务名称 | `wolf` |

### metadata.labels 必须字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `corp` | 公司标识 | `datatist` |
| `package` | 产品/服务名称 | `wolf` |

### Namespace 模板示例

```yaml
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    auther: <用户名>
    auther.mail: <邮箱>
    corp: datatist
    package: <产品名>
  labels:
    corp: datatist
    package: <产品名>
  name: <namespace名称>
```

---

## 二、PVC 规范模板

### metadata.annotations 必须字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `auther` | 创建者用户名 | `zhaoxin` |
| `auther.mail` | 创建者邮箱 | `xin.zhao@datatist.com` |
| `corp` | 公司标识 | `datatist` |
| `package` | 产品/服务名称 | `wolf` |

### metadata.labels 必须字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `corp` | 公司标识 | `datatist` |
| `package` | 产品/服务名称 | `wolf` |
| `usage` | 存储用途 | `dev-wolf-config` |

### 常用 usage 命名规范

| usage | 用途说明 | accessModes |
|-------|----------|-------------|
| `<name>-config` | 配置文件存储 | ReadOnlyMany |
| `<name>-package` | 安装包存储 | ReadOnlyMany |
| `<name>-script` | 脚本存储 | ReadWriteMany |
| `<name>-software` | 软件存储 | ReadOnlyMany |
| `<name>-upload` | 上传文件存储 | ReadWriteMany |

### spec 规范

- `accessModes`: 根据用途选择 `ReadOnlyMany`（只读多路）或 `ReadWriteMany`（读写多路）
- `resources.requests.storage`: 建议 10Gi 起
- `selector.matchLabels`: 必须包含 `corp`、`package`、`usage` 用于 PV 绑定

### PVC 模板示例

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    auther: <用户名>
    auther.mail: <邮箱>
    corp: datatist
    package: <产品名>
  labels:
    corp: datatist
    package: <产品名>
    usage: <name>-<用途>
  name: <pvc名称>
  namespace: <namespace名称>
spec:
  accessModes:
    - ReadOnlyMany  # 或 ReadWriteMany
  resources:
    requests:
      storage: 10Gi  # 可调整
  selector:
    matchLabels:
      corp: datatist
      package: <产品名>
      usage: <name>-<用途>
```

---

## 三、后续任务

- [ ] 完善 Service 模板规范
- [ ] 完善 Deployment 模板规范
- [ ] 更新 SKILL.md 文档

---

## 验证方式

创建完成后执行以下命令验证：
```bash
kubectl get <resource> <name> -n <namespace> -o yaml
```
检查 annotations 和 labels 是否符合规范。
