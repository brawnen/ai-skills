---
name: ui-ux-pro-max
description: 显式调用或由 design 定向选择的本地 UI/UX 数据检索工具，用于查询配色、字体、图表、交互或技术栈候选。普通页面实现、组件修复和已有设计稿落地使用宿主能力。
---

# UI UX Pro Max · 本地检索入口

这是本仓库维护的轻量适配入口。上游数据、脚本及许可证保持原样；完整原文保存在 [UPSTREAM-SKILL.md](UPSTREAM-SKILL.md)，仅在用户明确需要上游完整指导时读取，不作为默认流程加载。

## 按缺口查询

先复用项目已有设计约束；仅在需要外部候选或具体技术栈指导时查询。不要为了使用工具遍历所有领域，也不把检索结果当作用户批准的设计。

从本 skill 所在目录解析 `scripts/search.py` 的绝对路径；下列 `<skill-dir>` 是路径占位符。查询词优先使用数据库使用的英文关键词：

```bash
python3 <skill-dir>/scripts/search.py "accessible dashboard" --domain color --max-results 3
python3 <skill-dir>/scripts/search.py "form accessibility" --stack react --max-results 3
```

- 按当前问题选择一个 domain 或 stack；支持的参数和值以 `python3 <skill-dir>/scripts/search.py --help` 为准，不预读全部 CSV 或脚本实现。
- 使用默认精简输出；只有当前结果确实被截断且影响判断时才加 `--full`。结果不足时再改查询或补查相邻领域。
- 需要整体设计系统候选时才用 `--design-system`；当前快照的该模式不应用 `--stack`，技术栈指导需单独查询。
- 不默认使用 `--persist`。确需保存派生候选时明确 `--output-dir <project-root>`，保留现有项目规范的权威性，不覆盖既有决定。
- 无匹配时说明缺口并用宿主能力继续；不把空结果当作已有证据。

交付采用的候选、与项目约束的关系及必要出处即可，不附整套通用检查清单。实现和验证按当前任务需要进行，不由检索自动扩展成设计、审查和文档流水线。
