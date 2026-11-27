# 上游来源

- 仓库：https://github.com/morluto/rea
- 发布标签：`rea-agents-6.10.1`（发布提交 `8bb01b5`，PR `#12737`）
- 源路径：`.agents/skills/reverse-engineer-anything/`
- 运行快照：npm `rea-agents@6.10.1` 的 `skills/reverse-engineer-anything/`（`metadata.version: "63"`，`tool_count: 263`）。
- 获取日期：2026-11-27。
- npm 包：`https://registry.npmjs.org/rea-agents/-/rea-agents-6.10.1.tgz`
- 包完整性：`sha512-3AWrfFEXppvC98FWhZR2Tzulnqs5xJQrSKmAub6+QME/I58Pr3h8pHqqwM30z2DvlnIx/8Hsu8woMngfi4SNyg==`
- 许可证：MIT，原文见 `LICENSE`；不授予外部分析引擎许可证。

`UPSTREAM-SKILL.md` 保留 npm `6.10.1` 发布包中的原始 `SKILL.md`；`SKILL.md` 与 `references/`（含 6.9+ 新增的 `desktop-build.md`）保持发布包原文，仅将本地入口目录、frontmatter `name` 及 `agents/openai.yaml` 统一适配为个人命名空间 `x-rea`，归入可选 `addons` bundle。
上游打包过程已将 `@latest` 固定为 `@6.10.1` 并填入 `tool_count: 263`，其余逆向分析流程与恢复规则未作本地改写。MCP 与 CLI 由 REA 安装单独配置。

更新时先更换本仓库的固定快照（保留 `name: x-rea` 适配）并验证，再通过 catalog/publisher 发布。
REA setup 不接受此受管符号链接；配置 MCP 时使用 `--skill=false` 或手动注册，避免独立副本。
