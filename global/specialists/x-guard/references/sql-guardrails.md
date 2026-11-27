# 服务端关系型数据库 SQL 写门禁

## 1. 适用条件与边界

- **生效前提**：仅当仓库包含关系型数据库持久化代码（如 `migrations` / `sqlc` / MyBatis Mapper / ORM raw SQL / SQL 模板文件）时读取并评估接入。
- **不触发**：纯前端、静态站或不含关系型数据库的仓库不触发，不引入无关检查。
- **职责边界**：本协议负责静态代码与 SQL 写语句合规门禁；真实 DDL、索引变更、回填与生产写入的锁、兼容及回滚风险仍由 `x-db` 负责，业务正确性仍由运行态验证负责。

## 2. 三条标准 SQL 写门禁

### 规则 1：默认禁物理 `DELETE` + 防绕过
- 默认禁止任何物理 `DELETE`（业务删除优先软删除、状态流转或不可变流水）。
- 仅允许经人工审批登记的两类例外：**可重建派生投影表**或**受控当前关联表**；即使放行，`DELETE` 仍必须带命中索引前导列的 `WHERE` 条件。
- **防绕过**：禁止业务代码绕过项目统一 SQL 持久化层（如 `sqlc`、Mapper、Repository/ORM 封装）直接拼接或手写裸 `DELETE` / `UPDATE` 字符串。

### 规则 2：`UPDATE` 必带 `WHERE` 且走索引
- 所有顶层 `UPDATE` 及数据修改 CTE（如 `WITH ... AS (UPDATE ...)`）中的 `UPDATE` 必须包含 `WHERE`，且顶层 `AND` 过滤条件必须命中迁移/Schema 中定义的 `PRIMARY KEY`、`UNIQUE` 或 `INDEX` 的前导列。
- **精准放行**：
  - 受唯一约束保护的幂等 upsert：`INSERT ... ON CONFLICT DO UPDATE`、`INSERT ... ON DUPLICATE KEY UPDATE`。
  - 仅加行锁的读语句：`SELECT ... FOR UPDATE`。
- **拦截典型索引失效写法**：
  - 函数或表达式包裹索引列（如 `LOWER(col) = ...`、`DATE(col) = ...`、`col + 1 = ...`）。
  - 前置通配模糊匹配（如 `LIKE '%abc'`、`ILIKE '%abc'`）。
  - 顶层 `OR` 导致过滤条件无法稳定锚定索引前导列。
- **复杂索引复核**：遇到部分索引（partial index）、表达式索引或 `UPDATE ... FROM` 多表更新等静态分析边界场景时，静态规则注明局限，并在隔离测试库结合 `EXPLAIN`（如 PostgreSQL 会话内关闭 `enable_seqscan`）核对实际执行计划。

### 规则 3：受控人工审批白名单与禁 Agent 自批
- 未命中索引前导列的 `UPDATE` 与例外 `DELETE` 默认阻断。
- 确有合理业务原因必须放行时，仅允许由**人工审核**后登记到受控白名单文件（如 `sql-guardrails-allowlist.json`），每条必填字段：

| 字段 | 含义 |
| --- | --- |
| `file` | 语句所在相对文件路径 |
| `query` | 查询名称、Mapper ID 或语句定位标识 |
| `rule` | 所豁免的规则 ID |
| `sql_sha256` | 规范化 SQL（去除无关空白/注释后）的 SHA-256 哈希；SQL 一旦改动，原审批自动失效 |
| `reason` | 明确的业务理由与影响范围 |
| `approved_by` | 人工审批人标识 |
| `approved_at` | 审批时间（ISO 8601） |

- **硬性禁令**：严禁 Agent 自行新增、修改白名单条目或刷新 `sql_sha256`。触发未登记违规或哈希漂移时，必须保持阻断并报告具体文件、查询、当前/期望哈希差异与改写建议，交由人工决定修改 SQL、补建索引还是人工更新白名单。

## 3. 常见技术栈落地映射

优先沿用项目原生测试与解析工具，所有落地均须接入项目统一检查入口，并严格满足 [规则编码与四件套协议](rule-encoding.md)（规则本体 + 覆盖允许/阻断/失效写法的正反单测 + 面向 Agent 的三段式报错 + 落地后精简文档中重复的散文条款）：

| 技术栈 | Schema / 索引事实源 | 写 SQL 扫描对象 | 防绕过检查方式 |
| --- | --- | --- | --- |
| **Go + `sqlc`**（参考 `mitto-boss` 已验证实现） | `migrations/*.sql`（解析 `CREATE TABLE` 主键/唯一约束与 `CREATE INDEX`） | `sqlc` 查询目录 `*.sql` | `internal/archtest` 用 `go/ast` 扫描业务包，禁止绕过 `sqlc` 生成层手写裸 `DELETE`/`UPDATE` |
| **Java（MyBatis / JPA）** | Flyway / Liquibase 迁移或 DDL Schema | MyBatis XML Mapper、`@Update`/`@Delete` 注解及 `@Query` native SQL | ArchUnit / 自定义静态测试拦截业务层绕过 Mapper/Repository 拼接裸写 SQL |
| **Python（SQLAlchemy / Alembic）** | Alembic 迁移或 ORM Model 索引元数据 | 项目 `.sql` 文件与 `text()` / raw cursor 执行入口 | AST 检查脚本禁止业务模块绕过持久化层构造裸 `DELETE`/`UPDATE` |
| **Node / TS（Prisma / Drizzle / Knex）** | `schema.prisma` / Drizzle Schema / 迁移文件 | `.sql` 文件、`$executeRaw*`、`sql.raw` 及 Knex raw 调用 | ESLint 自定义规则或 AST 脚本拦截业务代码裸写 `DELETE`/`UPDATE` |

## 4. 三类项目保护策略

- **0→1 新项目**：在引入首个数据库迁移与查询层时即同步接入基础 SQL 写门禁，零历史债起步。
- **接手存量项目**：先只读扫描全部存量违规并输出分类清单（区分可补索引、应改写与需人工特批），交人工逐条确认后由人工登记进受控白名单；绝不直接刷红老代码，也严禁 Agent 自动批量写入白名单。
- **开源项目**：严格遵守上游贡献规范与既有检查配置，绝不向仓库混入私货白名单或未获上游认可的 SQL 检查配置；个人辅助扫描脚本仅放本地忽略路径（如 `.git/info/exclude`）。
