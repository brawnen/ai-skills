---
name: x-review
description: 用户要求审查工作区、提交、分支或 PR，或已授权交付进入审查阶段时使用；分别检查项目规范与需求符合性，复用运行证据但不以 PASS 免审，不替代实际运行验收。
---

# 代码双轴审查

读取 [审查协议](references/review.md)，确定真实比较基线、最终提交与工作树范围，主动查找适用于改动路径的项目规范。分别报告 Standards 与 Spec；对足以改变任一结论的关键假设，给出运行证据或标明未验证。

复用已有验证工件，仍独立检查已 PASS 场景的实现与断言盲区；新疑点或版本变化才补必要检查。跨部署风险读取 [跨边界参考](references/cross-boundary-design.md)，结构判断读取 [架构参考](references/architecture-design.md)。写 PR 时引用 [PR 协议](references/pr.md)，进入测试部署或准备上线时衔接 [发布协议](references/release.md)。

独立审查按[两轮材料交接](references/review.md#独立审查的材料交接)执行：新上下文先给出双轴初判，再提供实现者说明做复核。委派遵循已有授权。用户已授权修复时先形成可检查发现，再修复与验证。

方法来源与本地适配见 [来源记录](references/upstream.md)，许可见 [MIT 许可](references/LICENSE.mattpocock)。
