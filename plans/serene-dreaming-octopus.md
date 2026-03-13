# Gateway 重构计划：新建AuthService下沉业务逻辑

## Context

当前Gateway项目存在严重的"职责越位"问题，包含了大量不应该在网关层处理的业务逻辑。

### 问题清单

| 问题 | 严重程度 | 说明 |
|------|---------|------|
| **AbstractBaseFilter** (623行) | 严重 | 包含多端登录、密码安全校验、在线用户管理、站内信发送、操作日志记录等业务逻辑 |
| **10个Feign Client** | 严重 | 9个是业务调用 |
| **9个Domain实体** | 严重 | User、Project、Department、LoginReference等业务实体不应在Gateway |
| **多个业务Filter** | 中等 | AuthCheckFilter、UserDeptCheckFilter、LicenseCheckFilter |
| **20+个业务VO** | 中等 | LoginVo、OperateLog、AccountVo等 |

### 用户决策

- **业务下沉方式**: 新建AuthService微服务
- **License校验**: 移除
- **操作日志**: 保留简单日志（仅请求访问日志）

---

## 方案设计

### 目标架构

```
                    ┌─────────────────┐
    Client  ──────> │    Gateway      │  (仅路由 + Token验证 + 简单日志)
                    │  wolf-manager   │
                    │    -gateway     │
                    └────────┬────────┘
                             │ HTTP/Feign
                             ▼
                    ┌─────────────────┐
                    │   AuthService   │  (新建业务微服务)
                    │ (原Gateway业务)  │  - 多端登录处理
                    │                  │  - 在线用户管理
                    │                  │  - 权限校验
                    │                  │  - 部门校验
                    └─────────────────┘
```

### Gateway职责（重构后）

1. **路由转发** - 请求路由到下游服务
2. **Token验证** - JWT Token解析和校验
3. **请求日志** - 仅记录请求访问日志（非业务操作日志）

---

## 实施步骤

### Step 1: 创建 auth-service 模块

在项目中新建 `wolf-manager-auth` 模块：

```
wolf-manager-auth/
├── pom.xml
└── src/main/java/com/datatist/cloud/auth/
    ├── AuthApplication.java
    ├── controller/
    ├── service/
    ├── client/        (原Gateway的业务Client)
    ├── domain/        (业务实体)
    └── config/
```

### Step 2: 迁移业务代码到 AuthService

| 迁移项 | 说明 |
|--------|------|
| Feign Client | DepartmentClient, DepartmentUserClient, AccountClient, UserClient, LoginReferenceClient, UserOnlineClient, WebsiteMessageClient, EtlClient, ReferenceClient |
| Domain实体 | User, Project, Department, DepartmentUserBlacklist, LoginReference, LoginRuleConfig, UserOnline, Reference, KafkaArg |
| 业务VO | LoginVo, LoginResVo, LoginUserVo, LoginRecord, CheckAccountAuthVo, OperateLog等 |
| 业务Filter | AuthCheckFilter, UserDeptCheckFilter 的逻辑 |
| AbstractBaseFilter业务方法 | checkLoginAndSetAttribute, multiTerminalPasswordClear, addUserOnline, doOperateLog等 |

### Step 3: 简化 Gateway

#### 3.1 精简 AbstractBaseFilter

仅保留：
- 常量定义（ORDER_*）
- 响应封装方法（responseJson）
- Token解析基础方法（简化的getLoginUserFromAuthorization）
- IP获取方法（getIpFromRequest）

移除/迁移：
- 多端登录逻辑
- 密码安全校验
- 在线用户管理
- 站内信发送
- 操作日志（简化）

#### 3.2 简化Filter链

| Filter | 处理方式 |
|--------|---------|
| ProductIdCheckFilter | **保留** - 网关核心职责 |
| TokenCheckFilter | **保留** - JWT验证 |
| DecryptRequestBodyFilter | **保留** - 请求解密 |
| AuthCheckFilter | **移除** - 迁移到AuthService |
| UserDeptCheckFilter | **移除** - 迁移到AuthService |
| LicenseCheckFilter | **移除** - 按用户要求 |
| ApiResultWrapperFilter | **简化** - 仅响应包装 |
| UrlLogFilter | **保留** - 简化为请求访问日志 |

#### 3.3 清理依赖

pom.xml 移除：
- LicenseClient 相关依赖
- 业务VO相关类

### Step 4: Gateway与AuthService通信

Gateway通过Feign调用AuthService：

```java
// Gateway中新增
@FeignClient(name = "WOLF-MANAGER-AUTH")
public interface AuthServiceClient {
    // 权限校验
    @PostMapping("/auth/check")
    ResponseEntity<Rest> checkAuth(CheckAccountAuthVo vo);
    // 部门校验
    @PostMapping("/auth/checkDept")
    ResponseEntity<Rest> checkDept(DeptCheckVo vo);
    // 获取登录用户信息
    @GetMapping("/auth/loginUser")
    ResponseEntity<LoginUserVo> getLoginUser(@RequestParam("token") String token);
}
```

### Step 5: 配置调整

#### application.yml 调整

移除业务相关配置：
- `wolf.gateway.login-url-pattern`
- `wolf.gateway.urls-not-check-project`
- 其他业务URL配置

保留：
- `jwt.*` 配置
- `spring.cloud.gateway.*` 路由配置

---

## Critical Files

### 需要创建的文件
- `wolf-manager-auth/pom.xml`
- `wolf-manager-auth/src/main/java/.../AuthApplication.java`
- `wolf-manager-auth/src/main/java/.../config/`
- `wolf-manager-auth/src/main/java/.../service/`
- `wolf-manager-auth/src/main/java/.../controller/`
- `wolf-manager-auth/src/main/resources/bootstrap.yml`
- `wolf-manager-auth/src/main/resources/application.yml`

### 需要修改的文件
- `AbstractBaseFilter.java` - 精简
- `GatewayConfig.java` - 调整Filter配置
- `TokenCheckFilter.java` - 调整调用AuthService
- `pom.xml` - 新增auth模块

### 需要删除的文件
- `LicenseCheckFilter.java`
- `AuthCheckFilter.java`
- `UserDeptCheckFilter.java`
- `client/` 目录下9个Feign Client (迁移到auth)
- `domain/` 目录下所有实体类 (迁移到auth)
- `vo/` 目录下业务VO (迁移到auth)

---

## Verification

重构完成后验证：

1. **编译通过**: `mvn clean compile`
2. **Gateway启动**: `mvn spring-boot:run -pl wolf-manager-gateway`
3. **AuthService启动**: `mvn spring-boot:run -pl wolf-manager-auth`
4. **基础功能**:
   - Token校验正常
   - 路由转发正常
5. **业务功能**: 通过AuthService验证登录、权限、部门等业务逻辑
