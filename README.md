# 本地 AI Skills 中央目录

这个目录用于集中管理本地 AI skills 的事实源与模板，目标是保持结构清晰、边界稳定、维护成本可控。

## 目录边界

- `global/`：仅放跨项目通用的 skills，不放任何依赖具体仓库上下文的规则。
- `templates/project-local/`：项目级模板目录，只保存占位模板，不是最终落地点。
- `vendor/`：保存外部社区包的参考材料与试验内容，不得直接替换主干 skills。
- `adapters/`：为不同 CLI 或代理工具准备的适配骨架。
- `scripts/`：用于安装链接与结构巡检的辅助脚本。

## 维护原则

1. 第一阶段只维护 5 个核心 skill：
   - `safe-editing`
   - `validation-required`
   - `task-report`
   - `legacy-safe-mode`
   - `db-change-safety`
2. `global/` 只放通用规则，例如最小改动、验证要求、统一汇报、数据库风险分析、老系统保守模式。
3. 项目专属 rules 不放在 `global/`，而应放到具体项目仓库的 `.ai-skills/` 与项目级上下文文件中。
4. `templates/project-local/` 只保存项目模板，真实项目落地时应复制到具体项目根目录。
5. `vendor/` 中的社区包仅做参考和试验，不得整包混入主干或直接替换核心 skill。

## 当前阶段目标

当前目录完成的是第一阶段骨架：

- 5 个全局核心 skill
- 项目级模板
- vendor 占位目录
- Gemini 适配命令骨架
- 最小可用的安装与巡检脚本

第二阶段再补充语言 / 技术栈 workflow 与真实项目接入。
