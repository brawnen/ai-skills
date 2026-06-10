---
name: doc-converter
description: 适用于把 Markdown 文档转为 Word 或 PDF（macOS 专用，依赖本地 md2pdf / md2word / word2pdf 三个 CLI）；支持 mermaid 自动渲染、中文 PingFang 字体、Word 布局保真。常用于需求文档、投标书、架构文档等专业交付场景。
---

## 适用场景

- 需求文档、投标书、架构文档、汇报材料的最终交付
- Markdown → Word（.docx）：用户需要可继续编辑的版本
- Markdown → PDF：用户需要最终只读交付件
- 含 mermaid 图表的文档

## 不适用场景

- 用户只想看 markdown 渲染效果（编辑器自带预览即可）
- 非 macOS 环境（word2pdf 依赖 AppleScript + Microsoft Word，md2pdf 依赖本地 Chrome）
- 仅做 PDF 拆分 / 合并 / OCR / 加水印 → 走 `anthropic-skills:pdf`
- 仅做现有 docx 编辑、查找替换、插入图片 → 走 `anthropic-skills:docx`

## 与其它 skill 的关系

| 场景 | 优先 skill |
| --- | --- |
| macOS + 中文字体 + Word 排版保真 + 输出 .docx | `doc-converter`（md2word） |
| macOS + 直接出 PDF + 本地渲染 mermaid（不走公网） | `doc-converter`（md2pdf） |
| 跨平台 / 批量编辑现有 docx / python-docx 操作 | `anthropic-skills:docx` |
| PDF 拆分 / 合并 / OCR / 水印 / 表单 | `anthropic-skills:pdf` |

本 skill **不触发** `task-report`：转换是一次性副作用动作，告知输出路径即可，不走五段式汇报。

## 前置条件

执行前必须先确认（任一缺失就告知用户，不要硬跑）：

| 工具 | 必需依赖 |
| --- | --- |
| `md2pdf` | 已安装于 `~/.local/bin/md2pdf`；需要本地 Chrome（或设 `MD2PDF_CHROME`）；mermaid 本地渲染，无网络依赖 |
| `md2word` | 已安装于 `/opt/homebrew/bin/md2word`；mermaid 图表需要联网访问 `kroki.io` |
| `word2pdf` | macOS + 已安装 Microsoft Word + 终端已授权"辅助功能 / 自动化"权限 |

预检命令：

```bash
which md2pdf md2word word2pdf
```

任一不存在，先告知用户安装方式或换工具，不要直接报错。

## 工具说明

### 1. `md2pdf`（推荐默认 PDF 路径）

- **能力**：Markdown 直接转 PDF，用本地 Chrome 渲染 HTML → PDF
- **优势**：mermaid 本地渲染（无网络、无隐私问题）；不依赖 Word；速度快
- **输出**：默认在**源文件同目录**生成同名 `.html` + `.pdf`
- **用法**：

  ```bash
  # 默认输出 docs/foo.pdf 和 docs/foo.html
  md2pdf docs/foo.md

  # 自定义 PDF 路径
  md2pdf docs/foo.md -o /tmp/foo.pdf

  # 只生成 HTML，不需要 Chrome
  md2pdf docs/foo.md --html-only
  ```

- **环境变量**：`MD2PDF_CHROME`、`MD2PDF_MERMAID_JS` 可覆盖默认路径

### 2. `md2word`

- **能力**：Markdown 转 Word（.docx），自动渲染 mermaid（走 Kroki API）+ 自动缩放图片 + 注入 PingFang SC 中文字体
- **输出**：在 `output/` 子目录下生成 `.docx`（路径相对**当前工作目录**，调用前先 `cd` 到目标位置）
- **用法**：

  ```bash
  md2word my_doc.md
  ```

- **注意**：mermaid 内容会上传到公网 `kroki.io`，含敏感信息时禁止使用（见禁止事项）

### 3. `word2pdf`

- **能力**：把 `.docx` 转为 `.pdf`，用 `docx2pdf`（AppleScript + Microsoft Word），布局 100% 保真
- **输出**：与源 `.docx` 同目录同名 `.pdf`
- **用法**：

  ```bash
  word2pdf output/my_doc.docx       # 单文件
  word2pdf output/                  # 批量整个目录
  ```

- **注意**：依赖 Word UI 自动化，可能弹出"辅助功能"授权弹窗

## 选型规则

| 目标产物 | 推荐路径 | 原因 |
| --- | --- | --- |
| 仅需 PDF，普通文档 | `md2pdf` | 快、本地、无 Word 依赖 |
| 仅需 PDF，含敏感 mermaid | `md2pdf` | mermaid 本地渲染，不走公网 |
| 仅需 PDF，需要 Word 级排版保真或 PingFang 字体 | `md2word` → `word2pdf` | Word 排版引擎 |
| 需要可继续编辑的 .docx | `md2word`（可选再 `word2pdf` 出 PDF） | 必走 docx |

## 核心规则

1. 用户提"导出 / 转 word / 生成 pdf"时，优先用本 skill 而非自写脚本。
2. 调用前用 `which` 检查工具存在性；不存在不要硬跑，告知用户。
3. 通过宿主的 shell / bash 工具调用（Claude Code 是 `Bash`，Codex 是 `shell`，Gemini 是其原生 shell 工具），抽象层一致即可。
4. 转换完成后告知用户产物路径，不走 `task-report` 五段式汇报。
5. 失败时保留原始报错给用户，不擅自猜原因。

## 禁止事项

- **含敏感信息（内部系统名、密钥、未公开架构等）的 mermaid 禁止使用 `md2word`**，因为会上传到公网 `kroki.io`；改用 `md2pdf`（本地渲染）。
- 不要在非 macOS 环境上调用 `word2pdf`。
- 不要混淆输出路径：`md2word` 输出相对**当前工作目录**，`md2pdf` 输出相对**源文件目录**。
- 不要因为某个工具失败就自动 fallback 到 Python 脚本，先告知用户失败原因。
- 不要假设三个工具都存在 —— 用户机器可能只装了其中一两个。

## 失败兜底

| 工具 | 常见失败 | 处理 |
| --- | --- | --- |
| `md2pdf` | 找不到 Chrome | 提示设置 `MD2PDF_CHROME`，或改用 `--html-only` 先看 HTML |
| `md2word` | Kroki 网络不通 | 告知用户检查网络 / 公司代理；含敏感内容建议改用 `md2pdf` |
| `word2pdf` | 卡住 / 无响应 | 提示检查终端"辅助功能 / 自动化"权限，或 Word 是否有模态对话框 |
| 任一工具不存在 | `which` 失败 | 告知用户该工具未安装，给出备选路径 |
