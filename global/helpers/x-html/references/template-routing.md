# Formal HTML Template Routing

模板只负责稳定的阅读结构和视觉系统；章节内容仍以当前文档类型、项目事实和用户要求为准。

所有生产模板都必须保留纸张层的 `data-brand="brawnen"` 作品标记。标记通过 CSS
伪元素呈现，不属于正文内容；不得遮挡阅读、进入复制文本或拦截交互。屏幕和打印均应保留，
但只能作为正常阅读时近乎不可察的背景签名，不能承担来源、版权或证据状态等语义。

## 1. Decision Brief / Executive Sunrise（商业与立项决策）

资产：`assets/templates/decision-brief.html`

适用于需要读者快速形成商业或投资决定的正式文档：

- 可行性研究、商业模式分析和投资评审（如 `x-biz` 交付）；
- 市场分析、竞品格局和阶段门决策；
- 面向管理层或合作方的业务决策稿。

不适用于代码架构审查、技术规格、操作密集的 Runbook 或时间线技术复盘（此类使用下方的 `engineering-review`）。

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

- `decision-primary` 只用于最重要的综合判断；`decision-opportunity` 只用于机会或正向窗口，不表示已经实现。
- 不足两个摘要时删除整个摘要区域；不要为了凑卡片重复正文。

---

## 2. Engineering Review / Blueprint Slate（架构、规格、Runbook 与复盘）

资产：`assets/templates/engineering-review.html`

适用于软件研发全生命周期的技术与运维正式文档：

- 架构摩擦扫描报告（`x-arch`）与重构候选评审；
- 技术设计方案、实施规格（`x-spec`）与跨服务/数据库变更评估（`x-db`）；
- 排障手册、生产发布可执行 Runbook（`release.md`）；
- 线上故障或研发会话证据复盘报告（`x-debug` / `x-retro`）。

默认组合：

```text
profile: engineering-report
layout: engineering-review
theme: blueprint-slate
density: technical
```

### 占位符与专属结构组件

| 占位符 | 内容 |
| --- | --- |
| `{{DOCUMENT_TYPE}}` | 工程文档短标签，如 `ARCHITECTURE SCAN`、`TECHNICAL SPEC`、`RELEASE RUNBOOK`、`POSTMORTEM` |
| `{{TITLE}}` | 正式标题 |
| `{{SUBTITLE}}` | 一句话技术范围、目标系统或评估边界 |
| `{{UPDATED_AT}}` | 明确日期 |
| `{{METADATA}}` | 仓库、目标分支/Commit SHA、环境或责任人；用 `<span>` 分隔 |
| `{{SUMMARY_STRIP}}` | 2–4 个工程概览指标条（范围、基线版本、最高风险/推荐强度、门禁/验证状态） |
| `{{TOC}}` | 与正文锚点一致的列表 |
| `{{CONTENT}}` | 已确认的正文 HTML |

概览条与正文专属组件用法：

```html
<!-- 1. 顶部工程概览条 SUMMARY_STRIP -->
<div class="summary-item summary-primary">
  <strong>Top Recommendation</strong>
  <span>收敛订单结算浅接口，消除 4 处重复补偿</span>
</div>
<div class="summary-item summary-ok">
  <strong>验证与门禁</strong>
  <span>7/7 隔离集成通过 · Commit cf3be51</span>
</div>
<div class="summary-item summary-blocker">
  <strong>高危阻塞项</strong>
  <span>生产 DDL 尚未配置 lock_timeout</span>
</div>

<!-- 2. Before / After 架构或方案双栏对比 -->
<div class="compare-grid">
  <section class="compare-card compare-before">
    <h4>现状（浅接口与散落校验）</h4>
    <p>调用方需自行按顺序传入 5 个状态参数并处理幂等冲突。</p>
  </section>
  <section class="compare-card compare-after">
    <h4>深化后（边界集中收敛）</h4>
    <p>单一结算入口隐藏锁与幂等，对外暴露判别联合结果。</p>
  </section>
</div>

<!-- 3. 长日志 / SQL 计划折叠证据块 -->
<details class="evidence-fold">
  <summary>查看隔离变异复现输出与 EXPLAIN 计划</summary>
  <pre><code>Seq Scan on orders ...</code></pre>
</details>
```

优先级徽章可使用 `.badge.priority-blocker`（或 `priority-strong`）、`.badge.priority-important`（或 `priority-worth`）、`.badge.priority-optional`（或 `priority-speculative`）；流程图直接使用 `flow-diagrams.md` 定义的 `<figure class="flow-figure"><ol class="process-flow"><li class="process-step">...` 结构，模板已内置桌面横向箭头与窄屏纵向降级样式。

---

## 3. 通用回退外壳

资产：`assets/formal-document-shell.html`

仅用于连续长文白皮书、培训讲义等既非商业决策稿也非工程评审/操作单的文档。

## 共同生成要求

1. 复制所选资产后替换全部占位符，不在交付稿保留 `{{...}}`。
2. 将表格包在带有可读 `aria-label` 和 `tabindex="0"` 的 `.table-wrap` 中。
3. 外部链接按需加入 `target="_blank" rel="noopener noreferrer"`；不要引入远程 CSS、字体或脚本。
4. 证据状态必须同时保留精确文字和语义 class：`已验证`/`已确认` 用 `badge-confirmed`，`用户确认` 用 `badge-user`，`推断` 用 `badge-inference`，`未验证` 用 `badge-unverified`，`待决策`/`待确认` 用 `badge-pending`。
5. 删除不适用模块，不填充空章节；内容事实层级不得由模板改变。
6. 实际验证桌面、窄屏和打印；亮色不能承担唯一语义。
7. 保留 `data-brand="brawnen"` 及对应水印样式；除非仓库所有者明确要求，不得移除或替换。
