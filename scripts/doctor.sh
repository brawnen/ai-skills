#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

required_paths=(
  "README.md"
  "global/core/safe-editing/SKILL.md"
  "global/core/validation-required/SKILL.md"
  "global/core/task-report/SKILL.md"
  "global/workflows/legacy-safe-mode/SKILL.md"
  "global/workflows/db-change-safety/SKILL.md"
  "templates/project-local/AGENTS.md"
  "templates/project-local/CLAUDE.md"
  "templates/project-local/GEMINI.md"
  "templates/project-local/.ai-skills/project-constraints/SKILL.md"
  "templates/project-local/.ai-skills/release-guardrails/SKILL.md"
  "templates/project-local/.ai-skills/sql-risk-zones/SKILL.md"
  "vendor/superpowers/README.md"
  "vendor/gstack/README.md"
  "adapters/gemini/commands/fix-safe.toml"
  "adapters/gemini/commands/review-ready.toml"
  "adapters/gemini/commands/db-check.toml"
  "adapters/gemini/commands/legacy-fix.toml"
  "scripts/install-links.sh"
  "scripts/doctor.sh"
)

missing=0

for relative_path in "${required_paths[@]}"; do
  absolute_path="${ROOT_DIR}/${relative_path}"
  if [[ -e "${absolute_path}" ]]; then
    echo "OK   ${relative_path}"
  else
    echo "MISS ${relative_path}"
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  echo "结构检查失败：存在缺失文件。" >&2
  exit 1
fi

echo "结构检查通过。"
