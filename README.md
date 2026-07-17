# 本地 AI Skills 中央目录

这个目录用于集中管理本地 AI skills 的事实源、安装分层和项目模板。目标不是“装得越多越好”，而是让真正高频、意图明确的 skill 常驻，把专项 skill 和内部 helper 从默认安装面里剥离出去。

## 目录边界

- `global/`：跨项目通用 skills 的事实源。
- `templates/project-local/`：项目模板，只存占位模板，不是最终运行目录。
- `vendor/`：外部社区包参考区，不直接替换主干 skills。
- `adapters/`：面向不同 CLI / agent 的适配骨架。
- `scripts/`：安装链接、结构巡检和后续维护脚本。

## 当前管理模型

### 1. Core

90 天业务会话统计表明，当前 core 不需要再收缩，但需要分层表达：

#### 1.1 默认执行层

这层是默认常驻、最通用的工程执行骨架：

- `safe-editing`
- `task-todolist-execution`
- `task-report`

对应的是“范围控制 / 执行节奏 / 交付汇报”三道基础闸门。

#### 1.2 场景闸门层

这层仍属于 core，但按任务意图触发，不要求每次都命中：

- `repo-intake-scan`
- `requirements-clarification`
- `test-first-development`
- `db-change-safety`

对应的是“新仓库接手 / 需求前置沟通 / 行为变更证明 / 数据库高风险控制”。

#### 1.3 外部常驻补充

以下 skill 从使用频次上看也属于 core，但事实源不在本仓库主干内，因此保留为外部驻留补充：

- `systematic-debugging`

它是高频核心排障闸门，建议常驻，但不由本仓库默认 bundle 直接托管。

#### 1.4 90 天验证事实

以下统计窗口为 `2026-04-05` 至 `2026-07-04`，口径为“业务会话中命中 skill 正文特征”的高置信代理统计：

| skill | 业务会话命中 |
| --- | ---: |
| `task-todolist-execution` | 18 |
| `systematic-debugging` | 16 |
| `task-report` | 12 |
| `repo-intake-scan` | 11 |
| `safe-editing` | 10 |
| `db-change-safety` | 8 |
| `requirements-clarification` | 4 |
| `test-first-development` | 3 |

这组 skill 覆盖大多数“接手仓库 / 需求澄清 / 小中型改动 / 排障 / TDD / 数据库风险 / 最终汇报”的日常工作。

### 2. Specialist

按需安装，不默认常驻：

- `frontend`：
  - `frontend-project-flow`
- `docs`：
  - `code-evidence-docs`
  - `formal-html-docs`
- `incident`：
  - `production-incident-hotfix`
  - `project-release-scope-check`
  - `codegraph-assisted-navigation`
  - `architecture-friction-scan`

原则：只有当用户意图明显命中该领域，或者当前会话会长期停留在该领域时，才值得挂上。

### 3. Internal Helpers

这些内容继续保留在仓库里，但不作为默认顶层全局 skill 安装：

- `doc-converter`

它们更像被其它 skill 间接调用的模板 / 输出壳 / 工具说明，而不是用户会直接表达的任务意图。

`formal-html-docs` 是例外：虽然定位仍是 helper，不是高频用户意图入口，但为了统一正式 HTML 文档样式，建议作为 `docs` bundle 的全局可用能力安装。

### 4. External / Unmanaged

不在本仓库主干里统一管理的 skill，例如：

- `pdf`
- `taste-skill`
- 第三方 `code-review`
- 其它来自 `.skillshub` 或社区来源的 skill

这些可以继续存在于用户本机，但不应反向主导本仓库的主干结构。

## 生命周期原则

1. 先判断它是不是“用户意图级 skill”。
2. 如果只是输出模板、格式壳子或内部工具说明，降级为 helper，不默认安装。
3. 如果核心规则已经被别的 skill 吸收，就下线重复 skill。
4. 如果 skill 只适合窄场景且正文很重，移出 core，改为 specialist。

当前已执行的收缩原则：

- 验证纪律统一收口到 `task-report`，不再依赖单独的 `verification-before-completion`。
- `formal-html-docs` 仍作为 helper 保留，但为了统一正式 HTML 文档样式，建议随 `docs` bundle 全局可用安装。
- `frontend-project-flow` 保留，但作为 specialist，只在前端交付流里按需启用。
- `systematic-debugging` 继续视为高频核心能力，但按外部驻留处理，不反向污染本仓库主干边界。

## 安装方式

使用 [install-links.sh](/Users/lijianfeng/ai-skills/scripts/install-links.sh)。

默认安装仓库内托管的 `core` 到 `~/.codex/skills`：

```bash
./scripts/install-links.sh
```

安装指定 bundles：

```bash
./scripts/install-links.sh ~/.codex/skills core docs
./scripts/install-links.sh ~/.codex/skills core frontend incident
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

- `safe-editing`
- `task-todolist-execution`
- `task-report`
- `repo-intake-scan`
- `requirements-clarification`
- `test-first-development`
- `db-change-safety`

外部驻留的 `systematic-debugging` 不由本仓库直接安装；如果本机已有来源，安装脚本和巡检脚本会给出提示。

`docs` bundle 当前托管的是：

- `code-evidence-docs`
- `formal-html-docs`

其中 `formal-html-docs` 的定位仍是 helper，但正式 HTML 交付默认应走它，避免不同任务各自产生不一致的 HTML 样式。

`sync-global-platforms.sh` 的同步口径是：

- 以 `~/.codex/AGENTS.md` 为全局规则事实源
- 以 `~/.codex/skills` 当前集合为目标集合
- 仓库托管 skills 通过 `install-links.sh core docs` 安装
- 外部 skills 额外补齐：
  - `systematic-debugging`
  - `code-review`
  - `pdf`
  - `taste-skill`

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
