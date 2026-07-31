# 本地 AI Skills 中央目录

这个目录用于集中管理本地 AI skills 的事实源、安装分层和项目模板。目标不是“装得越多越好”，而是让真正高频、意图明确的 skill 常驻，把专项 skill 和内部 helper 从默认安装面里剥离出去。

## 目录边界

- `global/workflows/`：跨阶段编排和执行状态管理。
- `global/specialists/`：可按用户意图直接触发的领域专项能力。
- `global/helpers/`：由流程或专项间接调用的产物和工具 helper。
- `rules/AGENTS.md`：Codex、Claude Code、Gemini 和 Antigravity 用户级规则的唯一事实源。
- `templates/project-local/`：项目模板，只存占位模板，不是最终运行目录。
- `vendor/`：外部社区包参考区，不直接替换主干 skills。
- `adapters/`：面向不同 CLI / agent 的适配骨架。
- `scripts/`：安装链接、结构巡检和后续维护脚本。

## 当前管理模型

公开能力按“流程 + 专项”设计，物理目录与逻辑分类保持一致；helper 和工具适配器不作为顶层用户意图入口：

- **流程 skill**：跨阶段编排、维护状态并决定何时交给哪个专项 skill；不重复专项规则。
- **专项 skill**：只对一个问题领域、风险或产物负责；即使内部有步骤，也不接管完整任务生命周期。
- **内部 helper / 工具适配器**：被流程或专项 skill 间接调用；只有明确需要对应产物或工具时才加载。

### 1. 默认全局集合

#### 1.1 通用流程

- `task-todolist-execution`：只用于多阶段、有依赖、长时间或高风险实施任务；普通短任务由 agent 直接完成。

#### 1.2 自动触发专项

| skill | 唯一职责 | 不负责 |
| --- | --- | --- |
| `repo-intake-scan` | 陌生仓库的根目录、技术栈和验证入口 | 架构体检、正式文档 |
| `requirements-clarification` | 收敛未确认的目标、方案和验收边界 | 记录已确定的代码事实 |
| `safe-editing` | 兼容性敏感或影响面不明的现有代码改动 | 普通低风险修改、执行计划 |
| `test-first-development` | 对已明确行为建立 red-green 证据 | 未知根因诊断、事故止损 |
| `db-change-safety` | DDL、迁移、回填和生产写入风险 | 纯只读查询、通用任务状态 |
| `code-evidence-docs` | 基于现有代码事实沉淀可维护文档 | 推动需求决策、HTML 视觉外壳 |
| `production-incident-hotfix` | 生产事件边界、止损、恢复和交接 | 系统化根因诊断方法 |
| `project-release-scope-check` | 上线前制品范围、顺序、验证和回滚决策 | 实施结果汇报 |

#### 1.3 全局内部 helper

- `formal-html-docs`：提供统一正式 HTML 外壳，由文档专项间接调用。

#### 1.4 外部常驻补充

- `systematic-debugging`：未知故障的证据驱动根因诊断。
- `impeccable`：默认 UI 设计、审查和优化能力。

#### 1.5 90 天验证事实

以下统计窗口为 `2026-04-05` 至 `2026-07-04`，口径为“业务会话中命中 skill 正文特征”的高置信代理统计：

| skill | 业务会话命中 |
| --- | ---: |
| `task-todolist-execution` | 18 |
| `systematic-debugging` | 16 |
| `task-report`（历史，现已退役） | 12 |
| `repo-intake-scan` | 11 |
| `safe-editing` | 10 |
| `db-change-safety` | 8 |
| `requirements-clarification` | 4 |
| `test-first-development` | 3 |

这组统计用于判断是否值得保留，不用名称出现次数扩大触发范围。`task-report` 的历史命中主要来自统一收尾路由，不代表独立用户意图；其验证纪律已收口到全局规则和宿主 Agent 原生汇报。低频但高风险的 TDD、数据库、事故和发布专项仍应全局可用，依靠精确 description 自动触发。

### 2. 可选流程与专项

默认不同步，明确进入对应长流程或工具环境时再安装：

| bundle | skills | 原因 |
| --- | --- | --- |
| `frontend` | `frontend-project-flow` | 完整前端交付才需要；单页设计或实现直接用专项能力 |
| `architecture` | `architecture-friction-scan`、`codegraph-assisted-navigation` | 架构体检低频；CodeGraph 还依赖项目索引和宿主工具 |
| `tools` | `doc-converter` | 依赖本机 macOS、Word 和转换 CLI |

`docs`、`incident` bundle 保留为兼容别名；其中能力已经包含在默认 `core` 中。

## 生命周期原则

