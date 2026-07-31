# Local Document Toolchain

## 选择表

| 目标 | 路径 | 关键原因 |
| --- | --- | --- |
| 普通 PDF | `md2pdf` | 本地、快速、不依赖 Word |
| 含敏感 Mermaid 的 PDF | `md2pdf` | Mermaid 不出本机 |
| 可编辑 DOCX | `md2word` | Word 文档和中文字体 |
| Word 级 PDF 保真 | `md2word` → `word2pdf` | 使用 Word 排版引擎 |

## 前置检查

```bash
which md2pdf md2word word2pdf
```

- `md2pdf`：需要本地 Chrome，可通过 `MD2PDF_CHROME` 覆盖路径。
- `md2word`：Mermaid 需要联网访问 `kroki.io`。
- `word2pdf`：需要 Microsoft Word，以及终端的辅助功能/自动化权限。

只检查本次需要的工具；缺失时不要自动安装。

## md2pdf

Markdown 直接转自包含 HTML 和 PDF，Mermaid 在本地渲染。

```bash
md2pdf docs/foo.md
md2pdf docs/foo.md -o /tmp/foo.pdf
md2pdf docs/foo.md --html-only
```

默认产物位于源文件同目录。可用 `MD2PDF_CHROME`、`MD2PDF_MERMAID_JS` 覆盖本机路径。

常见失败：找不到 Chrome 时提示设置 `MD2PDF_CHROME`，或先用 `--html-only` 验证 HTML；不要自动换实现。

## md2word

Markdown 转 `.docx`，自动处理图片和中文字体；Mermaid 会发送到 Kroki。

```bash
md2word my_doc.md
```

输出通常位于当前工作目录的 `output/`。执行前先确认 cwd 和目标路径。Kroki 网络失败时保留原始错误；敏感 Mermaid 不得使用该路径。

## word2pdf

通过 Microsoft Word 把 `.docx` 转为 `.pdf`。

```bash
word2pdf output/my_doc.docx
word2pdf output/
```

输出与源 `.docx` 同目录。卡住时检查 Word 是否存在模态对话框，以及终端是否具备辅助功能和自动化权限。

## 产物验证

转换命令成功不等于交付完成。至少确认：

- 目标文件存在且非空
- 文件类型可识别、可以打开或读取
- 页数、标题和关键图表符合预期
- Mermaid、中文字体和分页没有明显损坏

无法做视觉验证时，明确说明只完成了文件或结构检查。
