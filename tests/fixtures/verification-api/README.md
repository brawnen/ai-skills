# 验证流程样例

这是仅用于流程 skills 验证的标准库 HTTP/SQLite 项目，不是业务试点或生产认证方案。`X-Actor` 对应固定测试身份；服务仅监听本机随机端口，每次运行使用独立临时数据库。

## 独立需求

- BR-01：A 管理员创建的记录只属于 A，名称与输入一致，创建一条审计记录。
- BR-02：B 管理员不能删除 A 的记录；返回 403，业务记录不变，记录一次拒绝审计。
- BR-03：普通成员不能创建记录，拒绝后没有新增业务记录。
- BR-04：A 管理员可以删除自己的记录，返回 200，实际删除且有对应审计。

动态 ID 用关联关系验证。`verify.py` 通过真实 HTTP 操作，并用只读 SQLite 查询断言业务副作用；不会导入应用计算函数生成 expected。

```bash
python3 verify.py run --artifacts /tmp/sample-api-evidence
```

执行包含启动、Doctor、准备与驱动、断言、取证、Cleanup。每次选择独立证据目录，旧报告不覆盖。退出码非零表示失败；`report.json` 和 `server.log` 留在指定位置。Cleanup 仅停止自己创建的进程并删除自己的临时数据库，不删除证据。

`verify-sample-api/` 是根据本项目事实创建并实跑的说明样例。流程测试把整个项目复制到临时目标，再把该样例放到该目标的 `.agents/skills/`，不在 ai-skills 本身的运行目录创建实体 skill。

从 ai-skills 根目录执行：

```bash
PYTHONDONTWRITEBYTECODE=1 python3 tests/verification-flow-test.py
```

该测试覆盖正确版本、隔离的租户检查变异、错误版本识别、环境失败与并行隔离。未覆盖浏览器、staging/production 或真实团队收益。
