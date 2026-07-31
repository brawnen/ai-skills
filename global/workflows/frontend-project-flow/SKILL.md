---
name: frontend-project-flow
description: "Optional end-to-end frontend orchestration skill. Use only when the user explicitly wants a complete frontend delivery flow spanning requirement clarification, project scan, design direction, implementation, visual verification, audit, and handoff. Ordinary page changes, standalone UI design, or requirement discussion should use the relevant specialist skill directly."
---

# Frontend Project Flow

## Purpose

Coordinate a complete frontend delivery flow from user requirement to verified UI. Treat this skill as the router and stage manager; it does not replace the specialized tools.

This is an optional domain workflow, not a default global intent. If the request covers only one stage, route directly to that stage's specialist instead of loading the entire flow.

Default stack of responsibility:

- Use `requirements-clarification` for product scope, page inventory, acceptance criteria, and non-goals.
- If当前环境已安装 `impeccable`，将它作为唯一默认设计 skill；品牌页面使用 brand register，后台、dashboard、工具和产品界面使用 product register。
- Codex 的 Product Design 插件只用于明确的视觉探索、参考克隆、产品流程审查或原型分享，不替代日常实现中的 `impeccable`。
- 默认使用现有仓库设计系统、组件和样式变量；不要假设存在额外前端设计插件或外部 workflow。
- Use existing engineering skills (`task-todolist-execution`, `safe-editing`, `test-first-development`) for implementation discipline.

## First Move

Classify the request before acting:

1. **Just discussing the flow**: answer with a recommendation; do not edit files.
2. **Creating or updating a reusable workflow/skill**: use `skill-creator`, then validate the skill.
3. **Running the flow on a real project**: inspect the repo first, then create a stage plan.
4. **Building UI now**: confirm the design brief before implementation unless the user explicitly provided a confirmed visual target.

If the user asks for a complete project flow and implementation in one turn, split it into gates. Do not jump from vague requirement directly to code.

## Stage Gates

Run stages in order unless the user explicitly asks for a subset:

1. **Intake**: clarify users, goal, register (`brand` or `product`), core flows, target surfaces, constraints, and acceptance criteria.
2. **Project Context**: inspect existing repo, design system, dependencies, routes, components, and runnable commands.
3. **Design Direction**: if there is no visual target for a new UI,先输出简短设计方向并确认，再开始实现；使用 `impeccable` 的 brand/product register 约束方向。
4. **Delivery Plan**: decompose into pages/components/states/assets/tests. Use `task-todolist-execution` for non-trivial work.
5. **Implementation**: use the existing framework and component patterns. Do not create a parallel project when a project already exists.
6. **Visual Verification**: run the app, inspect in Browser/Playwright/screenshots, and fix layout, responsiveness, overlap, contrast, and broken assets.
7. **Hardening**: cover loading, empty, error, disabled, long text, i18n-sensitive, keyboard, reduced-motion, and mobile states.
8. **Audit/Polish**: run manual visual and UX checks. 使用 `impeccable` 做与当前界面类型匹配的 critique、audit 或 polish，不额外叠加第二套设计 skill。
9. **Report**: summarize actual changes and verification evidence. Clearly separate verified and unverified paths.

## Routing References

Read only the relevant reference file:

- Read `references/routing.md` when choosing between ordinary delivery, Impeccable design work, and Codex Product Design exploration.
- Read `references/delivery-stages.md` when running a full frontend project flow.
- Read `references/quality-gates.md` before claiming the UI is ready.

## Hard Rules

- Do not install third-party skills, run `npx`, add dependencies, or enable hooks without user approval.
- Do not let design guidance override product usability, accessibility, platform conventions, or existing design-system constraints.
- Do not skip visual verification for frontend work. A build passing is not enough.
- When a repo already has design tokens/components, preserve them unless there is a concrete defect.
- For brand/marketing pages, require real visual assets or generated images when the subject needs imagery.
- For product/admin/tools, prefer dense, utilitarian, repeatable UI over decorative landing-page composition.

## Common Invocations

- "Use `frontend-project-flow` to turn this product brief into a frontend implementation plan."
- "Use `frontend-project-flow` to route this task through engineering delivery and the appropriate Impeccable register."
- "Use `frontend-project-flow` to build this page from requirements through prototype, implementation, audit, and polish."
- "Use `frontend-project-flow` to create a project-local frontend delivery workflow for this repo."
