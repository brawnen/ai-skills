# AI Skills 仓库协作说明

## 仓库定位

本仓库是个人 AI skills 的源码与发布仓库，不是业务应用或宿主安装目录。

- 只维护 Codex harness 未原生覆盖的专项决策模型、工具适配和项目级能力。
- 全局和项目级 skill 都以本仓库中的目录为唯一源码，通过符号链接发布。
- 不在本仓库创建 `.agents/skills`、`.codex/skills` 等安装副本。
- 不恢复静态项目模板；目标项目的 `AGENTS.md` 应根据其真实代码与约束生成。

## 事实源

- `config/skills.tsv`：skill 名称、scope、源码、bundle 和退役状态。
- `config/publish-targets.tsv`：各平台及项目级 skill 的默认发布目标。
- 各 skill 的 `SKILL.md`：触发条件、流程和能力边界。
- 各 skill 的 `agents/openai.yaml`：宿主展示与调用元数据。
- `rules/AGENTS.md`：发布到宿主的用户级偏好与全局 skill 路由。
- 根目录 `AGENTS.md`：只约束本仓库，不参与全局规则发布。
- `README.md`：面向使用者的能力说明与公开命令。

不要在脚本或文档中建立与 `config/` 平行的 skill 清单。

## 目录边界

- `global/specialists/`：可由用户意图直接触发的全局领域专项。
- `global/helpers/`：专用工具协议或固定产物 helper。
- `project/specialists/`：按需发布到具体项目的 skill 源码。
- `rules/`：用户级全局规则源，不存放本仓库的技术事实。
- `scripts/`、`tests/`：发布实现、兼容入口、巡检和隔离测试。
- `vendor/`：外部社区项目参考，不自动进入 catalog 或默认 bundle。
- `adapters/`：非 Codex 平台的适配骨架。

## 必须保持的契约

- skill 目录名、catalog 名称和元数据中的 `$<skill-name>` 必须一致。
- active skill 的 scope 必须与 `global/` 或 `project/` 源码目录一致，并提供
  `SKILL.md` 和 `agents/openai.yaml`。
- 退役 skill 在 catalog 中保留 `retired` 记录，源码字段设为 `-`；不要直接删行。
- 发布器只创建符号链接，拒绝覆盖实体目录或其他来源的链接。
- 清理范围只能是指向本仓库的受管链接。
- 移动或重命名源码会使已有绝对符号链接失效，必须说明需要重新发布的目标。
- 修改发布参数、筛选、清理或规则同步行为时，同步更新发布器测试。

## 发布边界

- `./scripts/publish-skills.sh global` 会修改用户目录中的链接并同步全局规则，
  只在用户明确要求真实发布时执行。
- 项目发布会修改目标项目的 `.agents/skills`，需要明确的目标项目。
- 验证发布器应使用临时目录、测试脚本或 `--check`，不能用真实全局发布代替测试。

## 验证

文档或 catalog 变更至少运行：

```bash
./scripts/doctor.sh
git diff --check
```

skill、元数据或发布行为变更还应运行：

```bash
./tests/publish-skills-test.sh
bash -n scripts/publish-skills.sh scripts/install-links.sh \
  scripts/sync-global-platforms.sh scripts/doctor.sh tests/publish-skills-test.sh
```
