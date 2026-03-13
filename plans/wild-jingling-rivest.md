# wolf-repository-test 子工程创建计划

## 背景

创建一个新的 Maven 子模块 `wolf-repository-test`，用于测试 `wolf-cloud-services` 中 Repository 层的数据库增删改查正确性。

**测试数据库信息**：
- 地址：127.0.0.1:3306
- 用户：root
- 密码：root
- 数据库：wolf

---

## 现有项目结构分析

| 项目 | 值 |
|------|-----|
| **项目类型** | Spring Cloud Maven 多模块项目 |
| **Java 版本** | 17 |
| **Spring Boot 版本** | 3.5.9 |
| **数据访问** | Spring Data JPA + MyRepository |
| **测试框架** | JUnit 5 + Spring Boot Test |
| **domain 模块 packaging** | jar |

---

## 实现方案

### 1. 创建 Maven 子模块

```
wolf-repository-test/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/
    │   │   └── com/datatist/cloud/wolf/repository/test/
    │   │       └── RepositoryTestApplication.java
    │   └── resources/
    │       └── application.yml
    └── test/
        └── java/
            └── com/datatist/cloud/wolf/repository/test/
                └── campaign/
                    └── CampaignV2RepositoryTest.java
```

### 2. pom.xml 配置

- **packaging**: jar
- **parent**: datatist-wolf
- **dependencies**:
  - wolf-service-campaign (包含 CampaignV2Repository)
  - wolf-cloud-domain (实体类)
  - spring-boot-starter-data-jpa
  - spring-boot-starter-test
  - mysql-connector-java

### 3. application.yml 配置

```yaml
spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/wolf?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: root
    password: root
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: true
    properties:
      hibernate:
        format_sql: true
```

---

## 需要创建的文件

### 1. `/Volumes/data/working/datatist/datatist-wolf/wolf-repository-test/pom.xml`

### 2. `/Volumes/data/working/datatist/datatist-wolf/wolf-repository-test/src/main/java/com/datatist/cloud/wolf/repository/test/RepositoryTestApplication.java`

### 3. `/Volumes/data/working/datatist/datatist-wolf/wolf-repository-test/src/main/resources/application.yml`

### 4. `/Volumes/data/working/datatist/datatist-wolf/wolf-repository-test/src/test/java/com/datatist/cloud/wolf/repository/test/campaign/CampaignV2RepositoryTest.java`

---

## CampaignV2RepositoryTest 测试用例设计

### 4.1 测试类结构

```java
@SpringBootTest
@Transactional
@Rollback(false)
class CampaignV2RepositoryTest {

    @Autowired
    private CampaignV2Repository repository;

    @Autowired
    private EntityManager entityManager;
}
```

### 4.2 测试方法设计 - 连贯 CRUD 测试

采用**连贯测试**设计：先 save → findById 验证 → update 验证 → delete 验证，确保数据流转正确。

