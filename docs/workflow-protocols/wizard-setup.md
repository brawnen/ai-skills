# 人工外部控制台与密钥交互式向导（Wizard）

当项目初始化、联调或上线前需要人类在第三方网页控制台手工完成的步骤（如开通支付商户、创建 Apple/Google/微信 OAuth 应用、配置云存储/数据库凭证、补齐 `.env` 与 GitHub Actions `secrets.*` / `vars.*`、或执行单次切换窗口）时使用。Agent 能自行完成的步骤严禁做成向导。

方法与模板源自 Matt Pocock `wizard`（见同目录 `UPSTREAM.md` 与 `LICENSE.mattpocock`）。

## 生成与核验流程

1. **先读仓库盘清清单（不空手反问）**：
   - 扫描 `.env.example`、`.env.*`、`README`、`docker-compose*`、应用配置读取处及 `.github/workflows/*` 中的所有 `secrets.*` / `vars.*` 引用；
   - 列出有序步骤与每个变量的三要素：**从哪个后台页面获取**、**写往何处**（本地 `.env`、GitHub Secret/Variable 或两者兼有）、**是否敏感密钥**（决定明文 `ask` 还是隐藏输入 `ask_secret`），先向用户简短确认列表。
2. **明确每步操作路径**：
   - 写清打开的精确控制台 URL 与点击路径（如 `控制台 → 开发者 → API 密钥 → 复制 Secret Key`）；不确定的第三方最新菜单如实说明或先查官方文档，绝不编造不存在的按钮。
3. **基于模板生成脚本**：
   - 复制 `scripts/wizard-template.sh`（随 `$x-dev` 分发于 `<x-dev>/scripts/wizard-template.sh`）到临时路径或项目 `scripts/setup-wizard.sh`（默认一次性使用、跑完即删；仅当用户希望沉淀为团队可重复初始化入口时才提交进仓库并在 `README` 留链接）。
   - **保持 `STAGES` 标记上方的公共库原封不动**，仅编写 `run_wizard()` 内的 `TOTAL_STAGES`、`banner` 与各 `stage`（先 `open_url` 再 `ask`/`ask_secret`，敏感项必用 `ask_secret`，仅对 CI 实际引用的变量调 `set_secret`，不可逆动作前加 `confirm`）。
4. **静态核验后交接**：
   - 运行 `bash -n <script>`（有 `shellcheck` 时一并运行）并 `chmod +x <script>`；
   - **不要由 Agent 自己跑交互主循环**（会唤起浏览器并阻塞在终端读入），改为静态逐项核对：第 1 步盘出的每个变量均被捕获并写入目标位置，`set_secret` 名称与 workflow 中的 `secrets.*` 精确一致，然后告知用户运行命令。
