---
name: wolf-ops
description: 当需要对Wolf产品进行运维操作或者询问运维wolf系统的运维信息时，调用本SKILL，如查看某namespace运行的pod情况，重启某个namespace下的pod。
allowed-tools: Bash(kubectl:*)
---

# Wolf系统简介

Wolf是我公司开发的营销系统简介，他所采用的技术架构主要如下

- Spring Cloud
- Mysql
- Redis
- elasticsearch 简称es
- Hadoop
- Spark

# 原则

- 每次执行命令必须打印执行的命令，以便后续审核

## Wolf系统部署的namespace简介

namespace主要如下

- dev-wolf: 放置spring cloud、nginx等业务组件
- store：放置mysql、redis、es等组件
- bigdata-test: 放置hadoop、spark、hive等组件

# 运维指导

## 示例1：获得wolf空间下的所有pod

```bash
kubectl get pod -n dev-wolf
```

## 示例2：查询Pod使用的JDK版本

```bash
# 1. 先查询目标服务的Pod名称
kubectl get pod -n dev-wolf | grep wolf-manager-v4

# 2. 查看Pod的环境变量，获取JDK版本
kubectl exec -it <pod-name> -n dev-wolf -- env | grep -i java

```

**常用查询命令**：

```bash
# 查看所有服务
kubectl get svc -n dev-wolf

# 查看特定服务的Pod
kubectl get pod -n dev-wolf | grep <服务名>

# 查看Pod详情（包括镜像、环境变量等）
kubectl describe pod <pod-name> -n dev-wolf

# 进入Pod内部执行命令
kubectl exec -it <pod-name> -n dev-wolf -- /bin/bash
```
