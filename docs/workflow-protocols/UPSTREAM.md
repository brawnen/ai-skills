# 方法来源与本地适配

- 主上游：https://github.com/mattpocock/skills
- 固定版本：v1.3.2（提交 `abeeaf95660ba9e8b7c753eb38f441ca707a8823`）
- 原文及完整许可证：`vendor/mattpocock/`；文件摘要与符号链接清单：`vendor/mattpocock.snapshot.json`。
- MIT 许可副本：同目录 `LICENSE.mattpocock`（Copyright (c) 2026 Matt Pocock）。
- 补充方法论参考（仅吸收决策模型与检查清单，未打包第三方私有运行时）：
  - `garrytan/gstack`（`vendor/gstack/` 及 v1.102.x 方法论：`/office-hours` 最小价值切口、`/design-shotgun` 单页对比选样、`/qa` + `/design-review` 三视口实景走查、`/document-release` 权威文档原位防腐败同步、`/deslop-shared-libs` 反 AI 胶水膨胀）；
  - `cursor/plugins`（`pstack` 0.15.46，提交 `7a583913eb1b8d1a0ee76753d1a2cf072e7b54f9`：`interrogate` 红队实证、`blast-radius` 可证伪假设、`correct` 第二次原则编码与 `reflect`）。

## 适配关系

- `x-req` / `requirements.md`：融合 `grilling`、`grill-with-docs` 与 `domain-modeling`（原 `x-domain` 已并入），统一承载依赖感知访谈、领域术语/状态边界建模（按需维护 `GLOSSARY.md` 与 `ADR`）及 `gstack /office-hours` 的现状替代基线与 20% 首日核心切口追问。
- `x-spec` / `spec.md` / `tickets.md`：参考 `to-spec` / `to-tickets` 与 `tdd` v1.3.2 的候选测试缝（seam）得失对比（原独立 `x-tasks`、`x-tdd` 已退役内联，同会话直接实施，跨会话交接按需读取 `tickets.md` 与 `scripts/check-task-graph.py`）。
- `implementation.md` / `parallel-implementation.md`：参考 `implement` / `implement-spec` 与 `tdd` 红绿重构纪律，结合前端三视口实检。
- `verification.md` / `x-verify` / `x-ui`：结合 Matt Pocock 变异反向证明与 `gstack /qa` + `/design-review` 的 `375px / 768px / 1440px` 内置浏览器真实点击走查、Console/网络异常检查与缺陷回归固化。
- `x-review` / `review.md`：参考 `code-review` 双轴审查、`pstack` 反逃生舱检查与 `gstack /deslop-shared-libs` 的重复胶水代码收敛检查。
- `x-redteam`：借鉴 `pstack` `interrogate` 的隔离副本红队破坏实证（仅保留真实运行复现缺陷，只报告不自动改代码）。
- `x-guard`：融合 `pstack` `correct` 第二次原则四件套、三类项目底座、SQL 静态写门禁、Matt Pocock `setup-ts-deep-modules`（`dependency-cruiser` 深模块根入口边界与三步咬合实证）以及 `retro` 会话环境复盘（原 `x-retro` 已并入）。
- `pr.md` / `release.md` / `wizard-setup.md`：结合 `pr`（最小可视化）、`gstack /document-release`（对照 diff 原位同步既有权威文档）、Matt Pocock `wizard`（`scripts/wizard-template.sh` 第三方后台与 `.env` / GitHub Secrets 交互式向导）及测试环境部署 smoke、人工生产发布 Runbook 交接。
- `x-arch` / `architecture-design.md`：参考 `improve-codebase-architecture`（Git 变更热点优先与 ADR 冲突核对）、`codebase-design` 与重复胶水识别。
- `authoring.md`：吸收 `writing-for-agents`（含 `SKILL-MECHANICS.md` 逐句 No-op 测试与常驻成本权衡）及 `chief-of-staff` 的历史结论绑定日期与 commit 规则。
- `prototype.md` / `cross-boundary-design.md`：按需共享协议。

## 本地差异

- 自管全局入口统一采用 `x-*` 命名空间（Codex 显示名为 `X·四字中文`），常驻 `core + flow` 精简为 **14 个高辨识度主入口**（外加 `addons` 按需逆向包 `x-rea` 与 `ui-deps` 底层依赖）。
- 消除与各宿主内置工作流重复的薄壳入口与全局规则冗余；生产部署、回滚与生产数据写入始终保持人工执行红线。
