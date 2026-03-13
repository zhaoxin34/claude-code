# 为 @JdbcTypeCode(SqlTypes.JSON) 实体类编写测试用例

## Context

项目中有 41 个 entity 类使用了 `@JdbcTypeCode(SqlTypes.JSON)` 注解，需要编写测试用例来验证 JSON 字段的读写是否正常工作。

参考实现: `/Volumes/data/working/datatist/datatist-upgrade-test/src/test/java/com/datatist/test/DeArchiveBoardRepositoryTest.java`

## 调研结果

### 使用 @JdbcTypeCode(SqlTypes.JSON) 的 entity 类（共41个）

| 序号 | 模块 | 实体类 |
|------|------|--------|
| 1 | campaign | CampaignFlow |
| 2 | campaign | CampaignFlowVersion |
| 3 | campaign | CampaignNode |
| 4 | campaign | CampaignV2 |
| 5 | campaign | CampaignV2Board |
| 6 | campaign | CampaignV2CalcLog |
| 7 | campaign | CampaignV2Calendar |
| 9 | campaign | CampaignV2ChartBoard |
| 10 | campaign | CampaignV2Template |
| 11 | campaign | Campaigns |
| 12 | chart | ChartBoard |
| 13 | chart | ChartConfig |
| 14 | de | ArchiveBoard |
| 15 | de | ArchiveDetail |
| 16 | de | ArchiveModule |
| 17 | de | BizTable |
| 18 | de | BlackListLog |
| 19 | de | BlackListLogDetail |
| 20 | de | Business |
| 21 | de | DataTemplate |
| 22 | de | EsExecuteSyncTask |
| 23 | de | Event |
| 24 | de | Metrics |
| 25 | de | PhysicsTable |
| 26 | de | Reference |
| 27 | de | SubscribeRecord |
| 28 | de | Table |
| 29 | de | TableImportBatch |
| 30 | de | TableQueryField |
| 31 | de | TemplateBizConfig |
| 32 | de | TemplateScenario |
| 33 | de | UserLabel |
| 34 | user | BizProduct |
| 35 | user | CompanyBizProduct |
| 36 | user | LoginReference |
| 37 | userlifecycle | UserLifecycle |
| 38 | 根目录 | AnalysisTemplateInfo |
| 39 | 根目录 | ReportCalculateResults |
| 40 | 根目录 | Segment |
| 41 | 根目录 | SegmentCalcLog |
| 42 | 根目录 | SegmentDownloadConf |

### 现有 Repository 情况

大部分实体类已有对应的 Repository，分布在：
- wolf-service-dataengine (最多)
- wolf-service-campaign
- wolf-service-user
- wolf-service-demographic

## 实现方案

由于 wolf-cloud-domain 是 domain 模块，没有 Spring Boot 启动类，需要采用特殊方案：

### 方案：在 wolf-cloud-domain 中创建独立测试模块

创建 `wolf-cloud-domain-test` 子模块（类似 datatist-upgrade-test），包含：
1. Spring Boot 启动类
2. JPA 配置
3. 测试用例

### 模块结构

```
wolf-cloud-domain/
├── pom.xml (修改，添加模块)
├── src/
│   └── main/java/
│       └── com/datatist/cloud/wolf/domain/
│           └── entity/ (现有41个实体类)
└── wolf-cloud-domain-test/ (新建)
    ├── pom.xml
    └── src/
        ├── main/java/
        │   └── com/datatist/cloud/wolf/domain/test/
        │       └── DomainTestApplication.java
        └── test/java/
            └── com/datatist/cloud/wolf/domain/test/
                └── JdbcTypeCodeJsonTest.java
```

## 实施步骤

### 步骤 1: 创建 wolf-cloud-domain-test 子模块

1. 创建目录结构
2. 创建 pom.xml，包含：
   - spring-boot-starter
   - spring-boot-starter-data-jpa
   - spring-boot-starter-test
   - mysql-connector-java
   - wolf-cloud-domain 依赖

### 步骤 2: 创建 Spring Boot 启动类

```java
@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.datatist.cloud.wolf.domain")
public class DomainTestApplication {
    public static void main(String[] args) {
        SpringApplication.run(DomainTestApplication.class, args);
    }
}
```

### 步骤 3: 配置 application.yml

配置数据库连接和其他 JPA 属性

### 步骤 4: 创建测试用例

```java
@SpringBootTest
class JdbcTypeCodeJsonTest {

    @Autowired
    private EventRepository eventRepository;

    @Test
    void testEventFilterField() {
        // 查询并验证 Event.filter 字段
    }

    @Test
    void testEventSpecialPropertyMappingListField() {
        // 查询并验证 Event.specialPropertyMappingList 字段
    }

    @Test
    void testCampaignFlowDetail() {
        // 查询并验证 CampaignFlow.detail 字段
    }
}
```

### 步骤 5: 运行测试

```bash
mvn test -pl wolf-cloud-domain-test
```

## Verification

1. 测试编译通过
2. 测试运行成功
3. 验证 JSON 字段能正确读写
4. 验证泛型类型信息保留（不会变成 Map<String, Object>）