```java
@SpringBootTest
@Transactional
@Rollback(false)
class CampaignV2RepositoryTest {

    @Autowired
    private CampaignV2Repository repository;

    @Autowired
    private EntityManager entityManager;

    private CampaignV2 testCampaign;

    /**
     * 测试完整的 CRUD 流程
     * 1. save: 创建数据
     * 2. findById: 验证数据存在
     * 3. equals: 验证数据一致性
     * 4. delete: 删除数据
     */
    @Test
    public void testCompleteCrudFlow() {
        // Step 1: 创建测试数据
        testCampaign = createTestCampaign();
        CampaignV2 saved = repository.save(testCampaign);
        entityManager.flush();
        entityManager.clear();

        // Step 2: 通过 findById 验证数据存在
        Optional<CampaignV2> found = repository.findById(saved.getId());
        assertTrue(found.isPresent());

        // Step 3: 验证数据一致性（通过 equals 判断）
        assertEquals(saved, found.get(), "save 和 findById 返回的数据应该一致");

        // Step 4: 更新数据
        found.get().setName("Updated Name");
        repository.save(found.get());
        entityManager.flush();
        entityManager.clear();

        // Step 5: 验证更新后的数据
        Optional<CampaignV2> updated = repository.findById(saved.getId());
        assertTrue(updated.isPresent());
        assertEquals("Updated Name", updated.get().getName());

        // Step 6: 删除数据
        repository.deleteById(saved.getId());
        entityManager.flush();

        // Step 7: 验证数据已删除
        Optional<CampaignV2> deleted = repository.findById(saved.getId());
        assertFalse(deleted.isPresent());
    }

    /**
     * 测试枚举字段查询
     */
    @Test
    public void testFindByPhase() {
        // 1. save 创建 DRAFT 状态的活动
        CampaignV2 campaign = createTestCampaign();
        campaign.setPhase(CampaignV2.Phase.DRAFT);
        repository.save(campaign);
        entityManager.flush();

        // 2. findByPhase 查询
        List<CampaignV2> drafts = repository.findByPhase(CampaignV2.Phase.DRAFT);

        // 3. 验证
        assertTrue(drafts.size() > 0);
        assertTrue(drafts.stream().anyMatch(c -> c.getId().equals(campaign.getId())));

        // 4. 清理
        repository.deleteById(campaign.getId());
    }

    /**
     * 测试自定义方法查询
     */
    @Test
    public void testFindByName() {
        String testName = "TestCampaign_" + System.currentTimeMillis();

        // 1. save
        CampaignV2 campaign = createTestCampaign();
        campaign.setName(testName);
        repository.save(campaign);
        entityManager.flush();

        // 2. findByName
        List<CampaignV2> results = repository.findByName(testName);

        // 3. 验证
        assertTrue(results.size() > 0);

        // 4. 清理
        repository.deleteById(campaign.getId());
    }

    /**
     * 测试原生 SQL 查询
     */
    @Test
    public void testNativeQuery() {
        // 1. save
        CampaignV2 campaign = createTestCampaign();
        repository.save(campaign);
        entityManager.flush();

        // 2. 原生查询
        Map<String, Object> data = repository.getDataMapById(campaign.getId());

        // 3. 验证
        assertNotNull(data);
        assertEquals(campaign.getId(), data.get("id"));

        // 4. 清理
        repository.deleteById(campaign.getId());
    }
}
```

### 4.3 测试方法列表

| 测试方法 | 测试流程 |
|---------|---------|
| `testCompleteCrudFlow` | save → findById → equals 验证 → update → findById 验证 → delete → findById 验证为空 |
| `testFindByPhase` | save(DRAFT) → findByPhase → 验证 → delete |
| `testFindByName` | save → findByName → 验证 → delete |
| `testNativeQuery` | save → getDataMapById → 验证 → delete |

---

## 实施步骤

### Step 1: 创建模块基础结构
- 创建目录结构
- 创建 pom.xml
- 创建启动类
- 创建配置文件

### Step 2: 修改父 pom.xml
- 添加新模块 `wolf-repository-test`

### Step 3: 创建 CampaignV2RepositoryTest
- 创建测试类
- 测试增删改查基本功能

### Step 4: 运行验证测试
- mvn test -Dtest=CampaignV2RepositoryTest
- 验证 Repository 功能正常

---

## 验证方式

1. **编译验证**: `mvn compile` - 确保模块能正常编译
2. **测试验证**: `mvn test -Dtest=CampaignV2RepositoryTest` - 运行 Repository 测试
3. **预期结果**: 所有 CRUD 测试通过

---

## 注意事项

1. **使用 JUnit 5** - 使用 JUnit 5 (`org.junit.jupiter.api`)
2. **事务管理** - 使用 `@Transactional` 和 `@Rollback(false)` 便于调试
3. **Repository 依赖** - 需要正确引入 wolf-service-campaign 模块
4. **测试数据** - 测试前需确保数据库表存在（market_campaign_v2）
5. **先验证再推广** - 先写一个测试用例验证架构可行，再批量创建剩余测试
