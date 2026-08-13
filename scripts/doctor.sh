#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
required_paths=(
  "AGENTS.md"
  "README.md"
  "config/skills.tsv"
  "config/publish-targets.tsv"
  "rules/AGENTS.md"
  "global/specialists/architecture-friction-scan/SKILL.md"
  "global/specialists/db-change-safety/SKILL.md"
  "global/specialists/domain-modeling/SKILL.md"
  "global/specialists/domain-modeling/references/context-format.md"
  "global/specialists/domain-modeling/references/adr-format.md"
  "global/specialists/decision-clarification/SKILL.md"
  "global/specialists/review-cross-stack-change/SKILL.md"
  "global/specialists/systematic-debugging/SKILL.md"
  "global/specialists/test-first-development/SKILL.md"
  "global/helpers/codegraph-assisted-navigation/SKILL.md"
  "global/helpers/formal-html-docs/SKILL.md"
  "global/helpers/formal-html-docs/references/document-types.md"
  "global/helpers/formal-html-docs/assets/formal-document-shell.html"
  "project/specialists/design-product-ui/SKILL.md"
  "project/specialists/design-product-ui/agents/openai.yaml"
  "project/specialists/design-product-ui/references/craft-principles.md"
  "project/specialists/design-product-ui/references/platform-checks.md"
  "project/specialists/design-product-ui/references/review-rubric.md"
  "project/specialists/design-product-ui/assets/DESIGN.template.md"
  "vendor/superpowers/README.md"
  "vendor/gstack/README.md"
  "adapters/gemini/commands/fix-safe.toml"
  "adapters/gemini/commands/review-ready.toml"
  "adapters/gemini/commands/db-check.toml"
  "adapters/gemini/commands/legacy-fix.toml"
  "scripts/install-links.sh"
  "scripts/publish-skills.sh"
  "scripts/sync-global-platforms.sh"
  "scripts/doctor.sh"
  "tests/publish-skills-test.sh"
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

catalog_names=()
while IFS='|' read -r skill_name skill_scope skill_source skill_bundles skill_status; do
  [[ -z "${skill_name}" || "${skill_name}" == \#* ]] && continue

  for seen_name in "${catalog_names[@]-}"; do
    if [[ "${seen_name}" == "${skill_name}" ]]; then
      echo "MISS config/skills.tsv (重复 skill 名称 ${skill_name})"
      missing=1
    fi
  done
  catalog_names+=("${skill_name}")

  case "${skill_scope}" in
    global|project) ;;
    *) echo "MISS config/skills.tsv (未知 scope ${skill_scope}: ${skill_name})"; missing=1 ;;
  esac

  case "${skill_status}" in
    active)
      case "${skill_scope}:${skill_source}" in
        global:global/*|project:project/*) ;;
        *)
          echo "MISS config/skills.tsv (scope 与源码目录不一致 ${skill_name})"
          missing=1
          ;;
      esac
      if [[ ! -f "${ROOT_DIR}/${skill_source}/SKILL.md" ]]; then
        echo "MISS config/skills.tsv (源码不存在 ${skill_source})"
        missing=1
      elif [[ "$(basename "${skill_source}")" != "${skill_name}" ]]; then
        echo "MISS config/skills.tsv (名称与源码目录不一致 ${skill_name})"
        missing=1
      fi
      [[ -n "${skill_bundles}" && "${skill_bundles}" != "-" ]] || {
        echo "MISS config/skills.tsv (active skill 缺少 bundle ${skill_name})"
        missing=1
      }
      ;;
    retired)
      [[ "${skill_source}" == "-" ]] || {
        echo "MISS config/skills.tsv (retired skill 不应保留源码 ${skill_name})"
        missing=1
      }
      ;;
    *) echo "MISS config/skills.tsv (未知 status ${skill_status}: ${skill_name})"; missing=1 ;;
  esac
done < "${ROOT_DIR}/config/skills.tsv"

for required_target in codex antigravity agents; do
  if ! grep -Eq "^${required_target}\\|" "${ROOT_DIR}/config/publish-targets.tsv"; then
    echo "MISS config/publish-targets.tsv (缺少 ${required_target})"
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
  "${ROOT_DIR}/project" \
  -name SKILL.md -type f | sort)

if [[ "${missing}" -ne 0 ]]; then
  echo "结构检查失败：存在缺失文件。" >&2
  exit 1
fi

echo "结构检查通过。"
