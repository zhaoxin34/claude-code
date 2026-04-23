# CDP 数据库备份脚本计划

## Context

需要创建一个统一的 `db_backup.sh` 脚本，包含 `backup`、`list`、`restore` 三个函数，文件放在 `cdp/backup_sql/` 目录。

## 实现方案

### 文件位置
`cdp/backup_sql/db_backup.sh`

### 三个函数

1. **backup** - 备份数据库
   - 使用 `mysqldump` 备份 `cdp` 数据库
   - 文件名格式：`cdp_backup_YYYYMMDD_HHMMSS.sql`
   - 保存到 `cdp/backup_sql/` 目录

2. **list** - 列出所有备份
   - 显示备份目录中的所有 `.sql` 文件
   - 显示文件大小和修改时间

3. **restore** - 还原数据库
   - 接受备份文件名作为参数
   - 还原前显示确认提示

### 数据库连接
从 `cdp/backend/.env` 读取 `DATABASE_URL` 解析出 MySQL 连接信息

### 验证方式
```bash
cdp/backup_sql/db_backup.sh backup   # 执行备份
cdp/backup_sql/db_backup.sh list    # 列出备份
cdp/backup_sql/db_backup.sh restore cdp_backup_xxx.sql  # 还原