# Routing

在前端任务里，先判断这是普通工程交付、界面设计，还是 Codex 专属的视觉探索 / 原型任务。

## 默认路径

大多数任务直接走工程交付路径：

- `requirements-clarification`：明确页面范围、关键状态、验收标准
- `task-todolist-execution`：多阶段、有依赖或高风险验证的前端任务维护 TODO
- `safe-editing`：兼容性敏感或影响面不明时控制改动范围
- `test-first-development`：行为变更或 bugfix 需要先补测试时使用
- 宿主 Agent 原生收尾：说明实际改动、验证、未验证项和风险

## 默认设计 skill

当前环境安装了 `impeccable` 时，将它作为唯一默认设计 skill：

- Landing、品牌官网、Portfolio 和营销页面使用 brand register。
- Admin、dashboard、internal tools、数据表格、表单、设置和 onboarding 使用 product register。
- 新界面设计、现有界面重设计、视觉升级、UX 审查、响应式和可访问性优化都由 `impeccable` 负责。
- 已有设计系统时先复用现有 token、组件和交互模式，再按需调用对应命令。

不要再叠加 `taste-skill`、Anthropic `frontend-design` 或其它通用设计 skill，避免规则冲突和重复上下文。

## Product Design 何时使用

Codex 的 Product Design 插件保持按需能力，只在用户明确调用，或任务核心是以下目标时使用：

- 在编码前生成并比较多个视觉方向。
- 基于 URL、截图、Figma 或 mockup 做参考克隆和交互原型。
- 对完整产品流程做截图驱动的 UX / 可访问性审查。
- 对照视觉来源做 design QA，或发布可分享的轻量原型。

普通页面实现、组件修改、后台开发和生产级 polish 默认走 `impeccable`，不自动启用 Product Design。

## 非设计任务

以下任务不调用设计 skill：

- 纯后端、API、数据库、基础设施和非 UI 脚本。
- 普通正式文档生成；这类任务直接走 `formal-html-docs`。
- 只修改文案、链接或无视觉影响的机械变更。

## 决策句式

先给一句判断：

- “这是产品界面任务，按现有设计系统实现，并使用 Impeccable 的 product register 做设计与验收。”
- “这是品牌表达任务，使用 Impeccable 的 brand register 建立视觉方向。”
- “这是视觉探索 / 原型任务，明确调用 Codex Product Design，选择方向后再进入生产实现。”
