---
name: to-tickets
description: 需要多人领取、跨会话恢复、显式依赖管理或并行任务图时，将已有规格或明确计划拆为独立可验证的行为任务；普通同会话实施不为流程形式生成任务工件。
---

# 拆解交接任务

读取 [任务协议](references/tickets.md)，核对来源任务的归属与标题，复用 spec、AC、术语、决定与项目 tracker。拆分时分别复用平台原生的父子与阻塞关系。独立任务必须能离开原聊天被领取。

需要派生 JSON 任务图时，用 [图校验脚本](scripts/check-task-graph.py) 检查依赖和 ready frontier：`python3 <本入口>/scripts/check-task-graph.py <任务图.json>`。快照来源与实际完成状态仍需核对，脚本不会访问 tracker 或批准执行。

已有拆分和发布授权则继续，不强制再确认颗粒度；本地草案不自动授权外部创建/关闭 issue。

方法来源与本地适配见 [来源记录](references/upstream.md)，许可见 [MIT 许可](references/LICENSE.mattpocock)。
