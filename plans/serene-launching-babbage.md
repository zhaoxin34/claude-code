# Swagger 迁移到 springdoc - 其他模块实施计划

## 背景

wolf-service-tool 模块已完成 Swagger 到 springdoc 的迁移。现在需要将此方案应用到 datatist-wolf 项目下的其他子模块。

## 迁移范围

| 模块 | Controller 文件数 | Feign Client 文件数 | 总计 |
|------|-----------------|---------------------|------|
| wolf-app-analyzer | 169 | 8 | 177 |
| wolf-service-dataengine | 37 | 0 | 37 |
| wolf-service-user | 11 | 0 | 11 |
| wolf-service-campaign | 4 | 1 | 5 |
| wolf-service-demographic | 1 | 0 | 1 |
| wolf-service-sql | 1 | 0 | 1 |
| wolf-app-job | 0 | 2 | 2 |
| **总计** | **223** | **11** | **234** |

## 实施步骤

### 步骤 1: 为各模块添加 springdoc 依赖

在子模块的 pom.xml 中添加：
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
</dependency>
```

### 步骤 2: 为各模块添加 OpenApiConfig

在模块的 conf 包下创建 OpenApiConfig.java（参考 wolf-service-tool）

### 步骤 3: 批量替换注解

| 旧注解 | 新注解 |
|--------|--------|
| `@Api(tags = "xxx")` | `@Tag(name = "xxx")` |
| `@ApiOperation(value = "xxx")` | `@Operation(summary = "xxx")` |
| `@ApiParam("xxx")` | `@Parameter(description = "xxx")` |
| `@ApiModel` | `@Schema` |
| `@ApiModelProperty` | `@Schema` |

### 步骤 4: 验证

- 启动服务
- 访问 `/swagger-ui.html` 验证页面正常
- 访问 `/v3/api-docs` 验证 JSON 正常

## 推荐迁移顺序

1. **wolf-app-analyzer** (177 个文件) - 工作量最大，建议先处理
2. **wolf-service-dataengine** (37 个文件)
3. **wolf-service-user** (11 个文件)
4. **wolf-service-campaign** (5 个文件)
5. 其他模块

## 关键文件

- 父 pom.xml: 已添加 springdoc 依赖
- 迁移计划文档: `docs/变更计划/2026-03-06-Swagger迁移springdoc计划.md`
- 参考实现: `wolf-cloud-services/wolf-service-tool/`

## 验证方式

1. 编译模块: `mvn compile -pl <module-name> -am`
2. 启动模块: `mvn spring-boot:run -pl <module-name>`
3. 访问 Swagger UI 测试
