# ui-ux-pro-max 来源记录

- 上游：https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- 固定提交：`8db36338810d0942567b97ce439affd1619fcf31`（2026-11-25）
- 获取日期：2026-11-25
- 版本口径：上游 `skill.json` 标注 2.15.0，同提交生成器 `cli/package.json` 为 2.5.0。按 Git 提交锁定资源。
- 许可证：上游根目录 LICENSE（MIT），随快照保留。

## 生成与本地适配

在临时 checkout 的 cli/ 执行 `npm ci --ignore-scripts --no-audit --no-fund`、`npm run build`，在空目录运行 `node <checkout>/cli/dist/index.js init --ai codex --offline`。提取生成的核心 `.agents/skills/ui-ux-pro-max/`，将 SKILL.md 原文保存为 UPSTREAM-SKILL.md，原样同步 data/ 和 scripts/。

SKILL.md 为本地轻量检索入口，agents/openai.yaml 为宿主适配，保留显式调用策略。升级先更新项目快照，再从项目链接核对检索参数与结果。
