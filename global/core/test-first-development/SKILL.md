---
name: test-first-development
description: 适用于新功能、bugfix、行为变更、重构前保护和高风险逻辑修改；结合 superpower TDD 的 red-green-refactor 证据纪律，以及 Matt Pocock TDD 的行为测试、公有接口、vertical slice 和 mock 边界。用户要求 TDD、测试优先、先写复现、先加回归测试，或任务需要证明行为变化时使用。老系统没有合适测试缝时，必须先说明测试缝缺口和替代验证，不能假装完成 TDD。
---

# Test First Development

## Goal

用测试先定义目标行为，再用最小实现让测试通过。核心是证据：先看到正确失败，再看到正确通过。

这个 skill 融合两类规则：

- superpower TDD：先写失败测试、验证 RED、最小实现、验证 GREEN、再重构。
- Matt TDD：测试行为而不是实现；通过公有接口或真实调用路径验证；一次一个 vertical slice，不先批量写一堆测试。

## When To Use

- 新功能、bugfix、行为变更。
- 重构前需要保护现有行为。
- 生产问题修复后要补回归测试。
- 用户要求“先复现”“先写测试”“TDD”“red-green-refactor”。

不适用或需要先说明例外：

- 纯文档、纯配置、一次性脚本、探索性 throwaway prototype。
- 老系统没有测试框架、没有可运行环境、没有稳定测试缝。
- 用户明确要求只读分析或临时线上止血。

例外不是跳过验证。例外时必须输出：为什么不能 test-first、替代验证是什么、剩余风险是什么。

## Workflow

1. 定义行为：用用户语言描述“应该发生什么”，不要先写实现步骤。
2. 找测试缝：优先从公有接口、HTTP/API、CLI、service 方法、页面用户路径、现有测试 harness 入手。
3. 选一个 vertical slice：先覆盖一个最关键行为，不要一次写完所有测试。
4. RED：写一个最小失败测试或复现脚本。
5. 验证 RED：运行目标测试，确认失败原因正确：
   - 失败是因为目标行为缺失，而不是语法、环境、mock 配置错误。
   - 如果测试直接通过，说明它没有证明新行为；修正测试或换测试缝。
6. GREEN：写最小实现让当前测试通过。
7. 验证 GREEN：重新运行同一测试，再运行必要的邻近测试/构建。
8. 重复：下一个行为再进入 RED，不做 horizontal slicing。
9. REFACTOR：只有全绿后才清理重复、命名或结构；每一步重构后重新运行测试。
10. 收尾：报告 red/green 命令、结果、未覆盖路径和剩余风险。

## Test Quality Rules

- 测试行为，不测试实现细节。
- 优先通过公有接口、真实调用路径或用户可观察结果验证。
- 测试名称描述“什么行为成立”，不要描述“调用了哪个内部方法”。
- 避免断言内部调用次数、私有方法、内部对象形状。
- 一个测试只证明一个核心行为；测试名里出现多个“和/并且”时考虑拆分。
- 测试应该能经受内部重构；重命名内部函数不应导致行为测试失败。

## Mock Rules

- 只 mock 系统边界：第三方 API、时间、随机数、文件系统、必要时数据库或网络。
- 不 mock 自己控制的内部模块，除非没有其它可行测试缝，并且必须说明原因。
- 创建 mock 前先确认真实依赖的副作用和返回结构。
- 不断言 mock 自己存在；断言真实业务行为。
- mock 响应要贴近真实结构，不能只补眼前字段导致假信心。

## Legacy / Existing Code

老系统或已有代码常常不能完美 TDD。处理方式：

1. 不假装已经 TDD。
2. 如果 bug 已存在，先写复现/回归测试，让它在旧行为下失败。
3. 如果是重构，先写 characterization test 固定现有行为；它可以先通过，但要说明它是保护网，不是 RED。
4. 如果没有测试缝，先找更外层验证入口：HTTP、CLI、日志 replay、最小 harness、人工步骤。
5. 如果仍无法自动化，输出替代验证和风险，再继续最小改动。

## Stop Conditions

暂停并说明，不要硬写测试：

- 需要大规模重构才能写测试。
- mock 比被测逻辑更复杂。
- 测试只能验证实现细节。
- 环境无法运行，且缺少替代 harness。
- 用户目标或行为边界未确认。

这时应转入 `requirements-clarification` 或 `codegraph-assisted-navigation`，先收敛边界和测试缝。

## Output Pattern

```markdown
## 行为定义
- ...

## 测试缝
- 选择：
- 原因：
- 替代方案：

## RED
- 测试/脚本：
- 命令：
- 失败结果：

## GREEN
- 最小实现：
- 命令：
- 通过结果：

## 未覆盖与风险
- ...
```

## Coordination

- 需求或行为不清楚：先用 `requirements-clarification`。
- 老系统局部修改：同时用 `safe-editing` 控制范围。
- 生产事故：先用 `production-incident-hotfix` 控制损失，再补回归测试。
- 任何完成声明：最后用 `task-report`，只写实际运行过的验证。
