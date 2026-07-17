#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXTERNAL_SYSTEMATIC_DEBUGGING_FILE="${SYSTEMATIC_DEBUGGING_DIR:-${HOME}/.skillshub/superpower/skills/systematic-debugging}/SKILL.md"

required_paths=(
  "README.md"
  "global/core/architecture-friction-scan/SKILL.md"
  "global/core/code-evidence-docs/SKILL.md"
  "global/core/codegraph-assisted-navigation/SKILL.md"
  "global/core/doc-converter/SKILL.md"
  "global/core/formal-html-docs/SKILL.md"
  "global/core/production-incident-hotfix/SKILL.md"
  "global/core/project-release-scope-check/SKILL.md"
  "global/core/repo-intake-scan/SKILL.md"
  "global/core/requirements-clarification/SKILL.md"
  "global/core/safe-editing/SKILL.md"
  "global/core/task-report/SKILL.md"
  "global/core/test-first-development/SKILL.md"
  "global/workflows/db-change-safety/SKILL.md"
  "global/workflows/frontend-project-flow/SKILL.md"
  "global/workflows/frontend-project-flow/references/delivery-stages.md"
  "global/workflows/frontend-project-flow/references/quality-gates.md"
  "global/workflows/frontend-project-flow/references/routing.md"
  "global/workflows/task-todolist-execution/SKILL.md"
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
  "scripts/sync-global-platforms.sh"
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

if [[ -f "${EXTERNAL_SYSTEMATIC_DEBUGGING_FILE}" ]]; then
  echo "OK   external/systematic-debugging"
else
  echo "WARN external/systematic-debugging (未检测到外部 core 补充 skill)"
fi

if [[ "${missing}" -ne 0 ]]; then
  echo "结构检查失败：存在缺失文件。" >&2
  exit 1
fi

echo "结构检查通过。"
