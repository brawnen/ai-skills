---
name: project-release-scope-check
description: 适用于多模块、多仓库或高风险功能上线前核对发布范围；输出必须发、条件发、可不发、验证命令、回滚/阻塞和未确认项。不要用于单文件小改或纯本地实验。
---

# Project Release Scope Check

## Use when

- 用户要求“再 check 一下需要发布什么”“告诉我发布步骤”“哪些模块必须发”。
- 变更跨多个服务、前端、API 包、配置、依赖版本或发布流水线。
- 需要区分功能主链路、后台配置页、兼容入口、可选运维操作。

## Coordinate with existing skills

- 修改代码时同时遵守 `safe-editing`。
- 涉及数据库写入或 migration 时先用 `db-change-safety`。
- 进入执行阶段时配合 `task-todolist-execution`，收尾用 `task-report`。

## Workflow

1. 先确认用户给出的发布目标和明确不在范围内的内容。
2. 从真实代码入口反查模块落点，不只沿用旧 TODO 或服务名猜测。
3. 如果项目存在 `.codegraph/` 或用户要求使用 CodeGraph，先用它生成候选影响面：
   - `codegraph query <symbol>` 定位入口和实现。
   - `codegraph callers <symbol>` / `codegraph callees <symbol>` 梳理上下游。
   - `codegraph impact <symbol> --depth 2` 生成候选影响范围。
   - 输出时必须标注哪些是 CodeGraph 候选，哪些已通过源码、配置、前端调用或构建验证确认。
4. 建立链路分层：
   - 功能主链路：缺失会导致用户功能不可用。
   - 配置/后台链路：只在需要生产配置调整时发布。
   - 兼容/观测链路：影响旧入口、日志、审计、回滚。
5. 检查每个候选模块的证据：controller/API、前端调用、服务实现、POM/package 依赖、脚本或配置。
6. 给出发布分层结论：
   - 必须发
   - 条件发
   - 可不发
   - 禁止顺手发
7. 为每一层写清验证方式，优先使用项目已有 harness、build、lint、test、smoke 或 XML/脚本语法检查。
8. 如本地无法验证，保留原始错误并说明影响范围。

## Output

```markdown
## 发布范围结论

| 层级 | 模块/仓库 | 原因 | 证据 | 验证 |
| --- | --- | --- | --- | --- |
| 必须发 |  |  |  |  |
| 条件发 |  |  |  |  |
| 可不发 |  |  |  |  |

## 发布顺序
1. ...

## 阻塞与未确认
- ...

## 回滚/兜底
- ...
```

## Guardrails

- 不把“某服务名出现过”当作必须发布证据。
- 不把功能主链路和后台配置页混为一谈。
- 不把 tag、分支、流水线触发口径写成假设；需要从当前项目事实确认。
- 不声称“可发布”除非验证已执行，或明确列为未验证。
- 不把 CodeGraph `impact` 的全部 affected symbols 直接等同为发布清单；它只是候选集。
