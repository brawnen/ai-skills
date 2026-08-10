#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
required_paths=(
  "README.md"
  "rules/AGENTS.md"
  "global/specialists/architecture-friction-scan/SKILL.md"
  "global/specialists/db-change-safety/SKILL.md"
  "global/specialists/domain-modeling/SKILL.md"
  "global/specialists/domain-modeling/references/context-format.md"
  "global/specialists/domain-modeling/references/adr-format.md"
  "global/specialists/requirements-clarification/SKILL.md"
  "global/specialists/review-cross-stack-change/SKILL.md"
  "global/specialists/systematic-debugging/SKILL.md"
  "global/specialists/test-first-development/SKILL.md"
  "global/helpers/codegraph-assisted-navigation/SKILL.md"
  "global/helpers/formal-html-docs/SKILL.md"
  "global/helpers/formal-html-docs/references/document-types.md"
  "global/helpers/formal-html-docs/assets/formal-document-shell.html"
  "templates/project-local/AGENTS.md"
  "templates/project-local/CLAUDE.md"
  "templates/project-local/GEMINI.md"
  "templates/project-local/.ai-skills/project-constraints/SKILL.md"
  "templates/project-local/.ai-skills/release-guardrails/SKILL.md"
  "templates/project-local/.ai-skills/sql-risk-zones/SKILL.md"
  "templates/project-local/.agents/skills/design-product-ui/SKILL.md"
  "templates/project-local/.agents/skills/design-product-ui/agents/openai.yaml"
  "templates/project-local/.agents/skills/design-product-ui/references/craft-principles.md"
  "templates/project-local/.agents/skills/design-product-ui/references/platform-checks.md"
  "templates/project-local/.agents/skills/design-product-ui/references/review-rubric.md"
  "templates/project-local/.agents/skills/design-product-ui/assets/DESIGN.template.md"
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

for marker in "# User Preferences" "## 沟通" "## 专项 Skill 路由" "## 文档偏好"; do
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
done < <(find \
  "${ROOT_DIR}/global" \
  "${ROOT_DIR}/templates/project-local/.agents/skills" \
  -name SKILL.md -type f | sort)

if [[ "${missing}" -ne 0 ]]; then
  echo "结构检查失败：存在缺失文件。" >&2
  exit 1
fi

echo "结构检查通过。"
