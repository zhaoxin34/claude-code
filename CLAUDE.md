# 个人偏好

- 我使用mac操作系统和mac电脑
- 如果是开发后端，我偏爱python
- 尽量使用openspec开发功能
- 如果使用数据库，优先考虑sqlite，其次考虑mysql
- 如果要使用临时目录，使用/tmp/claude/作为临时目录
- 如果可以，尽量生成MakeFile

* 如果需要在markdown里绘图，优先使用mermaid
* 如果需要执行rm -rf 这样的命令，由于这个命令是不允许执行的，所以替代方案是执行mv，将这些文件mv到/tmp/claude目录，比如 rm -rf a.txt, 可以改成执行 mv a.txt /tmp/claude/.delete.a.txt
* 如果是git工程，必须使用hooks，可以用`git config core.hooksPath hooks` 设置hook
* 如果没有.gitignore不允许提交代码

# 个性化配置

* maven仓库的位置 /Volumes/data/working/sdk/repo

# 工程规范

## python代码

- 源代码必须放到src目录下，不能放在根目录下, 如果是多工程项目，也可以是sub_project/src/
- 测试代码必须放到tests目录下，规则同源代码
- 如果需要在代码或文档中使用文件路径的，如果是当前项目下的，一律用相对路径，避免项目更换目录出现问题

## 开发流程

每次完成代码编写后，必须执行以下步骤：

1. **代码简化**: 运行 `/simplify` 检查并优化代码
2. **代码格式化**: 运行项目中的 format 命令
3. **类型检查**: 运行项目中的 type-check 命令
4. **代码检查**: 运行项目中的 lint 命令
5. **运行测试**: 运行项目中的 test 命令
6. **Git 提交**: 确保所有检查通过后再提交
