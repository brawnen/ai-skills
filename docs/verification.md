# 本仓库的验证入口

本仓库交付的是 skills、协议、发布器和配套工具，已有脚本可直接验证，不强制另建 verify-ai-skills skill。可从仓库根运行以下 local/CI 共用门禁：

```bash
./scripts/check-workflow.sh
```

依赖 Bash、Python 3 标准库、Git，以及可绑定 127.0.0.1 随机端口的环境；不调用模型、不访问业务账号、不修改真实用户安装。独立的官方 skill frontmatter 校验使用宿主 skill-creator 的 quick_validate.py，路径依宿主安装，不纳入可移植脚本依赖。

## 验证范围

- doctor：当前源码、catalog、scope、依赖和元数据约束；外部参考快照不当作已安装 skill。
- publish-skills-test：临时目标安装、依赖闭包、冲突、退役迁移、外部实体/链接保护。
- workflow-contract-test：任务图、上游原文摘要、发布资源可读、真实临时 Git worktree 集成及冲突保留。
- verification-flow-test：真实样例 HTTP/隔离 SQLite 正常和拒绝行为、目标变异、版本错配、环境失败、隔离与证据保护。
- formal-html-docs-test：已有 HTML helper 的模板与布局结构约束。

需要保留本轮工作流机制证据时，用全新目录，不能覆盖以前的运行工件：

```bash
./scripts/check-workflow.sh --artifacts /absolute/path/to/new-evidence-directory
```

该参数为 workflow-contract-test 保留 JSON 原始结果；其他门禁输出由 CI 日志或调用者保存。证据范围为确定性机制演练，不证明多模型协作质量或业务项目 E2E。

## 状态、观察与清理

图校验失败会非零退出；非法依赖、环和提前完成不能进入 ready frontier。发布测试不覆盖用户实体目录或外部链接，工作区冲突测试保留未合入任务再在本次临时仓库中中止合并。临时目录/worktree 自动清理，显式指定的证据目录保留；Python 缓存由运行参数关闭。

HTTP 端口无法绑定时是环境阻塞，不能改成成功。结构检查、模型行为、实际业务与远端 CI 分别报告。真实全局发布与 --check 按已确认目标另行执行；检查脚本不会发布到用户目录。

CI 可直接运行同一门禁命令，不绑定 GitHub/其他 provider。本仓库没有业务服务 staging 或生产部署，不伪造这两个 target；实际业务项目需补各自账号、运行协议、制品和环境事实。
