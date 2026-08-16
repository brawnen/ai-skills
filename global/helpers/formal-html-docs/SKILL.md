---
name: formal-html-docs
description: 可选的正式 HTML 文档外壳与章节模板 helper。仅在用户明确需要自包含、可打印的 HTML 正式文档时使用；README、AGENTS、普通分析和宿主已支持的 Word/PDF 文档不触发。
---

# Formal HTML Docs

## 定位

为正式文档提供统一、自包含、可打印的 HTML 外壳。它只负责视觉、文档类型结构和 HTML 交付质量，不替代上游 skill 的事实查证、需求决策或风险分析。

- README、AGENTS、轻量 ADR、开发说明和短记录仍使用 Markdown。
- 用户或项目已有格式、模板和设计系统优先。
- 不因主题相关就自动触发；只有正式 HTML 交付才加载本 skill。

## 工作流

1. 确认文档用途、读者、维护方式和项目已有格式。
2. 选择最接近的文档类型。需要章节建议时只读取 [document-types.md](references/document-types.md) 中对应部分，不加载无关章节。
3. 项目已有 HTML 模板或设计系统时优先使用。否则读取
   [template-routing.md](references/template-routing.md)，只加载匹配用途的生产模板；当前
   `decision-report` 使用 [decision-brief.html](assets/templates/decision-brief.html)。没有匹配
   模板时使用 [formal-document-shell.html](assets/formal-document-shell.html)，不硬套 A 版。
4. 复制所选资产，替换全部占位符并删除不适用模块；交付稿不得残留 `{{...}}`、示例内容或空章节。
5. 接收上游已确认内容，保留已确认、推断、未验证和待确认等证据状态，不自行改变事实层级。
6. 生成单个自包含 HTML：内联 CSS，不依赖远程 CDN 或前端构建链。
7. 检查标题、摘要、目录、主体、风险/未确认项和下一步是否按需存在；不要为了模板完整而填空。
8. 验证文件存在、HTML 结构、目录锚点和关键内容；实际渲染桌面、窄屏和打印表现，无法渲染时明确说明。

## 视觉约束

- 风格专业、克制、偏技术出版物；培训讲义可以强化课程节奏，但不做营销页。
- 标题区默认使用明亮、低饱和的浅蓝到青蓝渐变和深海军蓝文字，避免厚重深蓝实底。
- `Executive Sunrise` 允许用珊瑚橙和少量阳光黄强化判断、机会及章节节奏；亮色不能替代风险或证据语义。
- 正文阅读列约 760-860px；长目录桌面端可用左侧阅读索引，窄屏回落为单列。
- 使用语义化 HTML；表格窄屏可横向滚动，代码块可读，callout 和 badge 不能只靠颜色传达含义。
- 打印时使用白底，隐藏无关装饰，避免标题、表格行、代码块被生硬截断。

## 内容与证据

统一外壳通常包括标题、更新时间、摘要、目录和主体；风险、未确认项、下一步只在确实存在时加入。

证据状态统一使用：`已确认`、`推断`、`未验证`、`待确认`。颜色只是辅助，正文必须保留文字标签。

## 输出

- 文件名遵循项目约定；无约定时使用 `docs/specs/YYYY-MM-DD-<topic>.html` 或 `docs/reports/YYYY-MM-DD-<topic>.html`。
- 需要长期维护时，可同时保留 Markdown 源稿和 HTML 交付稿。
- 最终说明实际生成路径、执行过的检查和未完成的视觉验证。

## Guardrails

- 不使用远程 CSS/JS、外部字体或构建链，除非用户明确要求。
- 不把所有文档套进同一章节结构。
- 不把 `decision-brief` 用于白皮书、证据工作台、Runbook 或时间线复盘。
- 不生成只有视觉包装、缺少来源和验证边界的报告。
- 不在用户要求 Markdown、README、AGENTS 或 ADR 时强行改成 HTML。
