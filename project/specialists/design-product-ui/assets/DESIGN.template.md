# `<产品或项目名称>` Design System

> Status: `<proposed / approved / delegated / evolving>`
> Owners: `<产品 / 设计 / 前端 / 客户端负责人>`
> Last reviewed: `<YYYY-MM-DD>`

本文档记录跨页面、跨状态和跨平台需要持续遵循的 UI/UX 决策。页面级临时值不要写入；未确认内容标记为 `proposed`。
外部工具输出只作为候选或证据。`approved` 标明既有项目批准或用户选择的来源；`delegated` 表示用户授权范围内的代理决策，不能写成用户已确认。实现验证另行记录。

## 1. Context Sources

- 产品事实来源：`<现有 PRD / PRODUCT.md / 用户决定链接，不复制维护>`
- 视觉规范适用范围：`<页面、平台、主题>`
- 代码事实来源：`<tokens / 主题 / 公共组件路径>`
- 局部 brief 与派生文件：`<路径、职责与来源；没有则删除>`

## 2. Experience Principles

写 3–5 条可执行原则，避免“简洁、现代、高级”等无行为含义的词。

1. `<例如：始终让下一步主要动作在当前任务状态中可见>`
2. `<例如：错误必须说明恢复路径，不显示无行动的失败页>`
3. `<请填写>`

## 3. Visual Direction and Signature

- Design thesis：`<希望形成的感受 + 具体实现方法>`
- Product grounding：`<方向与产品世界、用户或任务的联系>`
- Signature：`<唯一或主要的可复用辨识特征>`
- Restraint：`<哪些区域保持安静>`
- Avoid：`<与本项目明确冲突的视觉或交互做法及原因>`

## 4. Color Roles

| Role | Token | Value / implementation | Usage |
| --- | --- | --- | --- |
| Canvas | `<color.canvas>` | `<请填写>` | `<页面背景>` |
| Surface | `<color.surface>` | `<请填写>` | `<主要容器>` |
| Elevated | `<color.surface.elevated>` | `<请填写>` | `<浮层/层级>` |
| Text | `<color.text.primary>` | `<请填写>` | `<正文>` |
| Muted | `<color.text.secondary>` | `<请填写>` | `<次要信息>` |
| Accent | `<color.action.primary>` | `<请填写>` | `<主动作>` |
| Focus | `<color.focus>` | `<请填写>` | `<键盘焦点>` |
| Semantic | `<success/warning/danger>` | `<请填写>` | `<状态>` |

- 深色 / 高对比策略：`<请填写；不支持则写明>`
- 对比度标准与验证工具：`<请填写>`

## 5. Typography

| Role | Token | Font / fallback | Size / weight / line height | Notes |
| --- | --- | --- | --- | --- |
| Display | `<type.display>` | `<请填写>` | `<请填写>` | `<低频品牌表达>` |
| Heading | `<type.heading>` | `<请填写>` | `<请填写>` | `<层级>` |
| Body | `<type.body>` | `<请填写>` | `<请填写>` | `<正文与行长>` |
| UI | `<type.ui>` | `<请填写>` | `<请填写>` | `<按钮/标签>` |
| Data / code | `<type.data>` | `<请填写>` | `<请填写>` | `<数字/代码；无则删除>` |

- 字体加载、授权和离线策略：`<请填写>`
- 字体缩放与本地化要求：`<请填写>`

## 6. Space, Layout and Responsive Behavior

- 间距 scale / token：`<请填写>`
- 内容最大宽度：`<请填写>`
- 栅格或主要对齐规则：`<请填写>`
- 密度策略：`<marketing / product / data / embedded>`
- 最小支持尺寸和断点 / 窗口类别：`<请填写>`
- 小屏重排顺序：`<请填写>`
- 大屏扩展方式：`<请填写>`
- safe area、键盘、窗口或远距离观看约束：`<请填写>`

## 7. Components and Patterns

| Product role | Existing component / path | Variants and states | Platform mapping |
| --- | --- | --- | --- |
| Primary action | `<请填写>` | `<default/pressed/loading/disabled>` | `<请填写>` |
| Secondary action | `<请填写>` | `<请填写>` | `<请填写>` |
| Form field | `<请填写>` | `<focus/error/disabled>` | `<请填写>` |
| Navigation | `<请填写>` | `<selected/collapsed>` | `<请填写>` |
| Feedback | `<请填写>` | `<loading/empty/error/success>` | `<请填写>` |

- 新增公共组件的门槛：`<请填写>`
- 图标体系与来源：`<请填写>`
- 圆角、边框、阴影和层级规则：`<请填写>`

## 8. Interaction, States and Motion

- 主要导航与返回语义：`<请填写>`
- 保存、取消、撤销和关闭保护：`<请填写>`
- loading / empty / error / disabled / permission / offline / success：`<组件或模式映射>`
- 动效目的与 duration/easing tokens：`<请填写>`
- reduced-motion 行为：`<请填写>`
- 危险动作保护：`<请填写>`

## 9. Content, Accessibility and Localization

- CTA 和控件命名规则：`<请填写>`
- 错误与恢复文案规则：`<请填写>`
- 支持语言、RTL、日期/数字/单位：`<请填写>`
- 键盘、焦点、屏幕阅读器和触摸目标标准：`<请填写>`
- 字体缩放、颜色非唯一信号和动画降级：`<请填写>`
- 需要人工或专业领域审核的内容：`<请填写>`

## 10. Implementation Mapping

- Design tokens：`<文件 / 包 / 生成流程>`
- Theme：`<文件 / 入口>`
- Shared components：`<目录 / 包>`
- Icons / fonts / assets：`<目录 / 管理方式>`
- Component preview / story / gallery：`<命令或位置>`
- Visual regression：`<命令或位置>`
- Device / browser verification：`<命令或工具>`

## 11. Do and Do Not

### Do

- `<请填写项目特有的正向规则>`

### Do not

- `<请填写项目特有禁区及原因；不要复制通用审美黑名单>`

## 12. Decision Log

| Date | Status | Decision | Reason | Evidence / source | Affected surfaces |
| --- | --- | --- | --- | --- | --- |
| `<YYYY-MM-DD>` | `<proposed/approved/delegated/superseded>` | `<请填写>` | `<请填写>` | `<既有批准 / 用户选择 / 授权代理决策；另列代码或截图验证>` | `<请填写>` |
