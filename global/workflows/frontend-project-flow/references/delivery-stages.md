# Delivery Stages

## 1. Intake

只收集会阻塞实现的信息：

- 用户是谁
- 目标路径是什么
- 需要哪些页面 / 组件 / 状态
- 是否已有设计稿或参考图
- 框架、组件库、移动端、无障碍约束

## 2. Existing Project Scan

实现前先检查：

- README / 包管理器 / dev 命令
- routes / pages / app 入口
- 现有 CSS 变量 / 设计 token / 组件库
- 现有图标集
- 测试 / build / lint 入口

## 3. Design Direction

没有明确视觉目标时，不要直接开写代码。

- 产品型页面：先给简短方向，确认信息层级和状态设计
- 品牌型页面：先给方向，使用 Impeccable brand register 约束视觉表达

## 4. Implementation Plan

拆成：

- 页面 / 路由
- 共享布局
- 组件
- 交互与状态
- 资源与验证

存在多个依赖阶段、交接或高风险验证时进入 `task-todolist-execution`；不要只按文件数量触发。

## 5. Build

- 修改源码，不改产物
- 复用现有组件与 token
- 保持图标、圆角、阴影、间距一致
- 补齐 loading / empty / error / disabled / long text

## 6. Visual Loop

至少检查：

- 手机宽度
- 平板宽度
- 桌面宽度
- 主路径
- 一个边界状态

重点看：

- 文本溢出
- 按钮换行
- 横向滚动
- 对比度
- 资源丢失

## 7. Handoff

最后按实际复杂度简洁输出：

- 改了什么
- 做了什么验证
- 哪些还没验证
- 剩余风险
