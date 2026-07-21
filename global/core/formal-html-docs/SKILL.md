---
name: formal-html-docs
description: 内部 HTML 文档外壳与章节模板 helper。全局安装以保证正式 HTML 的统一视觉，但只由正式文档路由按需触发；优先由 code-evidence-docs、requirements-clarification 等文档型 skill 间接使用。
---

# Formal HTML Docs

## Positioning

这个 skill 主要提供“正式 HTML 文档外壳和模板约定”，不是普通任务的高频用户意图入口。

- 可以全局安装以提供稳定模板，但不应因主题泛泛相关而自动触发。
- 更推荐由 `code-evidence-docs`、`requirements-clarification`、`architecture-friction-scan` 等上层文档型 skill 间接引用。
- README、AGENTS、轻量开发说明仍优先 Markdown，不要为了“统一”而强行转 HTML。

## Goal

生成正式、自包含、适合浏览器阅读和打印的 HTML 文档。统一的是视觉外壳和证据表达，不强制所有文档共用同一套章节。

## Default

- 输出单个自包含 `.html` 文件，内联 CSS，不依赖前端构建链。
- 风格专业、克制、工程咨询报告感；不要营销页、不要花哨动效。
- 正文阅读列默认控制在约 760-860px；长目录文档可在桌面端使用侧栏目录，移动端回落为单列，打印友好。
- 使用语义化 HTML：`header`、`main`、`section`、`article`、`table`、`code`。
- 文件命名优先遵循项目约定；无约定时使用 `docs/specs/YYYY-MM-DD-<topic>.html` 或 `docs/reports/YYYY-MM-DD-<topic>.html`。

## Common Shell

所有正式 HTML 文档都应包含：

- 标题
- 更新时间
- 摘要
- 目录
- 主体内容
- 风险 / 未确认项，如果存在
- 下一步，如果存在

不要把 Common Shell 当作内容章节模板。不同文档类型选择不同章节。

## Document Type Templates

### 需求 / Spec

- 背景
- 目标
- 非目标
- 用户 / 业务场景
- 已确认事实
- 待确认问题
- 推荐方案
- 备选方案
- 接口 / 数据 / 流程影响
- 验收标准
- 验证方式
- 执行边界

### 设计方案

- 背景与约束
- 设计目标
- 当前方案 / 当前问题
- 推荐设计
- 关键流程
- 数据 / 接口 / 依赖影响
- 取舍
- 风险
- 验证计划
- 迁移 / 回滚

### 培训讲义 / 教材

- 适用对象与前置知识
- 学习目标
- 课程地图 / 阅读路径
- 核心概念与方法
- 示例、现场演示或练习
- 关键结论 / 常见误区
- 课后行动或延伸阅读

### 架构扫描报告

- 扫描范围
- 已确认证据
- 架构摩擦候选
- Top Recommendation
- 候选详情
- 测试缝 / 可维护性影响
- 未验证项
- 建议下一步

### Runbook / 排障手册

- 适用场景
- 症状识别
- 快速判断
- 排查步骤
- 临时止血
- 长期修复
- 验证方式
- 回滚 / 升级路径
- 联系人 / 依赖系统，如适用

### 发布说明 / 发布计划

- 发布目标
- 发布范围
- 必发 / 条件发 / 不发
- 前置条件
- 发布步骤
- 验证步骤
- 回滚方案
- 风险与观察项

### 复盘报告

- 摘要
- 时间线
- 影响范围
- 根因
- 处置过程
- 做得好的地方
- 问题与缺口
- 后续行动
- 责任人与截止时间，如适用

### 风险评估 / 分析报告

- 摘要
- 分析范围
- 已确认事实
- 关键发现
- 风险分级
- 影响面
- 建议方案
- 未确认项
- 下一步

## Section Selection Rules

- 先判断文档用途，再选模板；不要把所有模板章节混在一起。
- 只保留对读者决策有帮助的章节，避免为了完整而填空。
- 用户或项目已有文档结构优先。
- 培训讲义和教材优先采用“学习目标 -> 内容路径 -> 示例/练习 -> 关键结论”的结构；可使用讲师提示、现场演示、学员练习等 callout，但不要伪装成风险或证据状态。
- 需要长期维护时，可以同时保留 Markdown 源稿和 HTML 交付稿。
- README、AGENTS、轻量 ADR、开发说明默认仍用 Markdown。

