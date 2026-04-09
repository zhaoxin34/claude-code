# JDK 17 + Spark 4.1 升级计划

## 当前状态

**已完成的升级：**
- JDK 17, Scala 2.13.17, Spark 4.1.1
- Hadoop 3.4.2, Zookeeper 3.9.4, Curator 5.9.0
- Kafka 3.9.1, Jackson 2.20.0, Netty 4.2.7.Final, Log4j 2.24.3
- Hive Metastore 4.1.0 connectivity ✅

**测试结果：**
- 118 total tests
- 89 passing (75%)
- 29 failing due to Parquet `detachFileInputStream()` issue

## Parquet 问题分析

错误：`NoSuchMethodError: 'void org.apache.parquet.hadoop.ParquetFileReader.detachFileInputStream()'`

**已验证：**
- Parquet 1.16.0 源码和 Maven jar 都包含 `detachFileInputStream()` 方法
- Spark 4.1.1 的 pom.xml 声明使用 Parquet 1.16.0
- MD5 哈希匹配：Maven仓库 和 官方Spark distribution 的 parquet-hadoop 1.16.0 一致
- javap 验证 Coursier 缓存的 jar 包含正确的方法签名

**疑问：**
- Spark 官方 distribution 正常运行
- 但 sbt 测试环境出现方法找不到的错误
- 怀疑存在 JAR 包冲突或 classloading 问题

## 调试策略：创建最小化测试工程

### 方案：新建 `spark4-test` 子工程

**目的：** 隔离问题，确定是 Spark 4.1.1 本身的问题还是项目依赖冲突

### 第一阶段：最小依赖测试
只引入：
```scala
libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "4.1.1" % Provided,
  "org.apache.spark" %% "spark-sql" % "4.1.1" % Provided
)
```

测试内容：
1. 创建 SparkSession
2. 写入 Parquet 到 HDFS
3. 读取 Parquet

**预期：** 如果这个也失败 → Spark 4.1.1 本身有问题
**预期：** 如果这个成功 → 项目依赖冲突

### 第二阶段：逐步引入依赖
如果第一阶段成功，逐步添加：
1. 添加 `sparkHive`
2. 添加 Hive Metastore 4.1.0
3. 添加其他依赖

每步验证 Parquet 功能是否正常。

### 第三阶段：定位冲突
如果某步失败，对比失败的 classpath 与最小工程的差异。

## 关键文件

- `build.sbt` - 项目构建配置
- `project/Dep.scala` - 依赖版本管理
