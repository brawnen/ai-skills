# 上游来源

- 仓库：https://github.com/morluto/rea
- 发布标签：`rea-agents-6.8.0`
- 固定提交：`160d821ac9a0310afcb8d1fc427862dd6508add5`
- 源路径：`.agents/skills/reverse-engineer-anything/`
- 运行快照：npm `rea-agents@6.8.0` 的 `skills/reverse-engineer-anything/`。
- 获取日期：2026-10-25。
- npm 包：`https://registry.npmjs.org/rea-agents/-/rea-agents-6.8.0.tgz`
- 包完整性：`sha512-9QDeRnGqEDzABZyr04eLnBXBv/c6I9/TWu/6M0MD4pEfkySI/BIgwTODIbAReX3C1x6hjw9+Jlx4A2yUSPZ9ww==`
- 许可证：MIT，原文见 `LICENSE`；不授予外部分析引擎许可证。

`SKILL.md` 与 references 保持 npm 发布包原文；`UPSTREAM-SKILL.md` 保留固定提交原文。
上游打包过程将 `@latest` 固定为 `@6.8.0` 并填入 `tool_count: 229`，其余 references 一致。
本地只附加本来源记录、许可证副本与 `agents/openai.yaml`，不改写上游分析流程。
可选 bundle 为 `rea`，本次发布目标为 Codex。MCP 与 CLI 由 REA 安装单独配置。

更新时先更换本仓库的固定快照并验证，再通过 catalog/publisher 发布。
REA setup 不接受此受管符号链接；配置 MCP 时使用 `--skill=false` 或手动注册，避免独立副本。
