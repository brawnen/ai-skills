# Codex 执行文档：本地 AI Skills 体系搭建与落盘方案

## 0. 文档目标

这是一份给 Codex 直接执行的实施文档。目标不是安装尽可能多的 skills，而是搭建一套 **少而精、可维护、分层清晰** 的本地 skills 体系，服务于以下场景：

- 用户是全栈开发者，常用语言：TypeScript、Java、Python、Go
- 常用数据库：MySQL、PL/SQL、SQLite
- 常用 CLI：Codex、Claude Code、Gemini CLI
- 同时维护老产品与新产品
- 目标是获得一套科学、高性价比的 skills 方案

本方案采用：

- **全局 skills 与项目级 skills 分离**
- **中央目录作为单一事实源**
- **项目专属 rules 跟项目代码放在一起**
- **外部流行 skill 包（superpowers / gstack）只做 vendor，不直接混入主干**

---

## 1. 设计原则

### 1.1 总体原则

1. skills 不是越多越好，重点是边界清晰、命中准确、维护成本低。
2. 全局 skill 只放跨项目通用规则。
3. 项目 skill 必须尽量跟项目仓库放在一起，不集中塞到全局目录。
4. 外部 skill 包只做参考和 vendor，不直接替换主干。
5. 第一阶段只落地 5 个核心 skill。

### 1.2 全局与项目级的边界

#### 放全局的内容

仅放这些：

- 最小改动
- 改动后必须验证
- 输出汇报格式统一
- 数据库改动优先做风险分析
- 老系统默认保守修改

#### 放项目里的内容

只要规则依赖某个具体仓库，就必须放该项目内，例如：

- 哪些目录不要改
- 哪些接口必须兼容
- 哪些 SQL 风险高
- 哪个模块怎么测试
- 哪个项目的 codegen 文件怎么处理
- 某个项目发布前有哪些特别检查

一句判断标准：

> 脱离这个项目后，这条规则还成立吗？
>
> - 成立：放全局
> - 不成立：放项目里

---

## 2. 最终推荐目录结构

### 2.1 中央目录（全局事实源）

建议创建：

```text
~/ai-skills/
├── README.md
├── global/
│   ├── core/
│   │   ├── safe-editing/
│   │   │   └── SKILL.md
│   │   ├── validation-required/
│   │   │   └── SKILL.md
│   │   └── task-report/
│   │       └── SKILL.md
│   ├── workflows/
│   │   ├── db-change-safety/
│   │   │   └── SKILL.md
│   │   └── legacy-safe-mode/
│   │       └── SKILL.md
│   └── stacks/
│       ├── typescript-app-workflow/
│       ├── java-service-workflow/
│       ├── python-tooling-workflow/
│       └── go-service-workflow/
├── templates/
│   ├── project-local/
│   │   ├── .ai-skills/
│   │   │   ├── project-constraints/
│   │   │   │   └── SKILL.md
│   │   │   ├── release-guardrails/
│   │   │   │   └── SKILL.md
│   │   │   └── sql-risk-zones/
│   │   │       └── SKILL.md
│   │   ├── AGENTS.md
│   │   ├── CLAUDE.md
│   │   └── GEMINI.md
├── vendor/
│   ├── superpowers/
│   └── gstack/
├── adapters/
│   ├── codex/
│   ├── claude-code/
│   └── gemini/
│       └── commands/
└── scripts/
    ├── install-links.sh
    └── doctor.sh
```

### 2.2 每个项目仓库内的目录

对每个真实项目，在项目根目录内创建：

```text
project-root/
├── .ai-skills/
│   ├── project-constraints/
│   │   └── SKILL.md
│   ├── release-guardrails/
│   │   └── SKILL.md
│   └── sql-risk-zones/
│       └── SKILL.md
├── AGENTS.md
├── CLAUDE.md
└── GEMINI.md
```

说明：

- `~/ai-skills/global/`：全局 skills
- `project-root/.ai-skills/`：项目专属 skills
- `project-root/AGENTS.md`、`CLAUDE.md`、`GEMINI.md`：项目级上下文文件
- `~/ai-skills/templates/project-local/`：项目内文件模板，不是最终运行目录

---

## 3. 第一阶段实施范围

第一阶段只做这 5 个全局 skill：

1. `safe-editing`
2. `validation-required`
3. `task-report`
4. `legacy-safe-mode`
5. `db-change-safety`

暂时不要做：

- python / go / java / typescript 语言专属 skill 内容
- 大量项目级 skill
- release manager / browser qa / reviewer agent 等增强型 roles
- 把 superpowers、gstack 整包混入主干

---

## 4. Codex 需要执行的任务

### 4.1 第一步：创建中央目录

在用户主目录下创建：

- `~/ai-skills/`
- `~/ai-skills/global/core/`
- `~/ai-skills/global/workflows/`
- `~/ai-skills/global/stacks/`
- `~/ai-skills/templates/project-local/`
- `~/ai-skills/vendor/`
- `~/ai-skills/adapters/gemini/commands/`
- `~/ai-skills/scripts/`

并创建 `README.md`。

### 4.2 第二步：创建 5 个全局 skill 目录

