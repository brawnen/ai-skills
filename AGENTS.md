# AI Skills 仓库协作说明

## 仓库定位

本仓库是个人 AI skills 的源码与发布仓库；也可以作为项目级 skill 的本地 dogfooding
目标，用于设计和验证本仓库自己的正式产物。

- 只维护 Codex harness 未原生覆盖的专项决策模型、工具适配和项目级能力。
- 全局和项目级 skill 都以本仓库中的目录为唯一源码，通过符号链接发布。
- 第一方源码位于 `global/` 和 `project/`；需要随项目级路由 skill 一起分发的固定版本
  第三方运行包位于 `vendor/project-skills/`；第三方全局 skill 位于 `vendor/global-skills/`。`.agents/skills` 只允许保存发布器创建的
  符号链接，不是源码或安装事实源。
- 不恢复静态项目模板；目标项目的 `AGENTS.md` 应根据其真实代码与约束生成。

## 事实源

- `config/skills.tsv`：skill 名称、scope、源码、bundle、退役状态和发布依赖。
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
- `vendor/project-skills/`：经来源和许可证核对、需要随项目发布的固定第三方快照。
- `vendor/global-skills/`：经来源和许可证核对的第三方全局 skill 固定快照。
- `vendor/` 的其他目录：外部社区参考，不自动进入 catalog 或默认 bundle。
- `adapters/`：非 Codex 平台的适配骨架。

## 必须保持的契约

- skill 目录名、catalog 名称和元数据中的 `$<skill-name>` 必须一致。
- active skill 的 scope 必须与 `global/`、`project/` 或允许的
  `vendor/project-skills/`、`vendor/global-skills/` 源码目录一致，并提供 `SKILL.md` 和 `agents/openai.yaml`。
- catalog 依赖必须指向同 scope 的 active skill；项目发布必须展开完整依赖闭包。
- 退役 skill 在 catalog 中保留 `retired` 记录，源码字段设为 `-`；不要直接删行。
- 发布器必须先检查完整依赖闭包，再创建符号链接；拒绝覆盖实体目录或其他来源的链接，
  并避免依赖冲突时留下部分发布结果。
- 清理范围只能是指向本仓库的受管链接。
- 移动或重命名源码会使已有绝对符号链接失效，必须说明需要重新发布的目标。
- 修改发布参数、筛选、清理或规则同步行为时，同步更新发布器测试。

## 第三方 skill 引入

- 用户要求引入的第三方 skills 一律先下载到本项目，再统一发布到明确指定的 agent；不要直接在 agent 目录中建立独立源码副本。
- 保留上游原文、固定提交、来源记录及许可证；宿主适配元数据与本地改动单独注明。
- 全局与项目级分别放在对应 vendor 目录，并登记 catalog；试用使用可选 bundle，不自动加入默认 core。
- 安装后使用指向项目快照的符号链接。升级先更新项目，再验证和发布；不自动迁移宿主内置或插件管理器托管的 skills。

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
./tests/formal-html-docs-test.sh
bash -n scripts/publish-skills.sh scripts/install-links.sh \
  scripts/sync-global-platforms.sh scripts/doctor.sh tests/publish-skills-test.sh \
  tests/formal-html-docs-test.sh
```