1. 只有跨阶段编排才定义为流程 skill；不能因为正文有步骤就归为流程。
2. 专项 skill 必须声明唯一职责、明确不负责什么，以及上下游交接对象。
3. 流程 skill 不复制专项规则，只维护阶段、状态和路由。
4. helper 可以全局存在以保证统一产物，但 description 必须阻止其抢占顶层用户意图。
5. 依赖特定项目索引、平台或本机工具的能力不进入默认全局集合。

当前已执行的收缩原则：

- `task-report` 与宿主 Agent 原生收尾及全局验证纪律重复，已退役；实施结束按实际复杂度简洁说明改动、验证、未验证项和风险。
- 通用代码审查使用 Codex 等 Agent 的原生审查能力；项目特殊检查写入项目级规则，不再同步外部 `code-review-excellence`。
- `formal-html-docs` 作为全局 helper 保留，由正式文档专项间接使用。
- `frontend-project-flow` 保留为可选领域流程，只在完整前端交付流里按需启用。
- `taste-skill` 已退役；设计任务统一使用外部驻留的 `impeccable`，避免多套设计规则重叠。
- Codex Product Design 保持插件级按需能力，仅用于视觉探索、参考克隆、流程审查和原型分享，不参与跨平台全局 skill 同步。
- `systematic-debugging` 继续视为高频核心能力，但按外部驻留处理，不反向污染本仓库主干边界。
- PDF 文件处理不再由本仓库托管全局 skill；Codex 使用官方 `pdf@openai-primary-runtime` 插件，避免重复路由。

## 安装方式

使用 [install-links.sh](/Users/lijianfeng/ai-skills/scripts/install-links.sh)。

默认安装仓库内托管的 `core` 到 `~/.codex/skills`：

```bash
./scripts/install-links.sh
```

安装指定 bundles：

```bash
./scripts/install-links.sh ~/.codex/skills core
./scripts/install-links.sh ~/.codex/skills core frontend
./scripts/install-links.sh ~/.codex/skills core architecture tools
```

查看可用 bundles：

```bash
./scripts/install-links.sh --list
```

一键把 Codex 当前全局规则与 skill 集合同步到 Claude / Gemini / Antigravity：

```bash
./scripts/sync-global-platforms.sh
```

只做一致性检查,不写任何全局目录：

```bash
./scripts/sync-global-platforms.sh --check
```

做严格一致性检查,额外校验每个 skill 的解析后目标路径是否与 Codex 一致：

```bash
./scripts/sync-global-platforms.sh --deep-check
```

`core` bundle 当前托管的是：

- `task-todolist-execution`
- `repo-intake-scan`
- `requirements-clarification`
- `safe-editing`
- `test-first-development`
- `db-change-safety`
- `code-evidence-docs`
- `production-incident-hotfix`
- `project-release-scope-check`
- `formal-html-docs`

外部驻留的 `systematic-debugging` 不由本仓库直接安装；如果本机已有来源，安装脚本和巡检脚本会给出提示。

`frontend` bundle 当前托管的是：

- `frontend-project-flow`

`architecture` bundle 托管 `architecture-friction-scan` 和 `codegraph-assisted-navigation`；`tools` bundle 托管 `doc-converter`。

视觉设计统一由外部驻留的 `impeccable` 负责：品牌页面使用 brand register，后台、dashboard、工具和产品界面使用 product register。

`sync-global-platforms.sh` 的同步口径是：

- 以仓库内 `rules/AGENTS.md` 为全局规则事实源，并同步到 Codex、Claude Code、Gemini
- 同步前强制检查规则文件非空及关键区块；覆盖非空旧文件前写入各平台 `rule-backups/`
- 以 `~/.codex/skills` 当前集合为目标集合
- 仓库托管 skills 通过 `install-links.sh core` 安装
- 外部 skills 额外补齐：
  - `systematic-debugging`
  - `impeccable`

当前已验证的目标目录包括：

- `~/.claude/skills`
- `~/.gemini/skills`
- `~/.gemini/config/skills`
- `~/.gemini/antigravity-ide/skills`

其中 Antigravity 运行时的 `~/.gemini/antigravity/skills` 当前是指向 `~/.gemini/config/skills` 的符号链接。

## 维护原则

1. 项目专属 rules 不放 `global/`，而应放到具体项目仓库的 `.ai-skills/` 与项目级上下文文件中。
2. `templates/project-local/` 只保存项目模板，真实项目落地时再复制到项目根目录。
3. `vendor/` 中的社区包仅做参考和试验，不得整包混入主干。
4. 安装脚本的 bundle 定义必须和实际 skill 生命周期一致，避免“仓库里有，默认全装上”。
