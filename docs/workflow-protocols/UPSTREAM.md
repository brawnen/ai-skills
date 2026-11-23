# 方法来源与本地适配

- 上游：https://github.com/mattpocock/skills
- 固定版本：v1.3.2
- 完整提交：abeeaf95660ba9e8b7c753eb38f441ca707a8823
- 原文及完整许可证：vendor/mattpocock/；文件摘要与符号链接清单：vendor/mattpocock.snapshot.json。
- MIT 许可副本：同目录 LICENSE.mattpocock（Copyright (c) 2026 Matt Pocock）。
- 补充方法参考：https://github.com/cursor/plugins（`pstack` 0.15.46，提交 `7a583913eb1b8d1a0ee76753d1a2cf072e7b54f9`，仅方法论吸收，未打包上游原文）。

## 适配关系

requirements：沿用本仓库需求/压力测试方法，参考 grilling/grill-with-docs（含 v1.3.2 的推荐默认“是”措辞与事实探索不阻塞就绪决策）。
spec/tickets：参考 to-spec/to-tickets，保留纵向行为、独立判据、真实阻塞边与 expand–contract。
implementation/parallel-implementation：参考 implement/implement-spec。
开工核对任务归属和原始标题、拆分时分别复用原生子项和阻塞边，参考 Matt Pocock 1.3.2 的 [implement](https://github.com/mattpocock/skills/blob/abeeaf95660ba9e8b7c753eb38f441ca707a8823/skills/engineering/implement/SKILL.md) 与 [to-tickets](https://github.com/mattpocock/skills/blob/abeeaf95660ba9e8b7c753eb38f441ca707a8823/skills/engineering/to-tickets/SKILL.md)。本地也支持以仓库 Markdown 台账作为任务来源。
review：参考 code-review 的 Standards + Spec 双轴，保留 PASS 场景独立审查。

审查协议另外借鉴了 [Matt Pocock 1.3.2 的规范查找方法](https://github.com/mattpocock/skills/blob/abeeaf95660ba9e8b7c753eb38f441ca707a8823/skills/engineering/code-review/SKILL.md)、[Lauren Tan 的 pstack blast-radius](https://github.com/cursor/plugins/blob/7a583913eb1b8d1a0ee76753d1a2cf072e7b54f9/pstack/skills/blast-radius/SKILL.md) 中验证关键假设的方法，以及 `pstack` `comment-sicko` / `principle-minimize-reader-load` / `principle-subtract-before-you-add` 的反逃生舱与结构负担检查。本地沿用同一双轴协议，既有证据充分时直接复用。

interrogate：借鉴 `pstack` `interrogate`（0.15.46）的红队对抗实证思路（仅保留经真实运行复现证明打破原意图的发现），本地化为不绑定固定模型或编排器的独立可选 skill。
setup-guardrails：吸收 `pstack` `correct`（0.15.46）与 `principle-encode-lessons-in-structure` 的历史失误归类、真实历史红灯、豁免三要素与规则退场机制，并结合三类项目适配底座。

pr：参考 pr；其最小可视化方法来自 Dex Horthy / Humanlayer show-me。上游原始归属见 vendor/mattpocock/skills/engineering/pr/CREDITS.md，本地不依赖安装 show-me。
retro/authoring：参考 retro/writing-for-agents；prototype：参考 prototype；architecture-design：参考 codebase-design、本地 scan-architecture 及 `pstack` 的 `boundary-discipline` / `type-system-discipline` / `separate-before-serializing-shared-state`。
复盘也参考 [pstack reflect](https://github.com/cursor/plugins/blob/0b46ec399d55f2829e88822998f53b84944837d3/pstack/skills/reflect/SKILL.md) 的做法：先读相关 skill，再决定经验应落在哪里。本地同时核对当时的协议版本、调用记录与项目接线，避免重复添加指令。
cross-boundary-design：由本仓库已退役 review-cross-stack-change 方法迁入。验证与发布结构继续以 docs/delivery-artifacts-spec.md 为准。

verify-change / debug：人为制造失败时先对照原副本核实变异，再核对失败原因，参考 [Matt Pocock diagnosing-bugs 的回归验证](https://github.com/mattpocock/skills/blob/abeeaf95660ba9e8b7c753eb38f441ca707a8823/skills/engineering/diagnosing-bugs/SKILL.md#phase-5-fix--regression-test)；`debug` 另吸收 `pstack` `principle-attack-the-premise`（同前提连败 2 次质疑前提）与 `benchmark-checklist`（性能测量 7 问清单）。

## 本地差异

独立审查借鉴 Matt 1.3.2 在 [code-review](https://github.com/mattpocock/skills/blob/abeeaf95660ba9e8b7c753eb38f441ca707a8823/skills/engineering/code-review/SKILL.md) 与 [implement-spec](https://github.com/mattpocock/skills/blob/abeeaf95660ba9e8b7c753eb38f441ca707a8823/skills/engineering/implement-spec/SKILL.md) 中使用新上下文的做法。“先留存初判、再给实现者说明”是本地交接约定。

使用第一方中文入口与单一共享协议；不发布上游整包，不重复安装同义入口。
沿用已有项目事实、tracker、文档位置与授权，不强制每阶段确认或安装专门 setup skill。
implement/pr 仅为协议；TDD、子代理、上下文切换和全量测试按任务选择，不自动要求。
规格到实施之间增加按需的界面设计就绪检查，补齐页面/交互方案后回写规格；原型只用于待验证问题，不把设计变成固定审批或强制安装项。
保留安全基线与用户工作区，不采用上游盲目 reset；集成后检查实际版本，按项目权限合并，生产操作仍由人执行。
原型必须运行代表性操作并保留证据，不将探索代码默认为生产实现；复盘先提出候选，不自动更改全局偏好。
上游文件保持原文，升级先比较固定版本差异再适配。此说明不把作者经验称为本团队已验证收益。
