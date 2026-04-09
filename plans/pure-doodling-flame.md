# 计划：创建 Makefile 和 .env 管理服务

## 背景

用户希望创建一个 Makefile 来统一管理本地服务（hadoop、zookeeper、hive metastore）的启动、停止和状态查看。同时需要一个 .env 文件来控制使用哪个版本。

## 当前状态

### 可用版本
- **Hadoop**: `hadoop-2.7.7`, `hadoop-3.4.3`
- **ZooKeeper**: `apache-zookeeper-3.9.5-bin` (只有这一个版本)
- **Hive Metastore**: `apache-hive-metastore-4.1.0-bin`, `apache-hive-2.3.6-bin`

### 启动脚本路径
- Hadoop: `$(HADOOP_HOME)/sbin/start-dfs.sh` / `stop-dfs.sh`
- ZooKeeper: `$(ZOOKEEPER_HOME)/bin/zkServer.sh start/stop`
- Hive Metastore: `$(HIVE_HOME)/bin/start-metastore` (无 stop 脚本，需用 kill)

## 实现方案

### 1. 创建 .env 文件

```env
# 服务版本配置
HADOOP_VERSION=hadoop-3.4.3
ZOOKEEPER_VERSION=apache-zookeeper-3.9.5-bin
HIVE_METASTORE_VERSION=apache-hive-metastore-4.1.0-bin

# 服务根目录
SERVER_DIR=/Volumes/data/working/server
```

### 2. 创建 Makefile

```makefile
include .env

# 解析版本路径
HADOOP_HOME=$(SERVER_DIR)/hadoop/$(HADOOP_VERSION)
ZOOKEEPER_HOME=$(SERVER_DIR)/zookeeper/$(ZOOKEEPER_VERSION)
HIVE_HOME=$(SERVER_DIR)/hive/$(HIVE_METASTORE_VERSION)

.PHONY: help start stop status status-hadoop status-zookeeper status-hive start-all stop-all

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  start        - 启动所有服务"
	@echo "  stop         - 停止所有服务"
	@echo "  status       - 查看所有服务状态"
	@echo "  start-hadoop - 启动 Hadoop"
	@echo "  stop-hadoop  - 停止 Hadoop"
	@echo "  start-zookeeper  - 启动 ZooKeeper"
	@echo "  stop-zookeeper   - 停止 ZooKeeper"
	@echo "  start-hive   - 启动 Hive Metastore"
	@echo "  stop-hive    - 停止 Hive Metastore"

start-all: start-hadoop start-zookeeper start-hive

stop-all: stop-hive stop-zookeeper stop-hadoop

start-hadoop:
	@echo "Starting Hadoop $(HADOOP_VERSION)..."
	@$(HADOOP_HOME)/sbin/start-dfs.sh

stop-hadoop:
	@echo "Stopping Hadoop $(HADOOP_VERSION)..."
	@$(HADOOP_HOME)/sbin/stop-dfs.sh

start-zookeeper:
	@echo "Starting ZooKeeper $(ZOOKEEPER_VERSION)..."
	@$(ZOOKEEPER_HOME)/bin/zkServer.sh start

stop-zookeeper:
	@echo "Stopping ZooKeeper $(ZOOKEEPER_VERSION)..."
	@$(ZOOKEEPER_HOME)/bin/zkServer.sh stop

start-hive:
	@echo "Starting Hive Metastore $(HIVE_METASTORE_VERSION)..."
	@$(HIVE_HOME)/bin/start-metastore

stop-hive:
	@echo "Stopping Hive Metastore..."
	@-ps aux | grep 'HiveMetaStore' | grep -v grep | awk '{print $$2}' | xargs -r kill 2>/dev/null || true

status: status-hadoop status-zookeeper status-hive

status-hadoop:
	@echo "=== Hadoop ==="
	@$(HADOOP_HOME)/bin/hdfs --versions 2>/dev/null || echo "Hadoop not running"

status-zookeeper:
	@echo "=== ZooKeeper ==="
	@$(ZOOKEEPER_HOME)/bin/zkServer.sh status

status-hive:
	@echo "=== Hive Metastore ==="
	@-ps aux | grep -E 'HiveMetaStore|metastore' | grep -v grep || echo "Hive Metastore not running"
```

## 关键文件

| 文件 | 路径 |
|------|------|
| Makefile | `/Volumes/data/working/server/Makefile` |
| .env | `/Volumes/data/working/server/.env` |

## 验证方法

```bash
# 1. 查看当前配置版本
cat .env

# 2. 查看服务状态
make status

# 3. 启动所有服务
make start

# 4. 停止所有服务
make stop

# 5. 单独启动/停止某个服务
make start-hadoop
make stop-hadoop
```
