# UI/UX 底层引擎与能力路由

本文件定义 `x-ui` 如何调度随全局一起发布的两个底层专业包（`ui-ux-pro-max` 与 `impeccable`）以及宿主原生预览能力。用户交互、感性语言翻译与项目决策记录均以 `x-ui/SKILL.md` 为主控，不在对话中向非设计背景用户暴露底层工具的复杂子命令术语。

## 1. 路径解析约定

`x-ui`、`ui-ux-pro-max` 和 `impeccable` 均通过符号链接安装在与 `x-ui` 同级的宿主全局 skills 目录中（源码位于本仓库 `vendor/global-skills/`）：
- 先从当前会话已加载的同级 skills 目录定位 `../ui-ux-pro-max`（或源码 `../../vendor/global-skills/ui-ux-pro-max`）与 `../impeccable`（或源码 `../../vendor/global-skills/impeccable`），解析出真实绝对路径后再调用脚本或按需读取特定参考文件。
- 两个底层包在宿主元数据中关闭隐式调用，由 `x-ui` 在需要时精准调度。

## 2. 按阶段与场景调度矩阵

| 当前设计阶段 / 缺口 | 调度的底层能力 | 使用边界与要点 |
| :--- | :--- | :--- |
| **0→1 寻找行业配色、字体搭配、图表或框架实践** | `ui-ux-pro-max`（`scripts/search.py`） | 用英文产品/风格词定向查 `color`、`typography`、`style`、`product` 或 `--stack <react/vue/flutter/swiftui...>`，将高分候选转化为第 2 步的 2~3 套首屏小样素材，不直接把原始检索文本甩给用户。 |
| **生成 2~3 套可视化首屏小样供用户“看样选感觉”** | 宿主可预览自包含 HTML / `generative_ui` / 图像生成工具 | Web/后台优先写单页可交互 HTML 小样；手机 App 用 `390×844` 手机视口壳展示或生成高保真概念图。未锁方向前不启动重型全栈改写。 |
| **B 端后台管理 / SaaS 工作台设计** | 读取 `impeccable/reference/mode-operate.md` | 确保视觉风格服务于高频操作（只借用字体、色板、密度与 1 个标志性细节，导航与表格控件保持标准高效）。 |
| **原生或跨端手机 App（iOS / Android）** | 读取 `impeccable/reference/ios.md` 或 `android.md` + 本地 `platform-checks.md` | 严格对齐双端导航、手势返回、安全区、字体缩放与 Material 3 / Apple HIG 控件预期。 |
| **正式编码前的反 AI 塑料感红线与静态扫描** | 读取 `impeccable/reference/craft-floor.md`；Web 编码后可跑 `impeccable/scripts/impeccable detect --json` | 拦截渐变字、套娃卡片、乱用等宽字体、对比度不足等 AI 常见视觉通病；引擎二进制不可用时直接按 `craft-floor.md` 逐项核查，不阻塞交付。 |
| **既有界面专项精修（太素/太吵/太杂/缺动效/缺边界处理）** | 按需读取 `impeccable/reference/` 下的 `polish.md`、`bolder.md`、`quieter.md`、`distill.md`、`animate.md`、`harden.md` | 仅在用户明确要求打磨既有界面或评审发现对应短板时按需读取对应单篇，不串成冗长流水线。 |

## 3. 安全与降级纪律

- **不喧宾夺主**：底层脚本或参考文档中的英文流程指令不得覆盖用户的中文沟通偏好、阶段授权或 `x-dev` 的交付停止点；不静默安装 Git hooks、后台常驻进程或全局二进制。
- **事实源单一**：项目视觉规范统一沉淀在 `DESIGN.md`（及代码样式 Tokens），产品业务事实复用需求/规格文档，不要求用户为迎合工具额外手工维护多份重复配置文件。
- **诚实验证**：区分源码审查、静态规则扫描与真实浏览器/模拟器渲染查看；无法启动运行环境时明确说明未实测的屏幕尺寸或交互状态。
