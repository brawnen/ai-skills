---
name: "doc-converter"
description: "Uses system-level CLI tools (md2word and word2pdf) to convert Markdown files to Word and PDF formats."
---

# 📖 Document Converter Skill

## 🎯 Purpose
This skill equips the AI with the ability to automatically convert the user's Markdown documents into beautifully formatted Word (.docx) and PDF (.pdf) files on the user's Mac. 

This is incredibly useful when the user is writing requirements, bids, or architecture documents and needs them in professional delivery formats.

## 🛠️ Tools Given to You
You have access to two custom, system-level CLI commands built natively into the user's `/opt/homebrew/bin/` paths. **You can call them directly via `run_command`**.

### 1. `md2word`
Converts `.md` to `.docx`.
- **Special Power**: It automatically parses and renders any ` ```mermaid ` chunks in the Markdown into high-quality images via the Kroki API before conversion. It also auto-scales images that are too tall for A4 paper and injects elegant "PingFang SC" fonts.
- **Usage**:
  ```bash
  md2word my_doc.md
  ```
  *(This will generate `my_doc.docx` in an `output/` subdirectory.)*

### 2. `word2pdf`
Converts `.docx` to `.pdf`.
- **Special Power**: It uses `docx2pdf` (AppleScript + MS Word) to strictly guarantee 100% layout fidelity. No broken tables, no displaced images.
- **Usage**:
  ```bash
  # Convert a specific file
  word2pdf output/my_doc.docx
  
  # Or batch convert an entire directory!
  word2pdf output/
  ```

## 📋 Rule of Execution
1. **Always use these tools instead of scripts when the user asks for document conversion to Word or PDF.**
2. When the user asks to "export", "convert to word", or "generate a pdf", leverage `run_command` with `md2word` first, followed by `word2pdf`.
3. Inform the user to check the `output/` directory for the final generated artifacts.
4. If `word2pdf` hangs or fails, remind the user that it interacts with Microsoft Word via macOS UI automation, so they may need to check for a security popup on their desktop (Terminal asking for accessibility/automation permissions) or close Word if it's exhibiting a modal dialog.
