---
name: codegraph-assisted-navigation
description: 适用于用 CodeGraph 辅助代码结构探索、符号定位、调用链追踪和改动影响面候选分析；当用户问“这个类/方法怎么工作”“谁调用了它”“从入口 A 到实现 B 怎么走”“改这里影响哪里”“先用 codegraph 看一下”时使用。不要替代故障排查、发布核对或正式文档沉淀；这些场景应配合对应 skill 使用。
---

# CodeGraph Assisted Navigation

## Scope

用 CodeGraph 快速生成结构化候选，再用源码、配置、日志或运行验证收敛结论。

适合：符号定义、调用方、被调用方、调用路径、候选影响面、代码结构初始上下文。

不适合：日志文本、配置字符串、SQL 片段、错误消息、注释、文案等字面量搜索；这些优先用 `rg` / 文件读取。

## Workflow

1. 先确认当前项目是否可用 CodeGraph：存在 `.codegraph/`，且宿主暴露 `codegraph_*` 工具；必要时先看 `codegraph_status`。
2. 按问题类型选择最小工具：
   - 找定义或入口：`codegraph_search`，需要源码再用 `codegraph_node`。
   - 看谁调用：`codegraph_callers`。
   - 看它调用什么：`codegraph_callees`。
   - 看 A 到 B 的路径：`codegraph_trace`。
   - 看改动候选影响面：`codegraph_impact`。
   - 需要一次拿任务上下文：`codegraph_context`。
   - 需要多个相关符号源码：`codegraph_explore`。
3. 把 CodeGraph 输出标记为“候选”：入口候选、调用链候选、影响面候选。
4. 对会影响结论的点回读真实源码、配置或测试；涉及线上问题时还要结合日志和复现/验证结果。
5. 输出时分层：
   - CodeGraph 候选
   - 源码已确认
   - 未验证
   - 下一步验证

## Evidence Rules

- CodeGraph 结果不是最终事实；不能直接写成“已确认”。
- `codegraph_impact` 只能作为候选影响面，不能直接等同发布清单。
- 如果工具提示索引滞后，先读取提示中列出的变更文件，或运行/建议运行同步命令。
- 如果项目没有 `.codegraph/` 或工具返回未初始化，先询问用户是否初始化；不要擅自创建索引。
- 如果 CodeGraph 与源码不一致，以当前源码和实际验证为准，并说明索引可能滞后。

## Output Pattern

```markdown
## CodeGraph 候选
- ...

## 源码已确认
- ...

## 未验证
- ...

## 下一步验证
- ...
```

## Coordination

- 生产故障、攻击、第三方失败传播：配合 `production-incident-hotfix`，日志和复现优先级高于 CodeGraph。
- 发布范围核对：配合 `project-release-scope-check`，`impact` 只是候选输入。
- 新仓库盘点：配合 `repo-intake-scan`，CodeGraph 不替代 README、构建脚本和环境确认。
- 文档沉淀：配合 `code-evidence-docs`，CodeGraph 输出默认归入“根据调用关系推断”。
