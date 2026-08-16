# UI/UX Capability Routing

## 目录

- [共同契约](#共同契约)
- [能力职责](#能力职责)
- [任务路由](#任务路由)
- [交接契约](#交接契约)
- [降级和冲突处理](#降级和冲突处理)

## 共同契约

- 把 `design-product-ui` 作为项目 UI/UX 决策与路由控制面，不建立第四套设计引擎。
- 把项目根目录 `DESIGN.md` 作为唯一人工设计事实源；外部能力只能提供候选、证据、实现或检查结果。
- 从当前宿主能力清单确认依赖，不扫描或猜测用户目录，不自动安装缺失能力。
- 每次只调用完成当前目标所需的能力；方向、视觉、实现和评审已经明确时跳过对应阶段。
- 保留外部结果的来源和状态：`candidate`、`selected`、`verified` 或 `rejected`，不要把推荐自动升级为项目决定。

## 能力职责

| 能力 | 使用条件 | 输入 | 期望输出 | 禁止事项 |
| --- | --- | --- | --- | --- |
| UI UX Pro Max | 新方向开放、缺少成熟设计系统，或明确需要 style、palette、typography、页面模式、图表或栈指导 | 产品类型、用户情境、平台、2–5 个核心关键词和一个主要约束 | 有来源的候选及适用风险 | 不直接决定方向；不默认 `--persist`；不以行业标签覆盖项目事实 |
| Product Design ideate | brief 已闭合但没有选定视觉目标，需要比较方向 | brief、真实内容、品牌资产、已有页面、设计 tokens 和目标尺寸 | 三个真正不同且可比较的视觉方向 | 未选择前不实施；不把只换颜色当不同方向 |
| Product Design image-to-code | 已有用户选定的 mockup、截图、Figma frame 或其他视觉目标 | 选定视觉目标、项目组件与实现边界 | 忠实、响应式、可运行实现 | 不从未选定方向猜测视觉目标 |
| Product Design audit | 用户要求评估页面或多步产品体验，并且能获得实际截图或运行页面 | 页面、流程、截图和用户目标 | 绑定视觉证据的 UX、设计和可访问性发现 | 不用源码推测代替实际页面证据 |
| Impeccable | 已有代码或可运行界面，需要设计改造和交付质量检查 | 现有 `DESIGN.md`、代码、运行界面和明确目标 | critique、audit、polish、harden、adapt 或 detector 结果 | 不默认 init/shape/重选方向；不覆盖已批准品牌和产品事实 |
| 宿主原生能力 | 所有实施和验证；或专项能力缺失 | 项目代码、命令、测试和运行环境 | 代码修改、测试、构建、浏览器/设备证据 | 不声称未实际运行的视觉或设备结果 |

Impeccable 的 `document` / `extract` 仅在需要从既有代码提取设计系统，或用户明确要求时使用。提取结果先与代码事实核对，再合并到根 `DESIGN.md`；不要建立平行规范。

## 任务路由

| 场景 | 路径 |
| --- | --- |
| 新产品或新视觉方向 | brief → UI UX Pro Max 候选（可用时）→ Direction Gate → Product Design ideate（可用时）→ 用户选择 → `DESIGN.md` → 实现 → 必要的 Impeccable 质量检查 |
| 成熟设计系统中的新页面 | 读取 `DESIGN.md` / tokens / 组件 → 跳过 UI UX Pro Max → 按现有方向形成页面方案 → 必要的 Product Design 视觉目标 → 实现 → Impeccable 窄检查 |
| 已有完整设计稿或截图 | 跳过候选检索和多方向探索 → Product Design image-to-code 或宿主原生实现 → fidelity / responsive 验证 → 必要的 Impeccable harden |
| 已实现页面的体验评审 | Product Design audit 获取截图证据 → 按用户影响排序；用户只要求评审时停止，不自动修复 |
| 已实现页面的代码级打磨 | 根据目标选择一个主要 Impeccable 命令：`critique`、`audit`、`polish`、`harden` 或 `adapt` → 宿主验证 |
| 彻底重设计既有页面 | 先审计并确认保留的产品事实 → UI UX Pro Max 候选（需要新视觉世界时）→ Product Design ideate → 用户选择 → 更新 `DESIGN.md` → 实现 → Impeccable 收尾 |
| 单个明确样式修正 | 跳过完整路由 → 宿主原生实现和局部视觉验证 |

## 交接契约

### 交给 UI UX Pro Max

提供产品类型、主要用户、任务语域、平台、现有品牌约束和需要查询的单一 domain。查询结果至少记录匹配理由、风险和与现有系统的冲突；一次无结果后缩窄查询重试，仍无结果则明确回退。

### 交给 Product Design

提供已闭合 brief、真实或结构真实内容、必须保留项、已有视觉证据、目标尺寸与平台。ideate 默认生成三个独立视觉选项，除非用户明确改变数量；结果返回后暂停生产实现，等待用户选择。选择结果才是 image-to-code 的视觉目标。

### 交给 Impeccable

提供已批准方向、目标页面、允许修改的范围和剩余风险。优先选择一个最贴近目标的命令；只有发现属于独立风险域时才追加第二个。要求保留产品事实、现有品牌和范围外行为。

### 回到 `design-product-ui`

只接收可追踪的候选、用户选择、视觉证据和验证结果。把稳定决定映射为语义 token、组件角色、平台规则和 decision log；临时截图坐标、工具缓存和未选择候选不进入 `DESIGN.md`。

## 降级和冲突处理

| 缺失或冲突 | 处理方式 |
| --- | --- |
| UI UX Pro Max 不可用 | 使用 `craft-principles.md` 从产品语义推导 2–3 个文字候选；Product Design 可用时仍可生成视觉方向，并标记未经过目录检索 |
| Product Design 不可用 | 使用宿主图片生成能力制作 mockup；仍不可用时输出 wireframe、状态和 token 方案，不声称已经视觉验证 |
| Impeccable 不可用 | 使用 `review-rubric.md` 与宿主原生审查、测试、构建和浏览器验证；标记未运行 detector |
| 外部建议与成熟设计系统冲突 | 成熟系统优先；只有用户明确选择重设计时才建立替代方向 |
| 多个工具生成设计文档 | 停止同步，比较代码事实和用户批准记录，只合并到根 `DESIGN.md`；其他文件标为派生或运行缓存 |
| Product Design 与 Impeccable 产生重复发现 | 合并为一条，以真实用户影响和最直接证据排序；不要按工具分别重复报告 |
