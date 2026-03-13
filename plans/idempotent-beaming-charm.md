# 修复 @JdbcTypeCode(List) 转换为 @Convert 计划

## Context

之前的测试发现 `@JdbcTypeCode(SqlTypes.JSON)` 在 Maven 环境中对于 List 类型的字段无法正确反序列化 JSON。需要将所有使用 `@JdbcTypeCode` 注解的 List 类型字段改为使用 `@Convert` 注解。

## 问题分析

- `@JdbcTypeCode(SqlTypes.JSON)` 对简单对象（Map、自定义类）有效
- 对 List 类型（如 `List<String>`, `List<CustomClass>`）在 Maven 中无法正确反序列化
- VO 类可以保留 @JdbcTypeCode（不直接与数据库交互）
- Entity 类需要改为 @Convert 方式

## 需要修复的类列表

### Entity 类 (24个文件)

| 文件 | 字段 |
|------|------|
| `CampaignV2.java` | `List<CampaignFlowNode> flows` |
| `CampaignNode.java` | `List<Integer> fatherIds`, `List<Integer> childrenIds` |
| `CampaignV2Board.java` | `List<TriggerMetrics> triggerMetricsList`, `List<SimpleMetrics> simpleMetricsList` |
| `CampaignV2CalcLog.java` | `List<CampaignFlowNode> flows`, `List<BusiAuthConfDto> busiAuthConf` |
| `CampaignV2ChartBoard.java` | `List<ChartBoard.Widget> widgets` |
| `CampaignV2Template.java` | `List<CampaignFlowNode> flows` |
| `chart/ChartBoard.java` | `List<Widget> widgets` |
| `chart/ChartConfig.java` | `List<Table> tables`, `List<AdvancedDatetime> dateRange2`, `List<Filter> filter` |
| `de/DataTemplate.java` | `List<TmplTable> templateTableList` |
| `de/EsExecuteSyncTask.java` | `List<QuerySearch> params` |
| `de/Metrics.java` | `List<Table> tables` |
| `de/PhysicsTable.java` | `List<Schema> schemaList` |
| `de/SubscribeRecord.java` | `List<FileInfo> filenameList` |
| `de/Table.java` | `List<String> primaryKeys`, `List<String> parititionColumns` |
| `de/TableQueryField.java` | `List<FieldInfo> fieldsInfo` |
| `de/TemplateBizConfig.java` | `List<BizTableConfigTemplate> bizTableConfig` |
| `de/TemplateScenario.java` | `List<TableAndColumn> joinTableAndColumn` |
| `Segment.java` | `List<CalcLogInfo> campaignCalcLogNodes` |
| `SegmentCalcLog.java` | `List<String> sqlList`, `List<Segment.CalcLogInfo> campaignCalcLogNodes` |
| `SegmentDownloadConf.java` | `List<DownloadSegmentSchemaConfVo> schemaList` |
| `user/BizProduct.java` | `List<Long> menuIds` |
| `userlifecycle/UserLifecycle.java` | `List<Node> nodeList` |
| `campaign/CampaignFlowVersion.java` | `List<CampaignFlowNode> flows` |
| `AnalysisTemplateInfo.java` | `List<AdvancedDatetime> dateRange2` |

### VO 类 (4个文件 - 无需修复)

- `CampaignV2Vo.java` - 可保留 @JdbcTypeCode
- `ChartConfigVo.java` - 可保留 @JdbcTypeCode
- `SegmentCalcLogVo.java` - 可保留 @JdbcTypeCode
- `SegmentVo.java` - 可保留 @JdbcTypeCode

## 修复方案

### 方案：使用 @Convert 注解

参考已修复的 `ArchiveBoard.java` 案例：

1. **为每个需要转换的 List 字段创建独立的 Converter 类**
   - 位置: `com.datatist.cloud.wolf.domain.converter`
   - 命名: `{EntityName}{FieldName}Converter`

2. **Entity 类修改示例**:
```java
// ArchiveBoard.java (已修复)
@Column(columnDefinition = "TEXT")
@Convert(converter = ArchiveBoardWidgetConverter.class)
private List<Widget> widgets;

// ArchiveBoardWidgetConverter.java (新增)
@Converter
public class ArchiveBoardWidgetConverter extends GenericJsonConverter<List<ArchiveBoard.Widget>> {
}
```

## 实施步骤

1. **第一步**: 确认所有需要修复的 Entity 类和字段
2. **第二步**: 为每个 Entity 创建对应的 Converter 类
3. **第三步**: 修改 Entity 类的字段注解
4. **第四步**: 运行测试验证修复效果

## 验证方式

1. 编译 domain 模块: `mvn clean install -pl wolf-cloud-domain -DskipTests`
2. 运行测试: `mvn test -pl wolf-cloud-domain-test -Dtest=ArchiveBoardJpaTest`
3. 检查 JSON 反序列化是否正确

## 注意事项

- VO 类不需要修改，保留 @JdbcTypeCode 即可
- Converter 类需要实现 `AttributeConverter<List<T>, String>`
- 需要使用独立的 Converter 类，内部类不被 JPA 正确识别
