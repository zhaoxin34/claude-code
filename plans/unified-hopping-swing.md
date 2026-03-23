# 部署验证脚本化计划

## 背景

当前 `deploy-ops.md` 中的 6.1, 6.2, 6.3 验证步骤（检查文件服务器和 K8s Pod 内的 jar 包）放在文档中不够标准化，且使用时间戳比对不够可靠。

## 改进目标

1. 创建 `deploy-verify.sh` 校验脚本，使用 md5sum 代替时间戳比对
2. 修改 `deploy.sh`，在部署完成后自动调用校验脚本
3. 更新 `deploy-ops.md`，移除已脚本化的验证章节

## 实现方案

### 1. 创建 `scripts/deploy-verify.sh`

功能：
- 接收参数：`<module_name>` `<version>` `<namespace>`
- 校验文件服务器上的 jar 包 md5sum
- 校验 K8s Pod 内加载的 jar 的 md5sum
- 对比两者是否一致，输出校验结果
- 支持等待 Pod 重启完成后再校验

```bash
# 用法
./deploy-verify.sh <module_name> <version> [namespace]
# 示例
./deploy-verify.sh wolf-service-user branch_cloud-parent-upgrade dev-wolf
```

### 2. 修改 `deploy.sh`

在步骤 3 (K8s 部署) 完成后，增加一步调用校验脚本：
- 等待 Pod 重启完成
- 调用 `deploy-verify.sh` 进行 md5sum 校验
- 如果校验失败，提示用户手动处理

### 3. 更新 `deploy-ops.md`

- 移除 6.1, 6.2, 6.3 章节
- 简化为：部署后自动校验，用户只需关注脚本输出

## 关键文件

- `.claude/skills/wolf-deployment/scripts/deploy-verify.sh` (新建)
- `.claude/skills/wolf-deployment/deploy.sh` (修改)
- `.claude/skills/wolf-deployment/deploy-ops.md` (修改)

## 验证方式

1. 运行 `./deploy.sh -m wolf-cloud-services/wolf-service-user`
2. 观察脚本自动执行 md5sum 校验
3. 确认输出清晰展示校验结果
