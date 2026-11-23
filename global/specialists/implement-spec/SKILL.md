---
name: implement-spec
description: 用户选择整份规格的任务图实施时，按真实阻塞边、基线和集成门禁推进；并行委派须有明确授权与宿主支持，否则顺序执行。单个明确任务直接使用宿主。
---

# 实施整份规格

读取 [任务图实施协议](references/parallel-implementation.md) 及需要的 [任务格式](references/tickets.md)。先运行 [图校验](scripts/check-task-graph.py)：`python3 <本入口>/scripts/check-task-graph.py <任务图.json>`，核对来源、基线、允许目标与预算。

只对 ready frontier 领取任务；明确授权委派才并行，无能力或授权时按图顺序推进。每项复用 [实施](references/implementation.md)，最终读取 [审查](references/review.md)、[验证方法](references/verification.md) 和 [PR](references/pr.md) 协议。

保留可恢复提交、失败证据和真实集成版本；代码合并遵循项目门禁，生产操作仍由人执行。

集成版本需要独立审查时，由未参与实现的审查者在新上下文审查完整变更。先留存双轴初判，再对照各实施者的交接说明。

方法来源与本地适配见 [来源记录](references/upstream.md)，许可见 [MIT 许可](references/LICENSE.mattpocock)。
