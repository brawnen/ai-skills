---
name: code-evidence-docs
description: 适用于把代码梳理、依赖清单、设计方案、发布流程、runbook 或仓库说明沉淀成正式文档；必须区分代码已确认、调用关系推断、未验证和待确认项。正式交付文档可调用 formal-html-docs 作为内部 HTML 外壳，README/AGENTS/轻量开发说明仍用 Markdown。
---

# Code Evidence Docs

## Use when

- 用户要求“整理成文档”“放到 docs”“补 README/AGENTS”“不要主流程概述，要依赖清单”。
- 需要从真实代码、配置、脚本、数据库表或前端调用生成可维护文档。
- 需要把设计讨论转成正式 proposal、guide、checklist 或 repo contributor guide。

## Workflow

1. 先确认文档目的和格式：README/AGENTS/轻量开发说明用 Markdown；正式代码证据文档、依赖清单、设计方案、排障 runbook、架构说明可调用 `formal-html-docs` 作为内部 HTML 外壳输出。
2. 读取真实文件，不凭记忆写架构；优先找入口、调用方、配置、数据表和验证命令。
3. 如果项目存在 `.codegraph/` 或用户要求使用 CodeGraph，先用它生成结构化候选证据：
   - `codegraph query <symbol>` 查入口、类、接口、测试。
   - `codegraph callers/callees <symbol>` 查调用方向。
   - `codegraph impact <symbol>` 查候选影响面。
   - 文档中要把 CodeGraph 结果归入“根据调用关系推断”，除非已经回读源码/配置并验证。
4. 建立证据分层：
   - 代码中已确认
   - 根据调用关系推断
   - 未验证/受环境限制
   - 待产品/运维/DBA/业务确认
5. 如果用户要求依赖清单，优先表格化：前置条件、触发入口、核心实现、外部依赖、失败行为、验证方式。
6. 如果用户要求设计方案，必须包含：范围、非范围、核心流程、数据/接口影响、幂等/补偿/回滚、验收标准。
7. 如果输出 HTML，使用 `formal-html-docs` 的 Common Shell、证据 badge、callout、表格和打印样式；它是内部 helper，不要求额外作为顶层全局 skill 常驻安装。章节结构按文档用途选择，不强行统一。
8. 如果文档需要长期维护，优先同时保留 Markdown 源稿和 HTML 交付稿。
9. 如果用户要求仓库说明或 AGENTS，保持短、密、命令可执行，引用的脚本和目录必须来自当前仓库事实，并使用 Markdown。
10. 修改 docs 导航时只补必要链接，不重排无关文档。

## Output patterns

### Evidence summary

```markdown
## 代码中已确认
- ...

## 根据调用关系推断
- ...

## 未验证
- ...

## 待确认
- ...
```

### Dependency table

```markdown
| 环节 | 代码/配置证据 | 前置条件 | 失败行为 | 验证方式 |
| --- | --- | --- | --- | --- |
```

### Formal HTML

正式 HTML 文档必须配合 `formal-html-docs`：

- 统一视觉外壳：标题、更新时间、摘要、目录、主体、风险/未确认项、下一步。
- 证据状态使用 badge：已确认、推断、未验证、待确认。
- 章节结构按文档用途选择：设计方案、runbook、风险评估、发布说明等各自不同。
- 不依赖外部 CSS/JS，不引入前端构建链。

## Guardrails

- 不把历史口头概念直接写成系统事实。
- 不把“员工/会员/访客”等业务身份混用；先声明本次文档采用的边界。
- 不把原始资料源写成已复核产品知识层。
- 没有跑过的验证不能写成已验证。
- 不把 CodeGraph 输出直接写成“代码中已确认”；除非已经打开对应文件和行号复核。
- 不为了 HTML 样式牺牲证据分层和未确认项表达。
