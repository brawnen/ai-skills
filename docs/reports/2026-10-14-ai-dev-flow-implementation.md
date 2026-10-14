# AI 研发流程实施与验证记录

- 日期：2026-10-14
- 基线：[统一方案](2026-10-13-ai-dev-flow-skills-redesign.md)
- 范围：源码、命名、共享契约、规则、隔离发布、最小真实运行协议验证与授权目标的实际安装更新。
- 状态：本地实施、检查与四平台及本项目重新发布完成；独立 Agent 行为评估、业务项目试点及生产操作未执行。

## 1. 源码结果

用户选定的八项名称已迁移：dev-flow → dev，delivery-spec → to-spec，decision-clarification → to-decision，systematic-debugging → debug，db-change-safety → review-db，domain-modeling → model，formal-html-docs → to-html，design-product-ui → design。

旧名称在 catalog 保留 retired 行，source 为 `-`。随后用户澄清：其修改的名称按用户版本，其余按方案建议。补齐四项迁移：test-first-development → tdd、verification-harness → setup-verification、architecture-friction-scan → scan-architecture、venture-feasibility → assess-venture，共十二项。受管事实以 `config/skills.tsv` 为准。

四个 flow 模块采用显式策略并共享 `docs/delivery-artifacts-spec.md` 1.1.0；`references/artifacts.md` 链接保证从符号链接安装入口访问同一份协议。核心变化：按风险选路径、复用授权和验收、不强制切换上下文、不重复生成文档、关键已知场景直接写回归、反向验证只在隔离副本、环境与未知失败如实报告、巡检范围/频率按需选择。

全局规则保留人工合并/生产操作边界，收窄无条件真实入口与证据包要求，并恢复故障扩大时的止损语义。跨栈审查不再自动路由 TDD。普通实现、计划、测试运行及代码审查仍交给宿主。

本轮以既有公开方法为参考，编写第一方中文说明与自有样例，没有复制安装 pstack/Matt 上游运行包；引入第三方原文/包时另按固定快照、来源与许可证契约处理。

## 2. 发布器迁移保护

临时目录测试验证：

- 全局旧名称链接清理、新入口和 --check 正常。
- 项目退役受管链接（含失效绝对链接）清理后，新 design 和完整依赖闭包发布。
- 其他来源的同名退役链接、实体目录和项目自有 verify-my-app 均保留。
- 新名称发生实体/依赖冲突时，不提前删除旧入口、不留下部分迁移。
- 可选 flow bundle 的四个实际名称正确发布。

修改仅增加项目退役链接清理；保留完整依赖检查、预检后再修改、不覆盖实体/外部链接和仅清理本仓库受管链接的契约。

## 3. 样例运行与反向证据

样例位于 `tests/fixtures/verification-api/`，是真实标准库 HTTP 服务和隔离 SQLite。身份用固定 fixture header 表达，不是生产认证实现。独立业务要求在样例 README，验证从 HTTP 入口进行，并通过只读数据库断言实际副作用。

### 正确版本

[原始报告](evidence/2026-10-14-flow/normal/report.json)，[请求日志](evidence/2026-10-14-flow/normal/server.log)。

- run ID：`760b8d1d4ead4f449f39f57382b07bc2`。
- 整体 PASS；管理员创建、实际读取、跨租户拒绝、普通成员拒绝、管理员删除均通过。
- 动态 ID 用返回值与独立数据库归属/名称关系断言。
- 403 的同时确认业务记录不变和拒绝审计；200 删除同时确认真实行删除和审计。

### 隔离的错误版本

[反向报告](evidence/2026-10-14-flow/mutation/report.json)，[请求日志](evidence/2026-10-14-flow/mutation/server.log)。

- run ID：`ad23a0267e484ebf9b6ce43272c15bca`。
- 在 `/tmp` 副本移除跨租户保护，未修改样例原源码。
- AC-02 准确 FAIL：错误版本对跨租户删除返回 200，且实际删除了业务记录；不是语法、夹具或环境错误。
- 后续 AC-03/04 明确 NOT_RUN，不能因之前场景通过而宣称全通过。
- 六项测试还确认错误版本摘要与正确版本不同，正确源码未被改写，正确版本复跑通过。

