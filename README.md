# 本地 AI Skills 中央目录

这个仓库只维护当前 coding agent 没有原生覆盖的专项决策模型、工具适配和项目验证协议。通用的计划管理、仓库探索、局部澄清、安全编辑、普通故障修复、常规测试和 Git 纪律由宿主自身负责，不再包装成 skills 或全局 AGENTS 规则。

所有自有与全局扩展入口统一采用 **`x-*` 私人短前缀命名空间**：在任意宿主中输入 `$x-` 或 `/x-` 即可直接筛选出个人技能集，并彻底避免与各宿主的内置斜杠命令（如 `/model`、`/review`、`/plan`）发生名称冲突。

## 取舍原则

一个能力只有满足以下至少一项才保留为独立入口：

- 包含明确的领域风险模型（如数据库迁移锁与回滚、生产事故止损、红队破坏实证）。
- 包含会显著改变执行顺序、反馈循环或系统边界判断的可复用工程决策模型。
- 依赖当前实际使用、且宿主原生能力未覆盖的专用工具协议（如二进制/发行包逆向）。
- 产出固定且可复用的非原生产物（如自包含可打印正式 HTML 文档、项目自有 `verify-<app>`）。

仅改变交接格式或单步执行纪律的能力（单任务编码、任务图并行集成、原型小实验、变更运行验真、PR 说明、测试部署与生产发布包准备）统一沉淀为 `docs/workflow-protocols/` 下的共享协议，由主干入口按需读取，不拆成冗余的薄壳 skill。

## 当前 Skills 矩阵

全局能力收敛为 **`core`（局部增强工具箱）+ `flow`（软件研发全流程）+ `addons`（重外部依赖按需扩展）** 三个 bundle，日常通过 `--bundles core,flow` 即可在所有宿主一次对齐。

### 1. `core`：局部增强工具箱（7 项，全平台常驻）

| skill | 核心定位 | 边界（不负责） |
| --- | --- | --- |
| `x-debug` | 疑难/偶发/性能故障的可证伪反馈循环、同前提连败质疑前提、生产止损与性能基准 7 问 | 根因明确的普通 bugfix |
| `x-db` | DDL、索引、迁移、回填与生产写入风险评估，附在线 DDL 锁与事务高频事故核查表，联动静态 SQL 门禁 | 纯只读查询、普通业务代码验证 |
| `x-arch` | 只读架构体检：优先围绕 `git log` 高频变更热点识别浅模块、耦合泄漏与测试困难，核对既有 ADR 冲突 | 普通仓库接手、单次改动影响分析 |
| `x-redteam` | 显式红队对抗审查：在隔离工作区设法破坏改动或方案，**仅保留经真实运行复现证明的缺陷** | 常规代码与规范审查（用 `x-review`） |
| `x-biz` | 商业模式/单位经济快算、市场与四类竞品深挖、新业务综合可行性与 Go/Stop 阶段投资门 | 已有明确需求的软件设计、通用科普 |
| `x-html` | 自包含、可打印的正式 HTML 文档外壳与流程图语义转换，统一五级证据状态标签 | 普通 Markdown、README、ADR 及 Word/PDF |
| `x-tdd` | 仅在显式要求 TDD 时启用：对比候选测试缝（seam）得失，严格执行 RED-GREEN-REFACTOR | 普通回归测试、集成与 E2E 调度 |

### 2. `flow`：软件研发全流程主线（10 项，覆盖需求分析 → 生产发布交接）

| skill | 在研发全流程中的职责 | 调用方式 |
| --- | --- | --- |
| `x-dev` | **全流程总控入口**：按缺口串联需求、规格、实施、验证、审查、CI/测试部署 smoke 与人工生产发布 Runbook；也支持单跑发布准备 | 显式调用（`$x-dev`） |
| `x-req` | 依赖感知分轮访谈：收敛模糊目标、范围与业务验收契约，或对想法/计划做压力测试 | 场景匹配 / 显式 |
| `x-domain` | 领域建模：统一业务术语、澄清身份/状态/生命周期与上下文边界，按需维护 `GLOSSARY.md` 与 ADR | 场景匹配 / 显式 |
| `x-api` | 前后端接口契约：复用四字段响应、HTTP/业务错误分层、流式 SSE 错误帧、写幂等 `Idempotency-Key`、页码/游标分页及版本兼容规则 | 场景匹配 / 显式 |
| `x-spec` | 技术与验收规格：锁定架构边界、测试缝与独立 AC，执行界面设计就绪检查（衔接项目级 `x-ui`）；同会话可内联实施顺序 | 场景匹配 / 显式 |
| `x-tasks` | 独立任务拆解：仅在多人领取、跨会话恢复或并行任务图需求下拆解行为切片与真实阻塞边（含 JSON 图校验脚本） | 显式调用（`$x-tasks`） |
| `x-review` | 代码双轴审查：固定比较基线，独立审查项目规范（Standards，含反逃生舱检查）与需求符合性（Spec，不以 PASS 免审） | 场景匹配 / 显式 |
| `x-guard` | 项目静态门禁：接手空白/存量/开源项目建立检查底座（含服务端 SQL 静态写门禁），按“第二次原则”将复发失误编码为带测试的自定义规则 | 场景匹配 / 显式 |
| `x-verify` | 项目运行自测底座：基于仓库事实建立或维护项目自有 `verify-<app>` 与功能地图，实跑证明正常及拒绝路径 | 场景匹配 / 显式 |
| `x-retro` | 会话环境复盘：从真实会话日志与运行证据提炼检查、导航与规范改进候选，机械问题转交 `x-guard` 落地 | 显式调用（`$x-retro`） |

