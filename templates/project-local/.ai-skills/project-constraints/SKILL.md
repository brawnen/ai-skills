---
name: project-constraints
description: 项目级约束模板，用于声明当前仓库的目录边界、兼容性要求和不可轻动区域。请在真实项目中替换占位内容。
---

## 项目上下文
- 项目名称：`<请填写>`
- 主要技术栈：`<请填写>`
- 默认工作模式：`<保守修复 / 常规开发 / 严格兼容>`

## Do
1. 先确认需求涉及的目录与模块是否在允许范围内
2. 涉及 root config、shared config、基础设施脚本时先做额外确认
3. 对必须保持兼容的接口、数据结构、事件格式做显式检查

## Rules
- 不要修改这些目录：`<请填写>`
- 这些目录只能局部修改：`<请填写>`
- 这些配置文件默认不要改：`<请填写>`
- 这些接口行为必须保持兼容：`<请填写>`

## Validation
- 检查改动目录是否越界
- 检查兼容性约束是否被破坏
- 检查是否误改 root / shared 配置

## Output
- Touched paths
- Constraint checks
- Compatibility considerations
- Unresolved questions
