---
name: k8s-ops
description: 当需要操作k8s集群
allowed-tools: Bash(kubectl:*)
---

# 操作k8s集群

## 获得某个$namespace下的所有pod

* params in:
  * namespace: which namespace to get pod

```bash
kubectl get pod -n $namespace
```

## 获得某个namespace下的pod的yaml配置信息

* params in:
  * namespace: which namespace to get pod
  * pod_name: which pod name to get 

```bash
kubectl get pod -n $namepsace $pod_name -o yaml
```

## 查看某个pod、statfulset、deployment、ingress的状态
