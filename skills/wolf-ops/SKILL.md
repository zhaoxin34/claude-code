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
