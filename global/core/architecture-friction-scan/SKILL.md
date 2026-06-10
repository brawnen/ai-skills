---
name: architecture-friction-scan
description: 适用于只读扫描代码库架构摩擦、浅模块、耦合泄漏、测试困难、AI 难导航区域和潜在重构候选；当用户要求“看看架构问题”“找重构机会”“为什么这块难维护”“帮我做架构体检”“扫描老系统摩擦点”时使用。默认只输出候选、证据、推荐优先级和验证边界，不改代码、不写 repo 文件、不生成 HTML，除非用户明确要求。
---

# Architecture Friction Scan

## Goal

只读发现架构摩擦，输出有证据的改进候选。这个 skill 吸收 Matt Pocock `improve-codebase-architecture` 的 deepening/deletion test/locality/leverage 思路，但本地化为默认只读、候选化、证据分层。

## Vocabulary

使用这些词表达架构判断，避免泛泛说“代码不优雅”：

- **模块**：有接口和实现的代码单元，可以是函数、类、包或业务切片。
- **接口**：调用方必须知道的一切，包括签名、参数、顺序、错误模式、配置和性能特征。
- **实现**：模块内部代码。
- **深度**：接口提供的杠杆。深模块是小接口承载较多行为；浅模块是接口复杂度接近实现复杂度。
- **缝**：可以替换行为而不原地改代码的位置。
- **适配器**：填入某个缝的具体实现。
- **杠杆**：调用方用较少接口知识获得较多能力。
- **局部性**：变化、缺陷和验证是否集中在一个地方。

## Default Mode

- 默认只读：不改代码、不写 repo 文件、不生成报告文件、不打开浏览器。
- 默认输出候选清单和证据分层。
- 用户明确要求正式文档时，转 `code-evidence-docs`。
- 用户选中某个候选继续设计时，转 `requirements-clarification`。
- 用户明确授权实现时，必须再转 `safe-editing`、`task-todolist-execution`、`test-first-development`。

## Workflow

1. 确认扫描范围：整个仓库、某个模块、某条业务链路、某次事故暴露出的区域，还是某个重构主题。
2. 读取项目事实：README、AGENTS、docs、ADR、测试目录、构建脚本、相关源码。
3. 如果项目存在 `.codegraph/` 或用户要求，配合 `codegraph-assisted-navigation` 快速生成候选入口、调用链和影响面；CodeGraph 结果只作为候选证据。
4. 找架构摩擦信号：
   - 理解一个概念需要在许多小文件之间跳转。
   - 模块只是透传，接口几乎和实现一样复杂。
   - 逻辑为了测试被拆成纯函数，但真实 bug 出现在编排调用处。
   - 调用方必须知道太多顺序、配置、错误模式或内部约定。
   - 多处调用方重复同一段校验、补偿、转换、异常处理。
   - 外部依赖、第三方接口或跨服务调用没有清晰缝和适配器。
   - 测试只能测内部细节，无法从稳定接口覆盖行为。
5. 对每个候选做 deletion test：如果删除这个模块，复杂度是消失，还是会散落到 N 个调用方？
6. 对依赖分类：
   - 进程内：纯计算、内存状态，无 I/O。
   - 本地可替代：数据库、文件系统等有本地替身。
   - 远程但自有：内部服务、RPC、消息，需要端口和适配器。
   - 真外部：第三方服务，只能用 mock/contract/fake 保护。
7. 给出候选，不直接给大改实现。每个候选必须包含证据、收益、风险和验证方式。
8. 排序推荐：Strong / Worth exploring / Speculative。
9. 输出最优下一步：继续澄清、写 spec、补测试缝、局部实现，或跳过。

## Output Pattern

```markdown
## 扫描范围
- ...

## 已确认证据
- ...

## 候选架构摩擦
| 优先级 | 候选 | 涉及文件/模块 | 摩擦 | 证据 | 推荐 |
| --- | --- | --- | --- | --- | --- |

## Top Recommendation
- 候选：
- 为什么先做：
- 不做的风险：
- 下一步：

## 未验证 / 需要更多证据
- ...
```

## Candidate Checklist

每个候选至少回答：

- 涉及哪些文件、模块或调用链？
- 当前摩擦是什么？
- 它是浅模块、耦合泄漏、测试缝缺失、还是局部性差？
- deletion test 结果是什么？
- 如果深化，接口会变小还是只是换一层包装？
- 依赖属于哪类？对应测试策略是什么？
- 这个候选是否触碰公共入口、共享配置、数据库或第三方接口？
- 推荐强度为什么是 Strong / Worth exploring / Speculative？

## Guardrails

- 不把“看起来不优雅”当作重构理由。
- 不默认写代码，不默认创建 HTML，不默认改 `CONTEXT.md` 或 ADR。
- 不输出只有观点没有文件/调用链/测试证据的架构结论。
- 不因为 CodeGraph `impact` 大就直接认定必须重构。
- 不建议大重构作为普通 bugfix 的默认路径。
- 不为只有一个适配器的场景引入抽象缝；一个适配器通常是假缝。
- 不和 `safe-editing` 冲突：真正实现前必须重新评估改动范围和回滚方式。

## Coordination

- 需要结构化调用链：配合 `codegraph-assisted-navigation`。
- 需要把扫描结果落正式文档：配合 `code-evidence-docs`。
- 需要把候选转成 spec：配合 `requirements-clarification`。
- 需要进入实现：配合 `safe-editing`、`task-todolist-execution`、`test-first-development`。
- 来源于生产事故：配合 `production-incident-hotfix`，先止血和验证根因，再谈架构候选。
