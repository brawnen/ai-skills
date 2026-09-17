# 本地 AI Skills 中央目录

这个仓库只保留 Codex harness 没有原生覆盖的专项决策模型、工具适配和项目约束模板。通用的计划管理、仓库探索、局部澄清、安全编辑、普通故障修复、外层验证、代码证据汇报和 Git 纪律由 Codex 自身负责，不再包装成 skills 或全局 AGENTS 规则。

## 取舍原则

一个能力只有满足以下至少一项才保留：

- 包含明确的领域风险模型，例如数据库上线风险或生产事故止损。
- 包含会显著改变执行顺序、反馈循环或系统边界判断的可复用工程决策模型。
- 依赖当前实际使用、且宿主原生能力未覆盖的专用工具协议。
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
| `decision-clarification` | 依赖感知的分轮访谈；支持想法/计划压力测试、需求收敛及二者组合 | 普通实施中的局部歧义、需求和验收已经明确的任务 |
| `systematic-debugging` | 疑难故障的反馈循环、根因验证，以及生产影响扩大时的止损分支 | 根因明确的普通 bugfix、组织级事故管理 |
| `test-first-development` | 缺陷回归、复杂规则、公共契约及高风险重构的行为测试 | 普通低风险改动的验证调度、全量测试、构建、E2E、视觉与发布验证 |
| `db-change-safety` | DDL、迁移、回填、生产写入的锁、事务、幂等、分批和回滚风险 | 纯只读查询、普通代码验证 |

### 可选 bundle

| bundle | skills | 使用条件 |
| --- | --- | --- |
| `architecture` | `architecture-friction-scan`、`review-cross-stack-change`、`domain-modeling` | 用户明确要求架构体检、跨栈方案评审或领域建模 |
| `strategy` | `venture-feasibility` | 新产品、新业务或高不确定技术机会需要用证据贯通可行性、市场、商业模式、技术方案和阶段投资决策 |
| `docs` | `formal-html-docs` | 用户明确要求自包含、可打印的正式 HTML；普通 Markdown、Word、PDF 不使用 |

`formal-html-docs` 当前包含第一款生产模板：`decision-brief` 布局配合
`executive-sunrise` 主题，适用于可行性研究、商业分析、方案比较、投资评审和其他以
“形成决定”为主要任务的正式报告。skill 触发后会按用途读取模板路由；白皮书、证据审查、
Runbook 和复盘在专用模板尚未落地前继续使用通用 shell，不会误套 A 版。
所有正式 HTML 生产模板都在纸张层保留低对比度 `brawnen` 作品标记，屏幕与打印可见，
但不会进入正文语义、复制文本或阻挡页面交互。
源稿中三个及以上有序阶段、分支、回路、依赖或责任交接会转换为语义化流程图，不把
多行箭头文本或着色文本框当作正式流程图；普通清单和并列事实仍保留原有结构。

### 第三方 skills 试用与安装

第三方 skills 先保存到本仓库的 `vendor/global-skills/` 或 `vendor/project-skills/`，
记录固定提交、来源、许可证和本地适配，再通过 catalog 与发布器安装到指定 agent。
保留上游原文试用，验证效果后再决定是否吸收为第一方能力；不直接维护 agent 目录中的独立副本。
宿主内置和插件管理器托管的 skills 仍由其原管理机制负责。

`trial` 是可选试用 bundle，具体成员以 `config/skills.tsv` 为准。发布时应显式包含需要保留的全部 bundles；
例如 Codex 的现有组合加试用：

```bash
./scripts/publish-skills.sh global --platforms codex --bundles core,architecture,docs,trial
```

### 项目级 UI/UX skill

`project/specialists/design-product-ui` 是本仓库自研 UI/UX 路由 skill 的源码目录，
不属于任何全局 bundle。它在 catalog 中声明了 `ui-ux-pro-max` 和 `impeccable` 两个
项目级运行依赖；发布路由 skill 时，发布器会自动展开并链接完整依赖闭包：

```bash
./scripts/publish-skills.sh project \
  --project /absolute/path/to/project \
  --skills design-product-ui
```

默认结果是：

```text
<project>/.agents/skills/
├── design-product-ui -> <repo>/project/specialists/design-product-ui
├── ui-ux-pro-max    -> <repo>/vendor/project-skills/ui-ux-pro-max
└── impeccable       -> <repo>/vendor/project-skills/impeccable
```

发布脚本不复制 skill，会在写入前检查完整闭包，不覆盖已有实体目录或其他来源的符号链接；
可以用相同参数加 `--check` 验证当前发布结果。

本仓库需要用该 skill 设计或验证自己的正式产物时，也可以把本仓库自身作为
`--project` 目标进行 dogfooding。此时 `.agents/` 只是已忽略的项目运行层，三个 skill
都必须是指向本仓库事实源的受管符号链接，不能保存实体安装副本。

该 skill 是项目 UI/UX 约束与能力适配层：复用用户任务、现有设计系统和平台约束，
协调页面/流程、设计系统和只读评审；明确的小修直接交回宿主。稳定决策按项目约定
记录到现有设计规范，不强制创建根目录 `DESIGN.md`。它按任务选择当前宿主可用的 UI UX Pro Max、
Product Design、Impeccable 或原生能力，不复制这些工具的知识库和实现。

#### 从产品需求到页面设计

“已有基本产品需求，希望设计产品页面”是 `design-product-ui` 的核心使用场景。
按需求成熟度和交付目标选择入口：

