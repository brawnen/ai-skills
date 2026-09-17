# impeccable 来源记录

- 上游：https://github.com/pbakaus/impeccable
- 固定提交：`0a4e72a254f3b175c95b36b82e5f2e60fa63f116`（2026-09-15）
- 获取日期：2026-09-16
- 版本口径：skill 4.3.1；scripts/VERSION 引擎 0.1.5；npm CLI 4.1.0 与 skill 版本独立。
- 许可证：见 LICENSE；Impeccable 的第三方归属另保留 NOTICE.md。

## 生成与本地适配

直接使用上游提交内 .agents/skills/impeccable 的 Codex 产物。

保留上游正文和运行资源；本地仅维护 agents/openai.yaml、来源记录和许可证副本。
升级先更新本仓库固定快照，再验证；不要在目标项目单独覆盖或运行自动 update。

## 运行变化

旧版 Node 脚本入口已由 scripts/impeccable 启动器替代。启动器首次运行会获取固定引擎 0.1.5 并核对 SHA-256；网络/权限不可用时按 SKILL.md 的降级路径读取项目上下文。
本次仅在临时 IMPECCABLE_HOME 中验证引擎，未把二进制提交进仓库、未启用 hook 或安装全局引擎。
