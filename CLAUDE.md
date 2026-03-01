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

# 工程规范

## python代码

- 源代码必须放到src目录下，不能放在根目录下
- 测试代码必须放到tests目录下，不能放到根目录下
