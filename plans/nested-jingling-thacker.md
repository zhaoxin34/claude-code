# 版本升级/降级计划：将 datatist-wolf-spark 同步为 event-producer 版本

## Context
用户希望将 datatist-wolf-spark 项目的 Scala、JDK、Spark、Hive、Hadoop 版本与 event-producer 项目保持一致。

## 需要修改的文件

### 1. project/Dep.scala

**版本变量修改：**
- `versionSpark = "4.1.1"` → `"3.1.1"`
- `versionScala = "2.13.17"` → `"2.12.12"`
- `versionHadoop = "3.4.2"` → `"2.7.4"`
- `versionHiveMetastore = "4.1.0"` → 删除或注释（Spark 3.1.1 使用内置 Hive）
- `versionKafkaClient = "3.9.1"` → `"2.3.0"`
- `versionZookeeper = "3.9.4"` → `"3.4.14"`
- `versionAkka = "2.6.21"` → `"2.5.31"`
- `versionAkkaHttp = "10.2.10"` → `"10.1.14"`
- `versionJackson = "2.20.0"` → `"2.10.0"`
- `versionJacksonAnnotations = "2.20"` → 删除（使用 versionJackson）
- `versionNetty = "4.2.7.Final"` → `"4.1.51.Final"`
- `versionLog4jApiScala = "12.3.0"` → `"11.0"`
- `log4jApi = "2.24.3"` → `"2.12.1"`
- `log4jCore = "2.24.3"` → `"2.12.1"`
- `versionScalaTest = "3.2.19"` → `"3.2.2"`
- `versionScalatestplus = "3.2.18.0"` → 删除
- `scopt = "4.1.0"` → `"3.7.0"`
- `curator = "5.9.0"` → `"4.3.0"`
- `parquet4s = "1.9.4"` → `"1.3.1"`
- `wolfSupportSpark = "1.0.71"` → `"1.0.44"`
- `versionCommonBean = "0.0.18"` → `"0.0.10"`
- `versionParquetHadoop = "1.10.1"` → 删除
- `versionDropwizardMetrics = "4.1.1"` → 删除

**depsSparkProvided 修改：**
- 删除显式的 parquet-hadoop 1.16.0 等版本（Spark 3.1.1 会自带）
- 删除显式的 hive-metastore、hive-common、hive-exec、hive-serde（Spark 3.1.1 会自带）
- 保留基本的 spark-core、spark-sql、spark-mllib、spark-streaming、spark-hive

**depsOverrideSpark 修改：**
- `hadoop-client 3.4.2` → `2.7.4`
- 删除 hive 和 parquet override

### 2. build.sbt (spark-udf 模块)

- `scalaVersion := "2.13.17"` → `"2.12.12"`

## 验证方式
1. 执行 `sbt compile` 确认编译通过
2. 执行 `sbt test` 确认测试通过
