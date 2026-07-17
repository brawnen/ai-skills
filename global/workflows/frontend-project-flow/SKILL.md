---
name: frontend-project-flow
description: End-to-end frontend delivery workflow for Codex. Use when the user wants a reusable local flow for taking product requirements through clarification, project scan, visual direction, frontend implementation, responsive polish, UX/a11y audit, and handoff. This skill is a router: it coordinates existing local skills instead of depending on external frontend-only systems by default.
---

# Frontend Project Flow

## Purpose

Coordinate a complete frontend delivery flow from user requirement to verified UI. Treat this skill as the router and stage manager; it does not replace the specialized tools.

Default stack of responsibility:

- Use `requirements-clarification` for product scope, page inventory, acceptance criteria, and non-goals.
- If当前环境已安装额外的视觉设计 skill（例如 `design-taste-frontend`），只在 landing / marketing / portfolio / redesign 这类品牌表达任务中按需调用。
- 默认使用现有仓库设计系统、组件和样式变量；不要假设存在额外前端设计插件或外部 workflow。
- Use existing Codex engineering skills (`task-todolist-execution`, `safe-editing`, `test-first-development`, `task-report`) for implementation discipline.

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
3. **Design Direction**: if there is no visual target for a new UI,先输出简短设计方向并确认，再开始实现；品牌表达型页面才考虑额外 taste-oriented skill。
4. **Delivery Plan**: decompose into pages/components/states/assets/tests. Use `task-todolist-execution` for non-trivial work.
5. **Implementation**: use the existing framework and component patterns. Do not create a parallel project when a project already exists.
6. **Visual Verification**: run the app, inspect in Browser/Playwright/screenshots, and fix layout, responsiveness, overlap, contrast, and broken assets.
7. **Hardening**: cover loading, empty, error, disabled, long text, i18n-sensitive, keyboard, reduced-motion, and mobile states.
8. **Audit/Polish**: run manual visual and UX checks. Only在存在额外视觉 skill 且场景明确命中时，才做品牌 / 营销导向的 taste pass。
9. **Report**: use `task-report` after code/config changes. Clearly separate verified and unverified paths.

## Routing References

Read only the relevant reference file:

- Read `references/routing.md` when choosing whether this task只需要工程交付，还是还需要额外的视觉 taste pass。
- Read `references/delivery-stages.md` when running a full frontend project flow.
- Read `references/quality-gates.md` before claiming the UI is ready.

## Hard Rules

- Do not install third-party skills, run `npx`, add dependencies, or enable hooks without user approval.
- Do not let taste-oriented guidance override product usability, accessibility, or existing design-system constraints.
- Do not skip visual verification for frontend work. A build passing is not enough.
- When a repo already has design tokens/components, preserve them unless there is a concrete defect.
- For brand/marketing pages, require real visual assets or generated images when the subject needs imagery.
- For product/admin/tools, prefer dense, utilitarian, repeatable UI over decorative landing-page composition.

## Common Invocations

- "Use `frontend-project-flow` to turn this product brief into a frontend implementation plan."
- "Use `frontend-project-flow` to decide whether this task只需要工程落地，还是还需要额外的视觉 taste pass."
- "Use `frontend-project-flow` to build this page from requirements through prototype, implementation, audit, and polish."
- "Use `frontend-project-flow` to create a project-local frontend delivery workflow for this repo."
