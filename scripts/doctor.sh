#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXTERNAL_SYSTEMATIC_DEBUGGING_FILE="${SYSTEMATIC_DEBUGGING_DIR:-${HOME}/.skillshub/superpower/skills/systematic-debugging}/SKILL.md"
EXTERNAL_IMPECCABLE_FILE="${IMPECCABLE_DIR:-${HOME}/.agents/skills/impeccable}/SKILL.md"

required_paths=(
  "README.md"
  "rules/AGENTS.md"
  "global/specialists/architecture-friction-scan/SKILL.md"
  "global/specialists/code-evidence-docs/SKILL.md"
  "global/specialists/db-change-safety/SKILL.md"
  "global/specialists/production-incident-hotfix/SKILL.md"
  "global/specialists/project-release-scope-check/SKILL.md"
  "global/specialists/repo-intake-scan/SKILL.md"
  "global/specialists/requirements-clarification/SKILL.md"
  "global/specialists/safe-editing/SKILL.md"
  "global/specialists/test-first-development/SKILL.md"
  "global/workflows/frontend-project-flow/SKILL.md"
  "global/workflows/frontend-project-flow/references/delivery-stages.md"
  "global/workflows/frontend-project-flow/references/quality-gates.md"
  "global/workflows/frontend-project-flow/references/routing.md"
  "global/workflows/task-todolist-execution/SKILL.md"
  "global/helpers/codegraph-assisted-navigation/SKILL.md"
  "global/helpers/doc-converter/SKILL.md"
  "global/helpers/doc-converter/references/local-toolchain.md"
  "global/helpers/formal-html-docs/SKILL.md"
  "global/helpers/formal-html-docs/references/document-types.md"
  "global/helpers/formal-html-docs/assets/formal-document-shell.html"
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

for marker in "# User Core Rules" "SKILL_ROUTING_START" "DOC_FORMAT_START" "CODEGRAPH_START"; do
  if ! grep -Fq "${marker}" "${ROOT_DIR}/rules/AGENTS.md"; then
    echo "MISS rules/AGENTS.md (缺少必要标记 ${marker})"
    missing=1
  fi
done

while IFS= read -r skill_file; do
  skill_dir="$(dirname "${skill_file}")"
  skill_name="$(basename "${skill_dir}")"
  metadata_file="${skill_dir}/agents/openai.yaml"

  if [[ ! -f "${metadata_file}" ]]; then
    echo "MISS ${metadata_file#${ROOT_DIR}/}"
    missing=1
    continue
  fi

  if ! grep -Eq '^  display_name: ".+"$' "${metadata_file}"; then
    echo "MISS ${metadata_file#${ROOT_DIR}/} (缺少 display_name)"
    missing=1
    continue
  fi

  short_description="$(sed -n 's/^  short_description: "\(.*\)"$/\1/p' "${metadata_file}")"
  if [[ "${#short_description}" -lt 25 || "${#short_description}" -gt 64 ]]; then
    echo "MISS ${metadata_file#${ROOT_DIR}/} (short_description 必须为 25-64 字符)"
    missing=1
    continue
  fi

  if ! grep -Fq "\$${skill_name}" "${metadata_file}"; then
    echo "MISS ${metadata_file#${ROOT_DIR}/} (default_prompt 未引用 \$${skill_name})"
    missing=1
    continue
  fi

  if ! grep -Eq '^  allow_implicit_invocation: true$' "${metadata_file}"; then
    echo "MISS ${metadata_file#${ROOT_DIR}/} (未启用隐式调用)"
    missing=1
    continue
  fi

  echo "OK   ${metadata_file#${ROOT_DIR}/}"
done < <(find "${ROOT_DIR}/global" -name SKILL.md -type f | sort)

if [[ -f "${EXTERNAL_SYSTEMATIC_DEBUGGING_FILE}" ]]; then
  echo "OK   external/systematic-debugging"
else
  echo "WARN external/systematic-debugging (未检测到外部 core 补充 skill)"
fi

if [[ -f "${EXTERNAL_IMPECCABLE_FILE}" ]]; then
  echo "OK   external/impeccable"
else
  echo "WARN external/impeccable (未检测到默认设计 skill)"
fi

if [[ "${missing}" -ne 0 ]]; then
  echo "结构检查失败：存在缺失文件。" >&2
  exit 1
fi

echo "结构检查通过。"
