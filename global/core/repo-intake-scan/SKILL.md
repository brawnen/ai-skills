---
name: repo-intake-scan
description: 适用于接手新仓库、旧项目复活、工作区盘点或 /init 后建立项目认知；输出项目根、技术栈、运行/验证入口、环境阻塞、AGENTS 建议和下一步。
---

# Repo Intake Scan

## Use when

- 用户打开陌生仓库、旧项目、非 Git 顶层 workspace，或说“去年项目今年继续推进”“帮我 init/看看项目”。
- 需要先判断主项目目录、技术栈、依赖版本和可运行入口。
- 需要生成或更新仓库级 AGENTS.md 前的事实盘点。

## Coordinate with existing skills

- 发现 legacy 项目后，后续改动同时遵守 `safe-editing` 或 `legacy-safe-mode`。
- 发现 DB 写入路径后，后续变更用 `db-change-safety`。
- 只做只读盘点时不要改文件；用户要求落盘时再用 `code-evidence-docs`。

## Workflow

1. 确认当前目录、Git 根和是否为多项目 workspace。
2. 识别主项目候选：README、package/pom/pyproject、入口文件、最近改动、用户目标相关目录。
3. 如果项目存在 `.codegraph/` 或用户要求使用 CodeGraph，先把它当作可选索引源：
   - `codegraph status --json` 查看索引是否新鲜。
   - 用 `codegraph query` 快速定位主入口、关键服务、测试和配置符号。
   - CodeGraph 结果只作为第一轮候选，项目根、环境要求和验证命令仍要回读真实文件确认。
4. 读取环境要求：Node/Python/JDK/Maven/Poetry/venv、依赖安装状态、脚本命令。
5. 区分环境问题与业务代码问题；保留原始报错。
6. 找到最小验证入口：
   - build/compile
   - unit test
   - lint/typecheck
   - smoke/import check
   - 文档结构检查
7. 输出当前可推进路径和阻塞项；不要在未确认主项目根前跑重型构建。
8. 若要生成 AGENTS.md，先说明 `/init` 只建立会话认知，落盘文件需要显式创建。

## Output

```markdown
## 项目根判断
- 当前目录：
- Git 根：
- 主项目：
- 依据：

## 技术栈与环境
- ...

## 可用命令
- ...

## 阻塞
- 原始报错：
- 判断：

## 下一步
- ...
```

## Guardrails

- 不把 workspace 顶层默认当 Git repo。
- 不在旧 Node/Gulp、pyenv/Poetry、JDK/Maven 不匹配时贸然把失败归因到业务代码。
- 不把依赖缺失导致的 test 失败写成代码失败。
- 不自动创建 AGENTS.md，除非用户要求或任务明确进入文档落地。
- 不因为 CodeGraph 已索引就跳过 README、构建脚本、包管理文件和实际验证命令。
