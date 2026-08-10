# 本地 AI Skills 中央目录

这个仓库只保留 Codex harness 没有原生覆盖的专项决策模型、工具适配和项目约束模板。通用的计划管理、仓库探索、局部澄清、安全编辑、普通故障修复、外层验证、代码证据汇报和 Git 纪律由 Codex 自身负责，不再包装成 skills 或全局 AGENTS 规则。

## 取舍原则

一个能力只有满足以下至少一项才保留：

- 包含明确的领域风险模型，例如数据库上线风险或生产事故止损。
- 包含会显著改变执行顺序、反馈循环或系统边界判断的可复用工程决策模型。
- 依赖专用工具协议，例如 CodeGraph。
- 产出固定且可复用的非原生产物，例如自包含 HTML 正式文档。
- 记录具体项目事实、禁区和发布约束，而不是通用工程常识。

以下内容不再由本仓库重复维护：

- TODO、阶段状态、依赖顺序和恢复执行：使用 Codex 原生计划能力。
- 陌生仓库扫描、读取 README/AGENTS、寻找测试入口：使用 Codex 原生仓库探索。
- 普通实施中的局部澄清、范围控制、最小改动和验证汇报：使用 Codex 原生执行纪律。
- 根因明确的普通 bugfix、代码审查和代码事实说明：使用 Codex 原生分析与验证能力。
- Word、PDF、幻灯片、表格、网站和产品设计：使用 Codex 官方 skills/plugins。

## 当前 skills

### 默认 `core`

| skill | 保留原因 | 不负责 |
| --- | --- | --- |
| `requirements-clarification` | 正式需求访谈、设计分支收敛和可验收 spec | 普通实施中的局部歧义 |
| `systematic-debugging` | 疑难故障的反馈循环、根因验证，以及生产影响扩大时的止损分支 | 根因明确的普通 bugfix、组织级事故管理 |
| `test-first-development` | 可测试行为的 RED-GREEN-REFACTOR、公共测试缝和 vertical slice | 全量测试、构建、E2E、视觉与发布验证 |
| `db-change-safety` | DDL、迁移、回填、生产写入的锁、事务、幂等、分批和回滚风险 | 纯只读查询、普通代码验证 |

### 可选 bundle

| bundle | skills | 使用条件 |
| --- | --- | --- |
| `architecture` | `architecture-friction-scan`、`review-cross-stack-change`、`domain-modeling`、`codegraph-assisted-navigation` | 用户明确要求架构体检、跨栈方案评审或领域建模；CodeGraph helper 还要求项目索引和宿主工具可用 |
| `docs` | `formal-html-docs` | 用户明确要求自包含、可打印的正式 HTML；普通 Markdown、Word、PDF 不使用 |

### 项目级 UI/UX skill

`templates/project-local/.agents/skills/design-product-ui` 是按项目引入的 UI/UX
设计能力，不属于任何全局 bundle，也不会被全局同步脚本安装。只在项目包含页面、
Web 或客户端设计工作时，把整个目录复制到目标仓库：

```bash
mkdir -p <project>/.agents/skills
cp -R templates/project-local/.agents/skills/design-product-ui \
  <project>/.agents/skills/design-product-ui
```

该 skill 负责从用户任务、现有设计系统和平台约束收敛设计方向，按复杂度处理局部
调整、页面/流程、新设计系统和只读评审，并在需要跨页面复用时维护项目根目录
`DESIGN.md`。宿主已有的图片生成、设计探索、浏览器/设备验证、测试和代码执行能力
继续负责实际工具流程。

设计模型综合参考了 Impeccable 的设计语言与反模板化、UI UX Pro Max 的跨平台
知识组织、Vercel Web Interface Guidelines 的质量检查、gstack 的方向选择与评审闭环，
以及 Open Design 将项目 `DESIGN.md`、通用 craft 规则和具体 artifact skill 分离的结构；
没有引入这些项目的 daemon、命令路由、自动提交或宿主专属运行时。

## 已移除的重复能力

| skill | 移除原因 | Codex 对应能力 |
| --- | --- | --- |
| `task-todolist-execution` | 只是维护 TODO、状态和验证门槛 | 原生计划与持续任务状态 |
| `repo-intake-scan` | 只是读取仓库入口、技术栈和验证命令 | 原生仓库探索与 AGENTS 发现 |
| `safe-editing` | 只是限制范围、保护用户改动和避免无关重构 | 原生编辑安全规则 |
| `code-evidence-docs` | 证据化分析和文档生成属于通用执行能力 | 原生代码分析与文档 skills |
| `frontend-project-flow` | 重复编排设计、实现、浏览器验证和审查 | Product Design、Browser、Sites 与原生计划 |
| `doc-converter` | 依赖旧本机 CLI，且与官方 Documents/PDF 能力重复 | 官方 Documents/PDF skills |
| `project-release-scope-check` | 发布闭包依赖项目制品拓扑和流水线事实，通用部分只是原生分析与验证 | 项目级 `AGENTS.md` 发布事实 + Codex 原生能力 |
| `production-incident-hotfix` | 止损只是疑难调试在生产影响扩大时的入口分支，独立维护会重复诊断与回归流程 | `systematic-debugging` Operational Gate |

历史上已经退役的 `task-report`、`validation-required`、`verification-before-completion`、`code-review`、`pdf` 和 `taste-skill` 继续由安装脚本清理旧链接。

## 全局 AGENTS

`rules/AGENTS.md` 是用户级 guidance 的事实源，但只保留：

- 中文、简洁、区分已验证与未验证等个人沟通偏好。
- 正式 HTML 与普通 Markdown 的产物偏好。
- 剩余领域 skills 的触发边界。

不要在这里重复 Codex 已经负责的计划、工具选择、编辑安全、测试、Git、提交权限或通用验证规则。项目根目录中的 `AGENTS.md` 应只记录该项目的真实命令、目录边界、兼容要求和高风险区域；模板位于 `templates/project-local/`。

## 安装

查看 bundles：

```bash
./scripts/install-links.sh --list
```

默认只安装 `core`：

```bash
./scripts/install-links.sh
```

按需安装：

```bash
./scripts/install-links.sh ~/.codex/skills core architecture
./scripts/install-links.sh ~/.codex/skills core docs
```

安装脚本只删除由本仓库创建的旧符号链接，不删除其他来源的 skills。

跨平台同步（默认只同步 Codex 与 Antigravity 的 `core`）：

```bash
./scripts/sync-global-platforms.sh
./scripts/sync-global-platforms.sh --platforms codex,antigravity --bundles all
./scripts/sync-global-platforms.sh --deep-check --platforms codex,antigravity --bundles all
```

Antigravity 的官方全局目录是 `~/.gemini/config/skills`，全局规则入口是
`~/.gemini/GEMINI.md`。后者也会被 Gemini CLI 读取；同步 Antigravity 时不会改动
Gemini CLI 独立的 `~/.gemini/skills`。

结构和元数据检查：

```bash
./scripts/doctor.sh
```

## 目录边界

- `global/specialists/`：可由用户意图直接触发的领域专项。
- `global/helpers/`：专用工具或产物 helper。
- `rules/AGENTS.md`：用户级偏好和剩余 skill 路由。
- `templates/project-local/`：项目事实、约束模板和按项目复制的 `.agents/skills`，不参与全局安装。
- `vendor/`：外部社区包参考，不混入默认集合。
- `adapters/`：非 Codex 平台的适配骨架。
- `scripts/`：安装、同步和巡检脚本。
