# 修复 Spring Boot 3.x 升级后 Netty 兼容性问题

## Context

项目从 Spring Boot 2.x 升级到 3.x 后，WebClient 调用下游服务时出现错误：

```
io.netty.handler.codec.EncoderException: java.lang.IllegalStateException: unexpected message type: UnpooledHeapByteBuf, state: 0
```

错误发生在 LicenseCheckFilter 调用 `WOLF-SERVICE-USER` 服务的许可证校验接口时。

## 问题分析

1. **Reactor Netty 版本变化**: Spring Boot 2.x 使用 Reactor Netty 0.9.x，Spring Boot 3.x 使用 1.2.x
2. **Netty Handler 兼容性问题**: 当前代码使用 Netty 原生的 `ReadTimeoutHandler` 和 `WriteTimeoutHandler`，这种方式在新版本中可能存在问题
3. **连接池配置**: 需要确保与 Spring Boot 3.x 兼容
4. **下游服务因素**: 可能与下游服务响应有关，需要隔离测试

## 方案：创建测试子工程重现问题

用户建议创建 `wolf-manager-v4-test` 子工程来重现问题。

### 步骤 1: 创建测试子工程

在父 pom 中添加模块：
```xml
<module>wolf-manager-v4-test</module>
```

创建 `wolf-manager-v4-test` 子工程，包含：
- 模拟一个简单的下游 HTTP 服务
- 提供 `/service/user/license/licenseExpired.do` 接口
- 可以模拟各种异常响应（延迟、错误格式等）

### 步骤 2: 修改 Gateway 调用测试服务

在测试环境中，让 Gateway 调用本地测试服务而不是真实的 WOLF-SERVICE-USER：
- 可以通过配置 Nacos 服务发现，或者
- 直接使用 HTTP 地址调用测试服务

### 步骤 3: 重现问题

启动测试服务和 Gateway，逐步排查：
1. 正常调用是否能成功
2. 模拟异常响应是否能重现相同错误
3. 逐步缩小问题范围

### 步骤 4: 修复并验证

根据重现的问题进行修复，然后验证。

## 关键文件

- `wolf-manager-v4-gateway/src/main/java/com/datatist/cloud/gateway/config/WebClientConfig.java` - 可能需要修改
- 新建: `wolf-manager-v4-test/` - 测试子工程

## 验证方法

1. 启动测试服务和 Gateway
2. 观察是否能重现 `UnpooledHeapByteBuf` 错误
3. 修复后确认问题消失
