# ui-ux-pro-max 来源记录

- 上游：https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- 固定提交：`15de38fb70bc80ae9276fa7703b48ae861a672e6`（2026-09-15）
- 获取日期：2026-09-16
- 版本口径：GitHub 固定提交生成；该提交 CLI package.json 为 2.5.0，npm latest 仍为 2.15.0，不能用 CLI 标签表示快照新旧。
- 许可证：见 LICENSE；Impeccable 的第三方归属另保留 NOTICE.md。

## 生成与本地适配

在临时 checkout 的 cli/ 执行 npm ci --ignore-scripts --no-audit --no-fund、npm run build，再于隔离目录运行 node <checkout>/cli/dist/index.js init --ai codex --offline。仅提取生成的核心 ui-ux-pro-max，不引入额外子 skills。

保留上游正文和运行资源；本地仅维护 agents/openai.yaml、来源记录和许可证副本。
升级先更新本仓库固定快照，再验证；不要在目标项目单独覆盖或运行自动 update。