创建这些目录与文件：

- `~/ai-skills/global/core/safe-editing/SKILL.md`
- `~/ai-skills/global/core/validation-required/SKILL.md`
- `~/ai-skills/global/core/task-report/SKILL.md`
- `~/ai-skills/global/workflows/legacy-safe-mode/SKILL.md`
- `~/ai-skills/global/workflows/db-change-safety/SKILL.md`

内容使用本文第 6 节给出的初稿。

### 4.3 第三步：创建项目模板，而不是强行写入未知项目

由于用户尚未提供实际项目绝对路径，先在：

- `~/ai-skills/templates/project-local/`

下创建模板文件：

- `.ai-skills/project-constraints/SKILL.md`
- `.ai-skills/release-guardrails/SKILL.md`
- `.ai-skills/sql-risk-zones/SKILL.md`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`

要求：

- 这些模板先写成占位版
- 模板内容用中文
- 标出需要项目维护者自行替换的字段，例如目录、测试命令、发布步骤、高风险模块等

### 4.4 第四步：准备 vendor 目录

创建：

- `~/ai-skills/vendor/superpowers/README.md`
- `~/ai-skills/vendor/gstack/README.md`

说明内容：

- 仅做外部参考与试验，不并入全局主干
- 后续允许从中局部吸收 workflow，但不得直接替换主干 5 skill

### 4.5 第五步：创建 Gemini 适配骨架

创建以下占位命令文件：

- `~/ai-skills/adapters/gemini/commands/fix-safe.toml`
- `~/ai-skills/adapters/gemini/commands/review-ready.toml`
- `~/ai-skills/adapters/gemini/commands/db-check.toml`
- `~/ai-skills/adapters/gemini/commands/legacy-fix.toml`

只需要创建基础占位内容，不必在本阶段写复杂 command 逻辑。

---

## 5. README 建议内容

`~/ai-skills/README.md` 建议至少写明：

1. 此仓库是本地 AI skills 的中央管理目录
2. `global/` 仅放通用 skills
3. 项目专属 rules 不放在 `global/`，而是放到各项目仓库的 `.ai-skills/`
4. `templates/project-local/` 只保存项目模板，不是最终落地点
5. `vendor/` 只保存外部社区包，不得直接替换主干
6. 第一阶段只维护 5 个核心 skill

---

## 6. 第一批 5 个 SKILL.md 初稿

### 6.1 `global/core/safe-editing/SKILL.md`

```md
---
name: safe-editing
description: 适用于修改现有代码、修复 bug、补局部逻辑时；目标是控制改动范围，避免顺手重构和无关修改。
---

## Use when
- 用户要求修改已有代码
- 任务是修 bug、补丁、局部优化、配置修正
- 需要在已有仓库中做小到中等规模改动
- 仓库较复杂，扩大改动范围会增加风险

## Do
1. 先定位与需求直接相关的文件、模块、函数或配置项
2. 优先采用最小闭环修改，而不是扩展成大范围重构
3. 只修改完成当前任务所必需的代码路径
4. 如发现潜在更大问题，先记录为 follow-up，而不是顺手展开
5. 在输出中说明为什么只改这些文件

## Rules
- 不要为了“更优雅”而扩大改动范围
- 不要混入无关格式化、命名调整、目录整理或依赖升级
- 不要同时做功能修改和大重构，除非用户明确要求
- 不要因为顺手就改 shared config、root config 或全局脚本
- 如果必须扩大范围，必须说明原因和影响面

## Validation
- 检查改动文件是否都与当前任务直接相关
- 检查是否混入无关改动
- 检查是否能用更小范围完成目标

## Output
- Changed files
- Why these files
- Scope kept intentionally small
- Follow-up issues noticed
```

### 6.2 `global/core/validation-required/SKILL.md`

```md
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
4. 区分“已验证部分”和“未验证部分"
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
```

### 6.3 `global/core/task-report/SKILL.md`

```md
---
name: task-report
description: 统一任务完成后的输出格式，确保每次都清楚说明改了什么、为什么改、如何验证、还剩什么风险。
---

## Use when
- 任务结束准备汇报
- 用户要求总结改动
- 需要给后续接手的人快速说明上下文
- 修改内容需要可追溯的说明

## Do
1. 用固定结构总结结果
2. 优先写事实，不写空话
3. 先写改动内容，再写原因和验证
4. 如果存在未验证部分或潜在风险，明确列出
5. 如有 follow-up，单独列出，不混在主结论中

## Rules
- 不要输出泛泛而谈的总结
- 不要省略验证信息
- 不要把推测写成事实
- 不要隐藏剩余风险
- 内容要简洁、可扫描、可交接

## Output
Use this structure:

### What I changed
- ...

### Why
- ...

### Validation
- ...

### Risks / follow-ups
- ...
```

### 6.4 `global/workflows/legacy-safe-mode/SKILL.md`

```md
---
name: legacy-safe-mode
description: 适用于老系统、历史包袱重、测试覆盖弱、兼容性要求高的项目；目标是优先稳住行为，避免引入额外变化。
---

