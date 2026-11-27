# impeccable 来源记录

- 上游：https://github.com/pbakaus/impeccable
- 固定提交：`9e460a87ef338ee9d12c7beed8fedc597a5af5f7`（2026-11-24）
- 获取日期：2026-11-25
- 版本口径：Codex skill 4.11.0，scripts/VERSION 引擎 0.1.30。
- 许可证：上游根目录 LICENSE（Apache-2.0），第三方归属见 NOTICE.md，两份均随快照保留。

## 来源与本地适配

直接同步固定提交内的 `.agents/skills/impeccable/`，保留上游正文、agents 角色定义、参考材料、启动器及引擎校验清单。仅 agents/openai.yaml 使用本仓库的展示与调用元数据，关闭隐式调用。UPSTREAM.md 由本仓库维护。

项目通过受管链接使用此快照。启动器按平台选择引擎；首次下载使用 scripts/engine-checksums.txt 校验。升级验收使用临时 IMPECCABLE_HOME。
