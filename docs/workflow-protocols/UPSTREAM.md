# 方法来源与本地适配

- 上游：https://github.com/mattpocock/skills
- 固定版本：v1.3.2
- 完整提交：abeeaf95660ba9e8b7c753eb38f441ca707a8823
- 原文及完整许可证：vendor/mattpocock/；文件摘要与符号链接清单：vendor/mattpocock.snapshot.json。
- MIT 许可副本：同目录 LICENSE.mattpocock（Copyright (c) 2026 Matt Pocock）。
- 补充方法参考：https://github.com/cursor/plugins（`pstack` 0.15.46，提交 `7a583913eb1b8d1a0ee76753d1a2cf072e7b54f9`，仅方法论吸收，未打包上游原文）。

## 适配关系

- `x-req` / `requirements.md`：沿用本仓库需求与压力测试访谈方法，参考 grilling/grill-with-docs（含 v1.3.2 的推荐默认“是”措辞与事实探索不阻塞就绪决策）。
- `x-spec` / `x-tasks`（`spec.md` / `tickets.md`）：参考 to-spec/to-tickets，保留纵向行为、独立判据、真实阻塞边与 expand–contract；支持仓库 Markdown 台账与平台原生父子/阻塞关系。
- `implementation.md` / `parallel-implementation.md`：参考 implement/implement-spec（不单独立全局 skill，统一由 `x-dev` 与宿主按需复用）。
- `x-review` / `review.md`：参考 code-review 的 Standards + Spec 双轴审查，结合 `pstack` `blast-radius` 的可证伪关键假设验证与反逃生舱/结构负担检查。
- `x-redteam`：借鉴 `pstack` `interrogate`（0.15.46）的红队对抗实证思路（仅保留经真实运行复现证明打破原意图的发现），本地化为模型无关入口。
- `x-guard`：吸收 `pstack` `correct`（0.15.46）与 `principle-encode-lessons-in-structure` 的第二次原则、四件套交付与存量豁免机制，结合三类项目底座与 SQL 静态写门禁。
- `pr.md`：参考 pr；最小可视化方法源于 Dex Horthy / Humanlayer show-me（上游归属见 `vendor/mattpocock/skills/engineering/pr/CREDITS.md`），已退役独立的 `show-me` 试用包。
- `release.md`：本地原创扩展，补齐 Matt 主线未覆盖的 CI 门禁验真、环境变量/迁移发布顺序、测试环境自动部署 smoke 与人工生产发布 Runbook 交接。
- `verification.md` / `x-debug`：由原 `verify-change` 收回为共享验证协议；变异反向证明参考 `diagnosing-bugs` Phase 5，`x-debug` 另结合同前提连败 2 次质疑前提与性能测量 7 问清单。
- `x-tdd`：吸收 v1.3.2 的候选测试缝（seam）得失对比（能捕获什么 vs 会漏掉什么）。
- `x-arch` / `architecture-design.md`：参考 improve-codebase-architecture（含 Git 变更热点优先与 ADR 冲突核对）、codebase-design 及 `pstack` 边界校验集中化/强类型不变量原则。
- `x-retro` / `authoring.md`：参考 retro/writing-for-agents 与 `pstack` `reflect`。
- `prototype.md` / `cross-boundary-design.md`：分别由已退役 `prototype`、`review-cross-stack-change` 收回为按需共享协议。

## 本地差异

- 自管第一方与全局扩展入口统一采用 `x-*` 私人短前缀命名空间，避免与各宿主内置斜杠命令冲突；全局能力收敛为 `core`（增强工具箱）、`flow`（研发全流程）、`addons`（重外部依赖按需扩展）三组。
- `implement`、`implement-spec`、`prototype`、`verify-change`、`pr`、`release` 均作为共享协议维护于 `docs/workflow-protocols/`，减少常驻入口冗余。
- 规格到实施之间保留界面设计就绪检查（衔接项目级 `x-ui`）；集成合并遵循用户授权与门禁，生产部署、回滚与生产数据写入维持人工执行红线。