## Use when
- 项目是老产品或维护多年的历史系统
- 测试覆盖较弱或验证成本高
- 兼容性、发布稳定性优先级高于“代码更优雅”
- 任务主要是修 bug、补丁、局部兼容修正
- 涉及老接口、老 SQL、老配置或历史行为

## Do
1. 默认采用局部修复，而不是架构整理
2. 优先保持现有行为和兼容性
3. 修改前先识别高风险区域，例如老配置、老事务、老 SQL、公共入口
4. 尽量复用现有模式，而不是引入新框架、新范式、新依赖
5. 输出中明确指出本次改动如何控制风险

## Rules
- 不要把“顺手现代化”当作默认操作
- 不要轻易替换已有基础库、框架写法或项目模式
- 不要在一次任务中同时处理多个历史问题
- 不要改变外部接口行为，除非用户明确要求
- 不要假设老系统一定支持新工具链或新规范
- 如果发现深层问题，记录为 follow-up，而不是直接展开

## Validation
- 检查是否改变了现有接口、配置或关键行为
- 检查是否引入了新的依赖、全局配置变更或额外迁移成本
- 检查改动是否保持在局部范围内

## Output
- Legacy risk areas touched
- Compatibility considerations
- Scope control choices
- Validation performed
- Follow-up recommendations
```

### 6.5 `global/workflows/db-change-safety/SKILL.md`

```md
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
5. 如涉及 schema 变更，考虑兼容窗口和旧代码/新代码共存问题
6. 输出中单独列出风险与验证建议

## Rules
- 不要默认数据库变更是低风险操作
- 不要把 schema 变更和数据回填混成一个模糊动作
- 不要在未说明风险时直接给“可上线”结论
- 不要忽略锁表、长事务、全表扫描或索引失效风险
- 不要把“语法正确”等同于“线上安全”
- 未确认幂等性前，不要声称脚本可重复执行
- 未确认回滚思路前，不要默认可轻易回退

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
```

---

## 7. 项目模板建议内容

### 7.1 `templates/project-local/AGENTS.md`

写成模板，占位字段包括：

- 项目简介
- 目录边界
- 不要修改的目录
- 标准测试命令
- 构建命令
- 高风险模块
- 发布注意事项
- 数据库相关注意点

### 7.2 `templates/project-local/CLAUDE.md`

内容与 `AGENTS.md` 保持核心一致，但可更偏向 Claude Code 的项目说明。

### 7.3 `templates/project-local/GEMINI.md`

内容与前两者一致，增加：

- 推荐 slash commands
- Gemini CLI 常用命令或检查路径

### 7.4 `templates/project-local/.ai-skills/project-constraints/SKILL.md`

建议写：

- 哪些目录不要碰
- 哪些目录只能局部改
- 哪些 config/root files 不能轻动
- 哪些接口兼容性必须保持

### 7.5 `templates/project-local/.ai-skills/release-guardrails/SKILL.md`

建议写：

- 发布前要确认哪些条件
- 哪些步骤必须人工确认
- 哪些配置、迁移、开关要特别小心

### 7.6 `templates/project-local/.ai-skills/sql-risk-zones/SKILL.md`

建议写：

- 哪些表/SQL 风险最高
- 哪些慢查询历史问题要避免重犯
- 哪些 SQL 不允许在生产直接跑

---

## 8. 外部社区包使用规则

### 8.1 superpowers

允许放入 `vendor/superpowers/`，但规则如下：

- 仅做参考和试验
- 不直接复制到 `global/`
- 只允许局部吸收 workflow 思想
- 初期最多挑 1 到 2 个能力点试用

### 8.2 gstack

允许放入 `vendor/gstack/`，但规则如下：

- 仅做增强层
- 不替代主干 5 skill
- 更适合 later phase 的 review / qa / browser / release 类体验增强

### 8.3 禁止事项

- 禁止整包替换 `safe-editing`
- 禁止整包替换 `validation-required`
- 禁止整包替换 `legacy-safe-mode`
- 禁止用外部包替代项目级上下文文件

---

## 9. 完成标准

当以下内容创建完成，即视为第一阶段完成：

1. `~/ai-skills/` 中央目录创建完毕
2. 5 个全局 skill 文件创建完毕
3. `templates/project-local/` 下的模板文件创建完毕
4. `vendor/` 目录准备完毕
5. `adapters/gemini/commands/` 目录与 4 个占位命令文件创建完毕
6. `README.md` 写明目录边界与维护原则

---

## 10. 第二阶段（此文档不要求立即执行）

第二阶段再做：

- `typescript-app-workflow`
- `java-service-workflow`
- `python-tooling-workflow`
- `go-service-workflow`
- 把项目模板真正复制到具体项目仓库中
- 根据真实项目补写 `.ai-skills/project-constraints/` 等项目专属 skill

此阶段在用户提供实际项目路径后执行。

---

## 11. Codex 执行偏好

执行时请遵守：

1. 不要擅自发明过多额外目录
2. 不要把外部 vendor 内容混入 `global/`
3. 不要把项目专属 skill 落到中央 `global/`
4. 中文内容优先
5. 文件结构清晰、命名稳定
6. 第一阶段只创建必要骨架，不做过度设计