## Evidence Badges

证据状态用一致的 badge 文案：

- 已确认
- 推断
- 未验证
- 待确认

不要用颜色替代文字；颜色只是辅助。

## CSS Requirements

每个 HTML 文档至少包含这些样式能力：

- 视觉应服从文档用途：spec、runbook、架构报告保持克制的技术出版物感；培训讲义可更强调课程层次和阅读节奏，但不做营销页。
- 稳定的标题区和元信息区。默认使用明亮、低饱和的浅蓝到青蓝渐变，配深海军蓝文字；避免厚重的深蓝实底或深蓝渐变。
- 多级目录较长时，桌面端优先作为正文左侧的阅读索引，而不是大面积内容卡片；窄屏必须回落为正文前的普通目录。
- 自动或手写目录区。
- 表格可读，窄屏可横向滚动。
- 代码块浅灰背景、等宽字体、可换行或横向滚动。
- callout 支持 note / risk / warning / success。
- badge 支持 evidence states。
- `@media print`：白底、隐藏不必要装饰、避免标题和表格行被生硬截断。

推荐 CSS token：

```css
:root {
  --canvas: #eef3f8;
  --paper: #ffffff;
  --text: #24384e;
  --muted: #5f7185;
  --border: #d5e0eb;
  --accent: #1e5ab6;
  --hero-start: #edf5ff;
  --hero-end: #e6f3f4;
  --hero-text: #15375f;
  --hero-muted: #3d5e7d;
  --ok: #047857;
  --warn: #b45309;
  --risk: #b91c1c;
  --code-bg: #f3f4f6;
}
```

## Minimal HTML Skeleton

