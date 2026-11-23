# Matt 流程优化实施记录

- 日期：2026-10-19。
- 基线：[定稿方案](2026-10-18-matt-aligned-workflow-design.md)。
- 范围：P1 主干、P2 可选入口源码、确定性机制演练及已授权四平台主干更新。
- 用户本轮确认：先完成 ai-skills 工程验证，真实业务项目稍后选择；不将 P3 业务试点计为已完成。

## 1. 实施结果

- to-decision 迁为 **to-requirement**，职责是需求收敛与显式压力测试，目录、元数据、活跃引用和测试同步迁移。
- **review-cross-stack-change** 独立入口退役，方法迁入共享跨边界设计参考；scan-architecture 仍是独立可选专项。
- flow 增加 **to-tickets、code-review、retro**；**implement-spec / prototype** 分别位于可选 flow-parallel / flow-explore。
- **implement / pr 不新增 skill**，实施和 PR 按共享协议执行。
- dev 作为完整交付入口按阶段读取协议；to-spec 允许无需独立交接时内联简短实施顺序，只有领取/恢复/依赖或并行需要才生成独立任务。
- 代码审查分 Standards 与 Spec；复用有效运行证据，但 PASS 不免除实现、断言和未测路径的独立审查。
- model 兼容既有 CONTEXT 与新项目 GLOSSARY 约定，不维护同义副本。
- 保留已生效的授权合并及人工生产操作边界，未重新引入“合并必须由人执行”。

catalog 当前为 21 个 active 入口；这是源码维护范围，不代表一次加载或向所有宿主安装 21 项。迁移与退役历史保留在 catalog，实际事实仍以 catalog 为准。

## 2. 上游与单一方法源

完整参考快照位于 `vendor/mattpocock/`，不登记为安装入口、不直接发布整包：

- 仓库：https://github.com/mattpocock/skills。
- 固定版本：v1.3.1。
- 完整提交：`24fe0ef7737efae15c87225755e9f6f5965e4888`。
- 原始归档 SHA-256：`437d7190285d6c7fd5a5dd65176c0868a35277f12cde46bec21714e5eefc0cf3`。
- 原文、文件摘要和符号链接：[快照记录](../../vendor/mattpocock.snapshot.json)。
- 本地适配、show-me 归属与 MIT 许可：[来源记录](../workflow-protocols/UPSTREAM.md)。

阶段方法统一位于 `docs/workflow-protocols/`，字段结构以 `docs/delivery-artifacts-spec.md` 1.3.0 为准。各入口只通过自身 references 链接读取；没有在 SKILL.md 写跨 skill 根目录的 ../docs 路径。

dev 的验证方法直接引用 verify-change 唯一源码，避免复制。新入口为元数据和条件路由，不重新实现宿主调度。阶段显式调用策略记录在元数据；其他宿主是否严格遵守仍需原生模型实测。

## 3. 已验证的工程结果

统一 local/CI 门禁为 `./scripts/check-workflow.sh`，操作说明见 [本仓库验证入口](../verification.md)。该门禁不调用模型、不执行真实全局发布。

| 检查 | 结果 | 证明范围 |
| --- | --- | --- |
| doctor | PASS | catalog、scope、依赖、所需路径和元数据；完整参考快照不进入运行 skill 扫描 |
| 全部 21 个 active skill 官方 quick_validate | PASS | frontmatter、命名和结构；不证明决策行为 |
| 发布器测试 | PASS | 旧入口/dangling 链接清理、新名称、依赖闭包、实体/外部链接保护、冲突不留下部分迁移 |
| 既有 HTML 测试 | PASS | 改动未破坏现有产物 helper |
| 工作流机制回归 | 7/7 PASS | 任务图、CLI、上游完整性、资源发布、真实临时 Git 集成及冲突 |
| HTTP/SQLite 回归 | 6/6 PASS | 正常/拒绝、目标变异、版本错配、环境失败、并行隔离与证据保护 |
| shell 语法与差异格式 | PASS | 既定脚本及新门禁入口 |

本机 HTTP 测试在允许监听的执行环境运行。环境限制不能当通过或有效反向证明；本轮没有将端口绑定失败改为 skip。

原始证据：

- [完整门禁日志](evidence/2026-10-19-matt-workflow/validation.log)。
- [七项测试汇总](evidence/2026-10-19-matt-workflow/summary.json)。
- [源文件摘要](evidence/2026-10-19-matt-workflow/source.json)：Git 基线、dirty 工作树与参与运行的内容摘要；没有创建本轮 Git 提交。
- [发布资源检查](evidence/2026-10-19-matt-workflow/publication-resources.json)：临时安装入口的 60 个链接资源可读且与权威源一致。

### 任务图与真实 Git 集成

[集成证据](evidence/2026-10-19-matt-workflow/integration.json)记录以下实际过程：

1. A/B 从同一临时集成基线创建独立 worktree，分别实现价格与运费行为，独立断言来自样例规格。
2. ready frontier 为 A/B；A 整合后仅 B 可开工；B 更新集成 tip、复验并整合后 C 才 ready。
3. C 基于已包含 A/B 的集成版本实现组合行为，最终三个功能测试全部通过。
4. 正常完成后只移除本次 worktree，保留规格、patch、提交图和运行结果。

[冲突证据](evidence/2026-10-19-matt-workflow/conflict.json)确认冲突导致合并失败、未合入提交与任务工作保留，B 不标 done，C 不进入 ready；随后只在本次临时仓库中中止合并并清理。

这是按协议执行的确定性演练，不是多个模型的并行协作评估，也没有测量并行提效。

## 4. 实际安装

四个平台保留已安装 bundles，并更新主干；Codex 继续保留 trial。所有入口通过发布器安装为指向本仓库的符号链接。

| 目标 | bundles | 受管入口数 | 检查 |
| --- | --- | --- | --- |
| Codex | core,architecture,docs,flow,trial | 15 | --check PASS |
| Claude Code | core,architecture,docs,flow | 14 | --check PASS |
| Antigravity | core,architecture,docs,flow | 14 | --check PASS |
| Gemini | core,architecture,docs,flow | 14 | --check PASS |

旧 to-decision 与 review-cross-stack-change 受管链接已清理。规则文件逐字节一致，Antigravity/Gemini 共用 GEMINI.md；全局规则不包含产品专属措辞。本项目 design 及两个依赖 --check 通过，无须迁移。

安装原始检查见 [四平台记录](evidence/2026-10-19-matt-workflow/installation.json)。并行/探索 bundle 源码和临时发布已验证，按方案没有自动安装到四个平台；strategy 的原有选择也未改变。

## 5. 实施边界与后续

已完成：主干与可选入口源码、引用/元数据/迁移、可移植门禁、本仓库工程验证和四平台主干安装。

未验证：各宿主真实模型对新指针与调用策略的执行、独立模型审查质量、原型 UI 交互、真实业务 E2E/远端 CI/测试环境部署及团队成本收益。没有创建远端 CI run、部署地址或业务结果来填补这些空白。

P3 按用户决定稍后选择业务项目；P4 需要实际使用数据。本仓库已有可靠脚本，直接使用验证说明，不为增加入口而创建 verify-ai-skills skill。后续在新会话使用 `$dev` 或 `$to-requirement`，以真实任务观察阶段读取与完成证据，再通过 retro 调整。
