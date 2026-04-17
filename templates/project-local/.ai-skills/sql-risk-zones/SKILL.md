---
name: sql-risk-zones
description: 项目级数据库风险模板，用于记录高风险表、慢查询历史与禁止直接在生产执行的 SQL 类型。请在真实项目中替换占位内容。
---

## 数据库上下文
- 数据库类型：`<MySQL / PL-SQL / SQLite / 其他>`
- 关键业务表：`<请填写>`
- 历史高风险查询：`<请填写>`

## Risk Zones
- 高风险表：`<请填写>`
- 高风险索引 / 关联路径：`<请填写>`
- 慢查询历史问题：`<请填写>`
- 禁止在生产直接执行的 SQL：`<请填写>`

## Do
1. 数据库相关改动前先判断是否触达高风险区域
2. 对可能影响锁、事务、全表扫描的语句先做风险说明
3. 涉及批量数据操作时明确批次、幂等性与回滚路径

## Validation
- 建议的 EXPLAIN 检查：`<请填写>`
- 测试库验证步骤：`<请填写>`
- 样本数据验证方法：`<请填写>`

## Output
- Affected tables / SQL
- Main risks
- Suggested validation
- Rollback / fallback notes
