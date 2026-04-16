# Makefile Upload 命令计划

## Context

在 Makefile 中增加 upload 命令，用于将前端、后端、PowerJob 的运行包上传到 FTP 服务器。

## FTP 配置 (来自 .env.sample)

```bash
FTP_HOST=ftp.datatist.com
FTP_USER=datatist
FTP_PASSWORD=Datatist-aws-ftp#888!
FTP_UPLOAD_DIR=/zhaoxin/k8s/package
```

## 上传规范

### 文件命名规则
- 格式: `{app_name}.jar.{tag_name}` 或直接 `{app_name}.jar`
- 使用 `git describe --tags --always` 获取版本/分支标识

### 上传命令
```bash
ncftpput -u ${ftpUser} -p ${ftpPassword} ${ftpHost} $ftpUploadDir {filename}
```

## 待上传的包

| 应用 | 源文件 | 上传目标文件名 |
|------|--------|---------------|
| frontend | `frontend/datatist-web/` (目录) | `pmo-frontend.tar.gz` |
| backend | `backend/target/datatist-server.jar` | `datatist-server.jar.{tag}` |
| powerjob | `powerjob/target/powerjob-server-5.1.2.jar` | `powerjob-server.jar.{tag}` |

## Makefile 设计

```makefile
# ============== Upload ==============

# 加载环境变量
include .env
export $(shell sed 's/=.*//' .env)

# 版本标识
GIT_VERSION := $(shell git describe --tags --always 2>/dev/null || echo "local")

upload-frontend: frontend-build ## 打包并上传前端
	@echo "Uploading frontend..."
	@cd frontend && tar czf datatist-web.tar.gz datatist-web/
	@ncftpput -u ${FTP_USER} -p ${FTP_PASSWORD} ${FTP_HOST} ${FTP_UPLOAD_DIR} datatist-web.tar.gz
	@rm -f datatist-web.tar.gz

upload-backend: backend-build ## 打包并上传后端
	@echo "Uploading backend..."
	@ncftpput -u ${FTP_USER} -p ${FTP_PASSWORD} ${FTP_HOST} ${FTP_UPLOAD_DIR} datatist-server.jar.${GIT_VERSION}

upload-powerjob: powerjob-download ## 下载并上传 PowerJob
	@echo "Uploading powerjob..."
	@ncftpput -u ${FTP_USER} -p ${FTP_PASSWORD} ${FTP_HOST} ${FTP_UPLOAD_DIR} powerjob-server-$(POWERJOB_VERSION).jar.${GIT_VERSION}

upload-all: upload-frontend upload-backend upload-powerjob ## 上传所有包
```

## 验证方法

```bash
make upload-all
# 或单独上传
make upload-backend
```
