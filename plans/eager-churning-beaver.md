# CDP User模型同步计划

## 目标
将CDP的User模型同步为与Ecommerce一致（不含Relationships）

## 需要修改的文件

### 1. CDP User模型
**路径**: `cdp/backend/src/app/models/user.py`

修改内容：
- `is_active` → `is_admin` (Boolean, default=False)
- 新增 `phone` (String(20), unique, nullable)
- 新增 `password_reset_token` (String(255), nullable)
- 新增 `password_reset_expires_at` (DateTime, nullable)
- 新增 `password_history` (String(1000), nullable)
- 新增 `failed_login_attempts` (Integer, default=0)
- 新增 `locked_until` (DateTime, nullable)
- 新增 `sms_code` (String(10), nullable)
- 新增 `sms_code_expires_at` (DateTime, nullable)

### 2. CDP 数据库迁移文件
**路径**: `cdp/backend/alembic/versions/001_initial_migration.py`

需要添加上述新字段的迁移语句

## 修改步骤

1. 修改 `cdp/backend/src/app/models/user.py` 中的User类
2. 创建新的迁移文件添加缺失字段

## 验证方式

1. 启动CDP后端服务
2. 检查数据库表结构是否正确
3. 测试用户注册和登录功能是否正常
