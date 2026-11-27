# 在线 DDL 与生产迁移高频事故清单

编写或评审进入 staging / 生产的 migration、索引、约束及数据回填脚本时读取。

## 1. 锁等待雪崩（最常见线上中断原因）

- **禁止裸跑无超时 `ALTER TABLE`**：即使 `ADD COLUMN ... NULL` 只需毫秒级排他锁，一旦前方有长查询持有读锁，`ALTER TABLE` 进入锁等待队列会阻塞后续所有对该表的普通读写，瞬间打满应用连接池。
- **必备保护**：生产 DDL 会话必须设置短锁超时（如 PostgreSQL `SET LOCAL lock_timeout = '2s'`，MySQL `lock_wait_timeout = 2`），超时快速失败后退避重试，绝不死等。

## 2. 索引变更陷阱

- **PostgreSQL `CREATE / DROP INDEX CONCURRENTLY`**：
  - **严禁包在显式事务块中**（注意许多迁移工具默认单文件包裹 `BEGIN...COMMIT`，必须按工具机制关闭该文件事务包装）。
  - **失败残留核查**：`CONCURRENTLY` 中断或唯一键冲突会留下 `INVALID` 索引（不加速查询但持续拖慢写入并占空间）；重跑前必须先检查 `pg_index.indisvalid = false` 并用 `DROP INDEX CONCURRENTLY IF EXISTS` 清理。
- **MySQL / InnoDB 在线 DDL**：显式指定 `ALGORITHM=INSTANT` 或 `ALGORITHM=INPLACE, LOCK=NONE`（按实际大版本支持能力核实），防止不支持在线操作时静默退回 `COPY` 全表锁。

## 3. 表重写与约束校验拆分

- **新增非空列与默认值**：核实当前数据库引擎及版本对常量默认值是否为元数据操作；动态表达式默认值或跨类型改列（`ALTER COLUMN TYPE`）往往触发全表重写，大表必须改为「加可空列 → 分批回填 → 加非空约束」。
- **外键与检查约束**：PostgreSQL 大表避免直接 `ADD CONSTRAINT`，拆分为两步：`ADD CONSTRAINT ... NOT VALID`（仅短暂锁表，立即拦截新写入）→ 低峰期 `VALIDATE CONSTRAINT`（不阻塞正常读写）。

## 4. 数据回填与新旧代码共存窗口

- **三阶段兼容（Expand → Migrate → Contract）**：删列、改名、收紧非空前，必须确认所有运行实例已不再读写旧字段；禁止将破坏性 DDL 与依赖新结构的代码放在同一批次原子假设下混发。
- **主键/索引游标分批**：大表回填一律按有序主键/唯一索引范围游标推进（禁止 `OFFSET` 深翻页），批间带可控休眠或延迟阈值检查，支持中断后从断点幂等续跑。