```html
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title><!-- title --></title>
  <style>
    :root {
      color-scheme: light;
      --canvas: #eef3f8;
      --paper: #ffffff;
      --text: #24384e;
      --muted: #5f7185;
      --border: #d5e0eb;
      --accent: #1e5ab6;
      --hero-start: #edf5ff;
      --hero-end: #e6f3f4;
      --hero-text: #15375f;
      --hero-muted: #3d5e7d;
      --code-bg: #f4f7fa;
      --risk: #b91c1c;
    }
    html { background: var(--canvas); }
    body { margin: 0; color: var(--text); font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif; line-height: 1.75; }
    .document-shell { box-sizing: border-box; max-width: 1320px; min-height: 100dvh; margin: 0 auto; padding: 32px 56px 88px; display: grid; grid-template-columns: minmax(200px, 240px) minmax(0, 820px); column-gap: 76px; align-items: start; background: var(--paper); }
    .document-header { grid-column: 1 / -1; margin: 0 0 52px; padding: 52px 56px 46px; color: var(--hero-text); background: linear-gradient(115deg, var(--hero-start), #f9fbff 62%, var(--hero-end)); border-bottom: 1px solid #cbdff4; border-left: 5px solid var(--accent); border-radius: 8px; }
    .document-header h1 { margin: 0 0 18px; color: var(--hero-text); font-size: clamp(2rem, 4vw, 3.2rem); letter-spacing: -0.035em; line-height: 1.18; overflow-wrap: anywhere; }
    .document-header .meta { margin: 0; padding-top: 16px; color: var(--hero-muted); border-top: 1px solid rgba(61, 94, 125, 0.2); font-size: 14px; overflow-wrap: anywhere; }
    .document-toc { grid-column: 1; position: sticky; top: 32px; align-self: start; color: var(--muted); font-size: 13px; line-height: 1.55; }
    .document-toc::before { content: "目录"; display: block; margin-bottom: 14px; padding-bottom: 10px; color: var(--hero-text); border-bottom: 2px solid var(--accent); font-size: 15px; font-weight: 700; }
    .document-toc ul { margin: 0; padding-left: 0; list-style: none; }
    .document-toc ul ul { margin: 5px 0 8px; padding-left: 14px; }
    .document-toc li { margin: 5px 0; }
    .document-toc a { color: #3a536e; text-decoration: none; }
    .document-toc a:hover { color: var(--accent); text-decoration: underline; text-decoration-thickness: 1px; text-underline-offset: 3px; }
    .document-content { grid-column: 2; min-width: 0; }
    .document-content > h1 { display: none; }
    h1, h2, h3 { color: var(--text); line-height: 1.35; }
    h2 { margin: 64px 0 22px; padding-bottom: 13px; border-bottom: 1px solid var(--border); color: #1c3f6b; font-size: 1.55rem; }
    h3 { margin: 34px 0 12px; color: #244f80; font-size: 1.12rem; }
    h4 { color: #315e8d; }
    p, li { max-width: 76ch; }
    a { color: var(--accent); text-decoration-thickness: 1px; text-underline-offset: 3px; }
    blockquote { margin: 24px 0; padding: 16px 20px; color: #36516c; background: #f3f7fb; border-left: 3px solid #75a7dd; border-radius: 0 8px 8px 0; }
    code, pre { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
    pre { padding: 16px 18px; background: var(--code-bg); border: 1px solid var(--border); border-left: 3px solid #8fb7e1; border-radius: 8px; overflow: auto; }
    :not(pre) > code { padding: 2px 5px; color: #244f80; background: #edf3f8; border-radius: 4px; }
    table { width: 100%; border-collapse: collapse; font-size: 0.94rem; }
    th, td { padding: 10px 12px; border-bottom: 1px solid var(--border); vertical-align: top; }
    th { color: #244f80; background: #eef5fc; border-top: 2px solid #8fb7e1; text-align: left; }
    hr { margin: 52px 0; border: 0; border-top: 1px solid var(--border); }
    .badge { display: inline-block; border: 1px solid var(--border); border-radius: 999px; padding: 2px 8px; font-size: 12px; }
    .callout { border-left: 3px solid var(--accent); background: #f3f7fb; padding: 12px 14px; margin: 16px 0; }
    .callout.risk { border-left-color: var(--risk); }
    @media (max-width: 1080px) {
      .document-shell { display: block; padding: 28px 32px 64px; }
      .document-header { margin-bottom: 38px; padding: 42px 40px 36px; }
      .document-toc { position: static; margin: 0 0 46px; padding: 0 0 24px; border-bottom: 1px solid var(--border); }
    }
    @media (max-width: 640px) {
      .document-shell { padding: 0 20px 48px; }
      .document-header { margin: 0 -20px 32px; padding: 36px 24px 30px; border-radius: 0; }
      .document-header h1 { font-size: clamp(1.72rem, 8vw, 2rem); word-break: break-all; }
      .document-header .meta { font-size: 0.9rem; word-break: break-word; }
      table { display: block; overflow-x: auto; }
    }
    @media print {
      html, body { background: #fff; }
      .document-shell { display: block; min-height: 0; margin: 0; padding: 0; max-width: none; }
      .document-header { margin: 0 0 24px; padding: 0 0 14px; background: #fff; border: 0; border-bottom: 1px solid var(--border); border-radius: 0; }
      .document-toc { position: static; margin: 0 0 24px; padding: 0; break-after: page; }
      h2, h3, h4, tr, pre, blockquote { break-inside: avoid; }
    }
  </style>
</head>
<body>
  <main class="document-shell">
    <header class="document-header">
      <h1><!-- title --></h1>
      <p class="meta">更新时间：<!-- date --></p>
    </header>
    <nav class="document-toc" aria-label="文档目录">
      <!-- toc -->
    </nav>
    <article class="document-content">
      <section>
        <h2>摘要</h2>
        <!-- summary -->
      </section>
    </article>
  </main>
</body>
</html>
```

## Guardrails

- 不使用远程 CDN、外部 CSS 或前端构建链，除非用户明确要求。
- 不为了样式牺牲证据分层和未确认项表达。
- 不把所有文档套进同一章节结构。
- 不生成只有视觉包装、缺少事实来源和验证边界的报告。
- 不在用户要求 Markdown/README/AGENTS/ADR 时强行改成 HTML。
