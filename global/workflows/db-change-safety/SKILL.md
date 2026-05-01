---
name: db-change-safety
description: 适用于数据库相关改动，包括 DDL、索引、SQL、迁移、回填和数据修复；目标是优先识别风险，再决定修改方案。
---

## Use when
- 任务涉及 MySQL、PL/SQL、SQLite 或其他数据库
- 需要修改表结构、字段、索引、约束
- 需要编写或修改 migration
- 需要写数据修复脚本、回填脚本或批处理 SQL
- 需要优化 SQL 或分析潜在数据库风险

## Do
1. 先判断本次改动属于哪一类：schema change、index change、query change、data migration、data fix
2. 识别影响范围：读路径、写路径、事务、锁、批量数据、兼容性
3. 先给出风险判断，再给出建议方案
4. 如涉及数据修改，考虑幂等性、回滚性、执行批次和失败恢复
5. 如涉及 schema 变更，考虑兼容窗口和旧代码 / 新代码共存问题
6. 输出中单独列出风险与验证建议

## Rules
- 不要默认数据库变更是低风险操作
- 不要把 schema 变更和数据回填混成一个模糊动作
- 不要在未说明风险时直接给“可上线”结论
- 不要忽略锁表、长事务、全表扫描或索引失效风险，未使用索引的 SQL语句必须提前告知
- 不要把“语法正确”等同于“线上安全”
- 未确认幂等性前，不要声称脚本可重复执行
- 未确认回滚思路前，不要默认可轻易回退
- 不能在项目代码中出现 delete 删除数据的SQL语句
- 不能在项目代码中出现没有 where 子语句的 update 操作
## Validation
- 明确改动类型
- 明确影响范围
- 明确主要风险
- 给出验证建议，例如 EXPLAIN、测试库验证、样本数据验证、灰度执行、分批执行

## Output
- Change type
- Affected tables / queries / code paths
- Main risks
- Rollback or fallback considerations
- Suggested validation steps
- Confidence / uncertainty