| 当前输入与目标 | 使用方式 |
| --- | --- |
| 已明确主要用户、核心任务、功能范围和关键约束，需要设计页面或流程 | 直接使用 `design-product-ui` |
| 需求仍有会改变信息架构、功能边界或验收标准的重要分歧 | 先使用 `decision-clarification` 收敛需求，再进入 `design-product-ui` |
| 需求清楚，但视觉方向仍开放，希望比较多套方案 | 由 `design-product-ui` 建立 brief；UI UX Pro Max 可用时先查询候选，再由 Product Design 或图片生成能力制作可比较方案 |
| 已有完整设计稿或截图，只需要忠实实现 | 不触发 `design-product-ui`；直接使用宿主的 image-to-code 或原生代码实现能力 |
| 页面已经实现，需要评估完整体验和一致性 | Product Design audit 负责截图支持的体验评审；Impeccable 负责代码级 critique、audit、polish、harden 和 detector |

标准责任链是：

```text
基本产品需求
  → decision-clarification（仅在关键产品决定未闭合时）
  → design-product-ui（项目约束、能力选择与决策来源）
      → UI UX Pro Max（仅在需要新候选知识时）
      → Product Design（仅在需要视觉探索、目标实现或体验审计时）
      → Impeccable（仅在需要实际页面打磨和质量检查时）
  → 宿主原生实现与验证（代码、测试、构建、浏览器或设备检查）
```

`design-product-ui` 不要求每次都生成 `DESIGN.md`。只有稳定设计决定需要跨页面、
跨会话复用且没有合适的现有规范时才创建该文件；单页局部调整沿用现有设计系统并做局部验证即可。
UI UX Pro Max 和 Impeccable 已作为固定第三方快照进入该路由的发布闭包；Product
Design 仍是可选的宿主插件，缺失时按路由规则降级，不由本仓库安装。当前快照为 UI UX Pro Max 上游提交 `15de38fb70bc` 和 Impeccable skill `4.3.1`
（提交 `0a4e72a254f3`，引擎 `0.1.5`）；CLI 包版本与 skill 快照独立，来源与升级要求见各自的
`UPSTREAM.md`。产品事实、视觉规范、代码 tokens 和局部 brief 各自有明确职责；工具 sidecar 可以保留，
但应注明派生来源，避免人工重复维护同一事实。

设计模型综合参考了 Impeccable 的设计语言与反模板化、UI UX Pro Max 的跨平台
知识组织、Vercel Web Interface Guidelines 的质量检查、gstack 的方向选择与评审闭环，
以及 Open Design 将项目 `DESIGN.md`、通用 craft 规则和具体 artifact skill 分离的结构；
`design-product-ui` 自身不复制这些能力的知识库或命令路由，固定第三方快照仍保留各自
正常运行所需的脚本和规则，但不启用 hook、daemon 或自动提交。Open Design 当前只作为
架构参考，不属于该 skill 的调用目标。

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

`requirements-clarification` 已合并到 `decision-clarification`：后者保留需求
访谈与可验收 spec，同时增加适用于软件及非软件场景的 grill 压力测试模式。

## 全局 AGENTS

`rules/AGENTS.md` 是用户级 guidance 的事实源，但只保留：

- 中文、简洁、区分已验证与未验证等个人沟通偏好。
- 正式 HTML 与普通 Markdown 的产物偏好。
- 剩余领域 skills 的触发边界。

不要在这里重复 Codex 已经负责的计划、工具选择、编辑安全、测试、Git、提交权限或通用验证规则。项目根目录中的 `AGENTS.md` 应由模型基于真实仓库生成和维护，只记录该项目的真实命令、目录边界、兼容要求和高风险区域。本仓库不维护静态项目规则模板。

## 配置与发布

`config/skills.tsv` 是 skill catalog，统一声明名称、作用域、源码路径、
bundle、退役状态和发布依赖。`config/publish-targets.tsv` 声明 Codex、Claude、Gemini、
Antigravity 以及项目级 `.agents/skills` 的发布落点。脚本不再维护另一份
硬编码 skill 列表。

查看 catalog：

```bash
./scripts/publish-skills.sh list
```

默认将全局 `core` 发布到 Codex 和 Antigravity，并同步全局规则：

```bash
./scripts/publish-skills.sh global
```

按需发布全局 bundle：

```bash
./scripts/publish-skills.sh global \
  --platforms codex,antigravity \
  --bundles core,architecture,strategy,docs
```

只发布到指定全局目录，不同步规则：

```bash
./scripts/publish-skills.sh global \
  --target ~/.codex/skills \
  --bundles core,architecture
```

旧的 `install-links.sh` 和 `sync-global-platforms.sh` 保留为兼容入口，实际都转交给
`publish-skills.sh`。发布器只清理指向本仓库的过期符号链接，不删除其他来源的
skills。Antigravity 的全局目录仍为 `~/.gemini/config/skills`。

结构和元数据检查：

```bash
./scripts/doctor.sh
```

## 目录边界

- `AGENTS.md`：本仓库自身的项目事实、修改约束和验证要求，不参与全局发布。
- `global/specialists/`：可由用户意图直接触发的领域专项。
- `global/helpers/`：专用工具或产物 helper。
- `project/specialists/`：按需发布到具体项目的 skill 源码，不是宿主安装目录。
- `config/`：skill catalog 与发布目标的声明式配置。
- `rules/AGENTS.md`：用户级偏好和剩余 skill 路由。
- `vendor/project-skills/`：随项目级 skill 发布的固定第三方运行快照。
- `vendor/` 其他目录：外部社区参考，不混入默认集合。
- `adapters/`：非 Codex 平台的适配骨架。
- `scripts/`：安装、同步和巡检脚本。