两份原始报告都确认本次进程停止、临时数据库/目录删除、证据保留。本机随机 URL 是该次实例信息，现已清理，不是可持续访问的部署地址。

## 4. 检查结果

| 检查 | 结果 | 证明范围 |
| --- | --- | --- |
| doctor + git diff --check | PASS | 当前结构、元数据约束和差异格式 |
| publish-skills-test.sh | PASS | 临时发布、依赖、冲突、退役迁移及非受管实体共存 |
| formal-html-docs-test.sh | PASS | 改名后的 to-html 模板与已有资产约束 |
| 既定 shell 语法 | PASS | 发布/安装/同步/巡检及两个既有测试入口 |
| 全部 17 个 active skill + 样例 quick_validate | PASS | Skill frontmatter 等结构，不证明运行行为 |
| verification-flow-test.py | 6/6 PASS | 正常/拒绝、目标变异、环境失败、证据保护、并行隔离、错版本 Doctor |
| 四平台 global + 本项目 design --check | PASS | 实际安装链接、依赖与规则同步；不证明会话已重新加载 |

HTTP 协议测试需允许本机监听。沙箱内首次运行在 socket bind 处失败，原文 `PermissionError: [Errno 1] Operation not permitted`；随后在允许监听的执行环境通过。环境限制没有被当作业务通过或有效反向验证。

六项测试基于真实临时项目运行。样例验证 skill 被放入该临时目标的 `.agents/skills/`，ai-skills 本仓库的忽略运行目录没有新增实体样例。测试结束可删除其测试根目录；单独保存的两份审查证据仍在本报告目录。

## 5. S/M/L 源文本走查

这是本次实施者的条件/交接走查，不是独立模型执行或 A/B；下面是情境与据源码确定的路径。

| 情境 | 路径与交接 | 检查结论 |
| --- | --- | --- |
| S：已有需求下修正文案 | 宿主直接编辑/相关检查，复用既有预期，不建 spec、不新开上下文、不全量自测 | 当前 dev/to-spec 入口具有该短路径 |
| M：明确样例 API 创建与权限需求 | README 独立 BR/AC → 合适公共入口 → 真实 API/SQLite → 证据/cleanup；关键回归直接运行 | 样例实际支持，运行报告已保留 |
| L：跨服务退款或重要数据兼容变更 | 补业务/契约缺口，按相关边界选择专项；独立验证需授权，缺真实依赖或环境逐项记录 | 源文本路径可衔接；该实际业务行为未验证 |

需要按真实需求检查动态预期、规格-only任务、没有 harness 但已有可用脚本、缺授权/环境、生产只读边界，以及错误测试允许基于证据修正；不能把遵守固定步数当结果正确。

## 6. 真实安装影响与下一阶段

用户明确选择原有目标并增加 Gemini 后，已通过发布器更新以下真实目标，并逐项通过 `--check`：

| 实际目录 | 发布结果 |
| --- | --- |
| `~/.codex/skills` | core/architecture/docs/flow/trial，13 个受管入口，保留 show-me |
| `~/.claude/skills` | core/architecture/docs/flow，12 个受管入口 |
| `~/.gemini/config/skills`（Antigravity） | core/architecture/docs/flow，12 个受管入口 |
| `~/.gemini/skills`（Gemini） | core/architecture/docs/flow，12 个受管入口；清理已退役 CodeGraph 受管链接 |
| 本仓库 `.agents/skills` | design 与 ui-ux-pro-max、impeccable 完整依赖闭包；旧 design-product-ui 链接已清理 |

各全局目标的八个已安装旧名称链接已清理，新名称与四个 flow 入口均指向仓库源码。新增迁移后的入口为 tdd、scan-architecture、setup-verification；assess-venture 源码与隔离发布已验证，仍属 strategy bundle，按此前安装组合没有加入这四个平台。用户级规则同步到 Codex 的 AGENTS.md、Claude Code 的 CLAUDE.md，以及 Antigravity/Gemini 共用的 GEMINI.md，发布器保留旧规则备份。

上述结果不穷举其他业务项目，也不声明当前会话重新加载了新元数据。其他项目若安装过旧 design-product-ui，仍需指定目标后迁移。

下一步在新会话显式调用 `$dev`，进行独立场景评估；真实业务试点仍按原决定后续选择。不能由本机样例或安装成功推断团队更快、缺陷更少或 token 节省。
