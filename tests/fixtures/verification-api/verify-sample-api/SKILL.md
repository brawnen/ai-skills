---
name: verify-sample-api
description: 对隔离 Sample API 验证管理员创建、跨租户拒绝、成员拒绝和删除行为；执行真实 HTTP 入口与只读 SQLite 断言并保留运行证据，仅适用于此样例项目。
---

# Sample API 验证

在 Sample API 项目根目录执行。需求来源为 README 的 BR-01 至 BR-04；实现文件 `server.py`，控制入口 `verify.py`。固定 X-Actor 身份仅用于测试，不是生产认证。

## Launch 与 Doctor

通常使用集成命令 `python3 verify.py run --artifacts <证据目录>`，它在独立临时目录启动服务、分配本机随机端口，并读取实际就绪记录。

需要手动定位时运行 `python3 server.py --state <新建隔离目录> --ready <该目录>/ready.json`，读取 ready.json 的 URL，再用 `python3 verify.py doctor --url <URL>` 核对运行中的源文件摘要。Doctor 不准备业务数据或修改服务。只停止自己创建的进程。

## Data / Drive / Observe

run 以空 SQLite 初始化；admin-a、member-a、admin-b 分别是 A 管理员、A 成员和 B 管理员。通过 POST /items、GET /items/id 和 DELETE /items/id 驱动，不直接写数据库模拟业务结果。

- AC-01：admin-a 创建 sample，201；读取同一 ID 得到 A/sample；只读数据库确认一条业务记录和 created 审计。
- AC-02：admin-b 删除该 ID，403；原记录不变且有 denied 审计。
- AC-03：member-a 创建，403；业务记录未增加。
- AC-04：admin-a 删除，200；记录消失且有 deleted 审计。

每次运行重新隔离，不能在共享实例 reset。readonly 状态和请求结果共同证明行为。

## Evidence / Cleanup

每次选择独立证据目录，已有工件不覆盖。report.json 记录 run ID、代码摘要、环境、AC、实际结果与数据库快照；server.log 记录请求。失败保存实际异常和已执行场景，未运行的后续场景不能算通过。

run 的 finally 停止自己创建的进程，退出后清理临时目录，报告 owned_resources_removed 与 process_stopped。证据目录不在临时运行状态中，Cleanup 后仍保留日志和报告；失败也遵循此路径。

## Targets 与维护

仅证明 local 和可运行标准库服务的 CI 执行；staging、production、浏览器未验证。生产部署和写入不属于该入口。

接口、权限规则或协议变化时更新受影响场景和说明并复跑；不定期自动全量巡检。独立需求有变更时先更新验收来源，不能放宽正确断言掩盖回归。
