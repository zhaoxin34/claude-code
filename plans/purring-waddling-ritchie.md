# Spring Boot 3.x 升级计划

## 升级目标
将 parent 从 `1.6.2-SNAPSHOT` 升级到 `1.6.3-SNAPSHOT`，涉及 Spring Boot 从 2.x 升级到 3.5.9。

## 当前版本 vs 目标版本

| 组件 | 当前版本 | 目标版本 | 状态 |
|------|---------|---------|------|
| Spring Boot | 2.x (推测) | 3.5.9 | ❌ 不兼容 |
| Spring Boot Admin | 2.1.6 | 3.x | ❌ 需升级 |
| Knife4j | 2.0.9 | 4.x | ❌ 需升级 |
| Springfox | 2.9.2 | - | ❌ 移除/替换 |
| Spring Cloud Alibaba | 2.1.4.RELEASE | 2025.0.0.0 | ❌ 需升级 |

## 升级步骤

### 步骤 1: 更新根 pom.xml parent 版本
```xml
<parent>
    <groupId>com.datatist</groupId>
    <artifactId>datatist-cloud-parent</artifactId>
    <version>1.6.3-SNAPSHOT</version>  <!-- 从 1.6.2-SNAPSHOT 改为 1.6.3-SNAPSHOT -->
</parent>
```

### 步骤 2: 更新 nacos 版本
移除根 pom.xml 中的 `nacos.version` 属性和 `dependencyManagement` 中的旧版 nacos 依赖，改为从 parent 继承。

### 步骤 3: 升级 wolf-manager-v4-admin 模块

**pom.xml 改动:**
- 升级 Spring Boot Admin: `spring-boot-admin.version` 从 2.1.6 升级到 3.x
- 移除所有 Springfox 相关依赖（Spring Boot 3.x 不兼容）
- 移除 `spring-boot-starter-security`（Spring Boot Admin 3.x 内置安全配置）

**代码改动:**
- 修改 `SecuritySecureConfig.java` - Spring Boot Admin 3.x 使用新的安全配置方式
- 可能需要更新 actuator 端点配置

### 步骤 4: 升级 wolf-manager-v4-swagger 模块

**pom.xml 改动:**
- 移除 `springfox.version` 属性
- 升级 Knife4j: `knife4j.version` 从 2.0.9 升级到 4.x
- 移除 `springfox-swagger2`、`springfox-bean-validators` 依赖
- 确认 `spring-boot-starter-undertow` 配置

**代码改动:**
- 更新 `SwaggerConfigProperties.java` - 适配 Knife4j 4.x 配置
- 更新 `GatewayConfig.java` - 适配新版本
- 更新 `IndexController.java` - 适配新版本
- 更新 `DefaultSwaggerResourceProvider.java` - 适配新版本

### 步骤 5: 处理 Java 版本
- Spring Boot 3.x 要求 Java 17+
- 检查所有自定义代码是否需要语法调整

### 步骤 6: 本地验证
```bash
make clean
make build
make run-admin
make run-swagger
```

## 关键文件清单

**需修改:**
- `/Volumes/t7shield/working/datatist/datatist-wolf-manager-v4/pom.xml`
- `/Volumes/t7shield/working/datatist/datatist-wolf-manager-v4/wolf-manager-v4-admin/pom.xml`
- `/Volumes/t7shield/working/datatist/datatist-wolf-manager-v4/wolf-manager-v4-admin/src/main/java/com/datatist/cloud/SecuritySecureConfig.java`
- `/Volumes/t7shield/working/datatist/datatist-wolf-manager-v4/wolf-manager-v4-swagger/pom.xml`
- `/Volumes/t7shield/working/datatist/datatist-wolf-manager-v4/wolf-manager-v4-swagger/src/main/java/com/datatist/cloud/swagger/config/*`
- `/Volumes/t7shield/working/datatist/datatist-wolf-manager-v4/wolf-manager-v4-swagger/src/main/java/com/datatist/cloud/swagger/controller/*`
- `/Volumes/t7shield/working/datatist/datatist-wolf-manager-v4/wolf-manager-v4-swagger/src/main/java/com/datatist/cloud/swagger/support/*`

## 验证方法

1. `make build` - 构建成功无错误
2. `make run-admin` - Admin 服务启动成功，访问 http://localhost:7003
3. `make run-swagger` - Swagger 服务启动成功，访问 http://localhost:7004/doc.html
4. 检查各端点是否正常响应

## 风险提示

- Spring Boot 3.x 有较多 breaking changes
- Knife4j 4.x API 有较大变化
- 需要充足时间测试验证