### 3. `addons`：重外部依赖按需扩展（1 项，按需挂载）

| skill | 核心定位 | 说明 |
| --- | --- | --- |
| `x-rea` | 基于 REA 分析原生二进制、发行包、Android/Electron、UEFI/固件、桌面环境构建与运行态证据 | 固定快照 `rea-agents@6.10.1`（`tool_count: 263`）位于 [vendor/global-skills/x-rea](vendor/global-skills/x-rea/UPSTREAM.md)，MCP/CLI 独立配置 |

---

## 研发全流程与共享协议

`$x-dev` 是端到端交付总控，各阶段共享方法统一维护于 [docs/workflow-protocols/](docs/workflow-protocols/)，交付产物与状态定义以 [docs/delivery-artifacts-spec.md](docs/delivery-artifacts-spec.md) 为准：

```text
需求澄清 (x-req / x-domain)
  → 契约、UI 就绪与技术规格 (x-api / x-ui / x-spec)
  → 编码实施 (implementation.md；跨会话或授权并行时用 x-tasks + parallel-implementation.md)
  → 运行验证与双轴审查 (verification.md + x-review；高风险压测用 x-redteam)
  → CI 门禁、测试环境自动部署 smoke 与人工生产发布 Runbook (release.md，数据库迁移联动 x-db)
  → 会话复盘与静态规则沉淀 (x-retro → x-guard)
```

- 小且明确的改动直接由宿主实施与验证，不生成形式化的空 spec 或任务单。
- 代码合并遵循用户授权、项目分支策略和必要门禁；测试环境在授权门禁通过后可自动部署并执行 smoke；**生产部署、回滚与生产数据写入始终由人执行**，agent 负责生成可执行发布包并在允许范围内做只读观察。
- `x-html` 内置两款生产模板：`decision-brief.html`（`executive-sunrise` 主题，用于商业可行性与阶段投资决策）和 `engineering-review.html`（`blueprint-slate` 主题，内置工程概览条、Before/After 架构对比双栏、纯 CSS 语义流程图与折叠证据抽屉，用于架构扫描、技术规格、发布 Runbook 与复盘报告）。所有模板保留极低对比度 `brawnen` 纸张层水印，五级证据标签与 `x-biz` 完全对齐。

---

## 项目级 UI/UX 路由（`x-ui`）

`project/specialists/x-ui` 是项目级 UI/UX 约束与能力路由 skill，声明了 `ui-ux-pro-max` 与 `impeccable` 两个固定第三方项目级运行依赖（第三方依赖保持上游原名并关闭隐式调用）：

```bash
./scripts/publish-skills.sh project \
  --project /absolute/path/to/project \
  --skills x-ui
```

发布结果均为受管符号链接（`.agents/skills/x-ui`、`ui-ux-pro-max`、`impeccable`），自动清理同项目下已退役的旧受管链接（`design`、`design-product-ui`），不覆盖非受管实体目录（如项目自有的 `verify-<app>`）。当前快照为 UI UX Pro Max 上游提交 `8db36338810d` 和 Impeccable skill `4.11.0`（提交 `9e460a87ef33`，引擎 `0.1.30`），来源与升级边界见各自的 `UPSTREAM.md`。

---

## 配置、发布与验证

- `config/skills.tsv`：唯一 skill catalog（保留全部历史改名与退役记录供发布器自动清理旧软链）。
- `config/publish-targets.tsv`：Codex、Claude Code、Gemini、Antigravity 与项目级 `.agents/skills` 目标配置。
- `rules/AGENTS.md`：同步到各宿主的用户级沟通偏好、路由原则与交付标准。

常用命令：

```bash
# 查看当前启用 skills
./scripts/publish-skills.sh list

# 将日常完整能力（工具箱 + 全流程）同步到四平台并更新全局规则（需明确授权时执行）
./scripts/publish-skills.sh global \
  --platforms codex,claude,gemini,antigravity \
  --bundles core,flow

# 在指定平台额外挂载逆向扩展包
./scripts/publish-skills.sh global \
  --platforms codex \
  --bundles core,flow,addons

# 检查已安装平台链接与规则一致性（只读）
./scripts/publish-skills.sh global --check \
  --platforms codex,claude,gemini,antigravity \
  --bundles core,flow
```

本地与 CI 统一隔离验证门禁（不修改用户家目录真实安装）：

```bash
./scripts/check-workflow.sh
```
