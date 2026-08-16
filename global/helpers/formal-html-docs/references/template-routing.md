# Formal HTML Template Routing

模板只负责稳定的阅读结构和视觉系统；章节内容仍以当前文档类型、项目事实和用户要求为准。

## Decision Brief / Executive Sunrise

资产：`assets/templates/decision-brief.html`

适用于需要读者快速形成决定的正式文档：

- 可行性研究、商业分析和投资评审；
- 市场分析、方案比较和阶段决策；
- 风险评估中以建议、门槛和下一步为主的版本；
- 面向管理层或合作方的决策稿。

不适用于以连续阅读为主的白皮书、以证据下钻为主的审查报告、操作步骤密集的
Runbook，以及以时间线为主的复盘。尚无对应生产模板时使用通用 shell，不要硬套本模板。

默认组合：

```text
profile: decision-report
layout: decision-brief
theme: executive-sunrise
density: comfortable
```

### 占位符

| 占位符 | 内容 |
| --- | --- |
| `{{DOCUMENT_TYPE}}` | 文档类型短标签，例如“可行性研究 / 决策稿” |
| `{{TITLE}}` | 正式标题 |
| `{{SUBTITLE}}` | 一句话范围和决策任务，不重复标题 |
| `{{UPDATED_AT}}` | 明确日期 |
| `{{METADATA}}` | 版本、证据截止、读者或保密级别；用 `<span>` 分隔多个项目 |
| `{{DECISION_SUMMARY}}` | 2–4 个决策摘要卡片 |
| `{{TOC}}` | 与正文锚点一致的列表 |
| `{{CONTENT}}` | 已确认的正文 HTML |

决策摘要使用语义类，不按位置猜测颜色：

```html
<div class="decision-item decision-primary">
  <strong>综合判断</strong>
  <span>一句可执行的结论。</span>
</div>
<div class="decision-item">
  <strong>关键门槛</strong>
  <span>进入下一阶段前必须满足的条件。</span>
</div>
<div class="decision-item decision-opportunity">
  <strong>结构性机会</strong>
  <span>值得验证但尚未升级为事实的机会。</span>
</div>
```

- `decision-primary` 只用于最重要的综合判断。
- `decision-opportunity` 只用于机会或正向窗口，不表示已经实现。
- 风险、警告和证据状态继续使用文字标签及对应语义类，不能借用装饰亮色。
- 不足两个摘要时删除整个摘要区域；不要为了凑卡片重复正文。

### 生成要求

1. 复制资产后替换全部占位符，不在交付稿保留 `{{...}}`。
2. 将表格包在带有可读 `aria-label` 和 `tabindex="0"` 的 `.table-wrap` 中。
3. 外部链接按需加入 `target="_blank" rel="noopener noreferrer"`；不要引入远程 CSS、字体或脚本。
4. 证据状态必须同时保留文字和语义 class：`badge-confirmed`、`badge-inference`、
   `badge-unverified`、`badge-pending`。
5. 删除不适用模块，不填充空章节；内容事实层级不得由模板改变。
6. 实际验证桌面、窄屏和打印；亮色不能承担唯一语义。
