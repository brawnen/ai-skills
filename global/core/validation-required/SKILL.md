---
name: validation-required
description: 适用于任何代码、配置、脚本或 SQL 改动；要求在结束前进行验证，不能仅凭静态阅读就宣称完成。
---

## Use when
- 做了任何代码修改
- 做了配置调整
- 修改了脚本、SQL、接口实现、前端逻辑或构建行为
- 任务结果需要可确认的完成依据

## Do
1. 优先运行与当前改动最相关的测试、构建或检查命令
2. 如果没有自动化测试，提供最小人工验证步骤
3. 如果环境限制导致无法验证，明确说明受阻原因
4. 区分“已验证部分”和“未验证部分”
5. 输出中只写实际执行过的验证，不写假设性验证

## Rules
- 未验证前不要说“已修复”或“已完成”
- 不要把“代码看起来没问题”等同于“验证通过”
- 不要夸大验证范围
- 验证失败时必须明确失败点
- 验证不完整时必须说明剩余风险

## Validation
- 至少给出一项实际验证动作
- 如果无法运行验证，必须写出原因
- 明确列出 what remains unverified

## Output
- Validation run
- Result
- What remains unverified
- Blocking issues if any
- Confidence level
