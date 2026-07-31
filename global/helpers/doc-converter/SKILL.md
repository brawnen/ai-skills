---
name: doc-converter
description: 适用于把 Markdown 文档转为 Word 或 PDF（macOS 专用，依赖本地 md2pdf / md2word / word2pdf 三个 CLI）；支持 mermaid 自动渲染、中文 PingFang 字体、Word 布局保真。常用于需求文档、投标书、架构文档等专业交付场景。
---

# Doc Converter

## 边界

只负责在 macOS 上调用已安装的本机 CLI 完成 Markdown、Word 和 PDF 之间的确定性转换。

适用：

- Markdown 转可编辑 `.docx`
- Markdown 直接转 `.pdf`
- Word 转 PDF，且需要 Word 排版保真
- 含 Mermaid 或需要中文字体控制的正式交付

不适用：

- 仅预览 Markdown
- PDF 读取、创建、拆分、合并、旋转、表单或视觉验收；使用宿主 PDF 能力
- 编辑现有 Word 内容；使用宿主文档能力
- 非 macOS 环境

## 路由

- 普通或含敏感 Mermaid 的 PDF：优先 `md2pdf`，保持本地渲染。
- 需要可继续编辑或 Word 级排版：使用 `md2word`，必要时再用 `word2pdf`。
- 只处理已有 PDF：Codex 使用官方 PDF 插件，其他宿主使用各自原生能力。

## 工作流

1. 在执行任何转换前读取 [local-toolchain.md](references/local-toolchain.md) 中对应工具章节。
2. 用 `which md2pdf md2word word2pdf` 检查所需工具；缺失时说明缺口和替代路径，不自行安装。
3. 确认输入、目标格式、输出路径和敏感信息边界。
4. 调用最小转换链，不因失败自动改写成临时 Python 脚本。
5. 检查产物存在、大小合理且可读取；条件允许时做渲染或页面抽查。
6. 简洁说明输出路径、执行工具、验证结果和未验证项。

## 安全边界

- `md2word` 的 Mermaid 会发送到公网 Kroki；含内部系统名、密钥、未公开架构或其他敏感信息时禁止使用，改走本地 `md2pdf`。
- `word2pdf` 依赖 Microsoft Word UI 自动化，不在非 macOS 环境调用。
- 保留工具原始错误，不把依赖或权限问题伪装成文档内容错误。
- 用户没有要求转换时，不因正式文档路由自动加载本 skill。
