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
  "global/specialists/x-arch/SKILL.md"
  "global/specialists/x-arch/references/architecture-design.md"
  "global/specialists/x-arch/references/cross-boundary-design.md"
  "global/specialists/x-db/SKILL.md"
  "global/specialists/x-db/references/online-ddl-pitfalls.md"
  "global/specialists/x-api/SKILL.md"
  "global/specialists/x-api/references/api-conventions.md"
  "global/specialists/x-req/SKILL.md"
  "global/specialists/x-req/references/context-format.md"
  "global/specialists/x-req/references/adr-format.md"
  "global/specialists/x-debug/SKILL.md"
  "global/specialists/x-debug/references/benchmark-checklist.md"
  "global/specialists/x-biz/SKILL.md"
  "global/specialists/x-biz/references/evidence-and-market-research.md"
  "global/specialists/x-biz/references/decision-models-and-deliverables.md"
  "global/specialists/x-dev/SKILL.md"
  "global/specialists/x-dev/references/verification.md"
  "global/specialists/x-dev/references/release.md"
  "global/specialists/x-dev/references/wizard-setup.md"
  "global/specialists/x-dev/scripts/check-task-graph.py"
  "global/specialists/x-dev/scripts/wizard-template.sh"
  "global/specialists/x-spec/SKILL.md"
  "global/specialists/x-review/SKILL.md"
  "global/specialists/x-review/references/release.md"
  "global/specialists/x-verify/SKILL.md"
  "global/specialists/x-guard/SKILL.md"
  "global/specialists/x-guard/references/project-modes.md"
  "global/specialists/x-guard/references/rule-encoding.md"
  "global/specialists/x-guard/references/sql-guardrails.md"
  "global/specialists/x-guard/references/ts-deep-modules.md"
  "global/specialists/x-guard/references/retro.md"
  "global/specialists/x-guard/references/authoring.md"
  "global/specialists/x-redteam/SKILL.md"
  "global/specialists/x-redteam/references/adversarial-protocol.md"
  "vendor/global-skills/x-rea/SKILL.md"
  "vendor/global-skills/x-rea/UPSTREAM-SKILL.md"
  "vendor/global-skills/x-rea/UPSTREAM.md"
  "vendor/global-skills/x-rea/LICENSE"
  "vendor/global-skills/x-rea/references/desktop-build.md"
  "docs/delivery-artifacts-spec.md"
  "docs/workflow-protocols/requirements.md"
  "docs/workflow-protocols/spec.md"
  "docs/workflow-protocols/tickets.md"
  "docs/workflow-protocols/implementation.md"
  "docs/workflow-protocols/verification.md"
  "docs/workflow-protocols/review.md"
  "docs/workflow-protocols/pr.md"
  "docs/workflow-protocols/release.md"
  "docs/workflow-protocols/wizard-setup.md"
  "docs/workflow-protocols/retro.md"
  "docs/workflow-protocols/parallel-implementation.md"
  "docs/workflow-protocols/prototype.md"
  "docs/workflow-protocols/architecture-design.md"
  "docs/workflow-protocols/cross-boundary-design.md"
  "docs/workflow-protocols/authoring.md"
  "docs/workflow-protocols/UPSTREAM.md"
  "docs/workflow-protocols/LICENSE.mattpocock"
  "scripts/check-task-graph.py"
  "scripts/wizard-template.sh"
  "scripts/check-workflow.sh"
  "docs/verification.md"
  "vendor/mattpocock.snapshot.json"
  "vendor/mattpocock/LICENSE"
  "tests/workflow-contract-test.py"
  "global/helpers/x-html/SKILL.md"
  "global/helpers/x-html/references/document-types.md"
  "global/helpers/x-html/references/flow-diagrams.md"
  "global/helpers/x-html/references/template-routing.md"
  "global/helpers/x-html/assets/formal-document-shell.html"
  "global/helpers/x-html/assets/templates/decision-brief.html"
  "global/helpers/x-html/assets/templates/engineering-review.html"
  "global/specialists/x-ui/SKILL.md"
  "global/specialists/x-ui/agents/openai.yaml"
  "global/specialists/x-ui/references/discovery-and-prototyping.md"
  "global/specialists/x-ui/references/brand-archetypes.md"
  "global/specialists/x-ui/references/capability-routing.md"
  "global/specialists/x-ui/references/craft-principles.md"
  "global/specialists/x-ui/references/platform-checks.md"
  "global/specialists/x-ui/references/review-rubric.md"
  "global/specialists/x-ui/assets/DESIGN.template.md"
  "vendor/global-skills/ui-ux-pro-max/SKILL.md"
  "vendor/global-skills/ui-ux-pro-max/agents/openai.yaml"
  "vendor/global-skills/ui-ux-pro-max/UPSTREAM.md"
  "vendor/global-skills/ui-ux-pro-max/LICENSE"
  "vendor/global-skills/impeccable/SKILL.md"
  "vendor/global-skills/impeccable/agents/openai.yaml"
  "vendor/global-skills/impeccable/UPSTREAM.md"
  "vendor/global-skills/impeccable/LICENSE"
  "vendor/superpowers/README.md"
  "vendor/gstack/README.md"
  "scripts/install-links.sh"
  "scripts/publish-skills.sh"
  "scripts/sync-global-platforms.sh"
  "scripts/doctor.sh"
  "tests/publish-skills-test.sh"
  "tests/formal-html-docs-test.sh"
  "tests/verification-flow-test.py"
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

# 拦截已退役或误留下的空壳 skill 子目录
for skill_parent in \
  "global/specialists" \
  "global/helpers" \
  "project/specialists" \
  "vendor/global-skills" \
  "vendor/project-skills"; do
  [[ -d "${ROOT_DIR}/${skill_parent}" ]] || continue
  while IFS= read -r child_dir; do
    if [[ ! -f "${child_dir}/SKILL.md" ]]; then
      echo "MISS ${child_dir#${ROOT_DIR}/} (存在缺少 SKILL.md 的残留空壳目录)"
      missing=1
    fi
  done < <(find "${ROOT_DIR}/${skill_parent}" -mindepth 1 -maxdepth 1 -type d | sort)
done

catalog_names=()
catalog_scopes=()
catalog_statuses=()
catalog_dependencies=()
while IFS='|' read -r skill_name skill_scope skill_source skill_bundles skill_status skill_dependencies; do
  [[ -z "${skill_name}" || "${skill_name}" == \#* ]] && continue

  for seen_name in "${catalog_names[@]-}"; do
    if [[ "${seen_name}" == "${skill_name}" ]]; then
      echo "MISS config/skills.tsv (重复 skill 名称 ${skill_name})"
      missing=1
    fi
  done
  catalog_names+=("${skill_name}")
  catalog_scopes+=("${skill_scope}")
  catalog_statuses+=("${skill_status}")
  catalog_dependencies+=("${skill_dependencies:--}")

  case "${skill_scope}" in
    global|project) ;;
    *) echo "MISS config/skills.tsv (未知 scope ${skill_scope}: ${skill_name})"; missing=1 ;;
  esac

  case "${skill_status}" in
    active)
      case "${skill_scope}:${skill_source}" in
        global:global/*|global:vendor/global-skills/*|project:project/*|project:vendor/project-skills/*) ;;
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
      elif ! grep -Eq "^name: ${skill_name}$" "${ROOT_DIR}/${skill_source}/SKILL.md"; then
        echo "MISS ${skill_source}/SKILL.md (frontmatter name 与 ${skill_name} 不一致)"
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

for ((catalog_index=0; catalog_index<${#catalog_names[@]}; catalog_index++)); do
  dependency_csv="${catalog_dependencies[catalog_index]}"
  [[ -n "${dependency_csv}" && "${dependency_csv}" != "-" ]] || continue
  dependency_names=()
  IFS=',' read -r -a dependency_names <<< "${dependency_csv}"
  for dependency_name in "${dependency_names[@]}"; do
    if [[ -z "${dependency_name}" || "${dependency_name}" == "${catalog_names[catalog_index]}" ]]; then
      echo "MISS config/skills.tsv (非法依赖 ${catalog_names[catalog_index]} -> ${dependency_name:-<empty>})"
      missing=1
      continue
    fi
    dependency_found=0
    for ((dependency_index=0; dependency_index<${#catalog_names[@]}; dependency_index++)); do
      [[ "${catalog_names[dependency_index]}" == "${dependency_name}" ]] || continue
      dependency_found=1
      if [[ "${catalog_statuses[dependency_index]}" != "active" ]]; then
        echo "MISS config/skills.tsv (依赖未启用 ${catalog_names[catalog_index]} -> ${dependency_name})"
        missing=1
      fi
      if [[ "${catalog_scopes[dependency_index]}" != "${catalog_scopes[catalog_index]}" ]]; then
        echo "MISS config/skills.tsv (依赖 scope 不一致 ${catalog_names[catalog_index]} -> ${dependency_name})"
        missing=1
      fi
      break
    done
    if [[ "${dependency_found}" -eq 0 ]]; then
      echo "MISS config/skills.tsv (依赖不存在 ${catalog_names[catalog_index]} -> ${dependency_name})"
      missing=1
    fi
  done
done

for required_target in codex antigravity agents; do
  if ! grep -Eq "^${required_target}\\|" "${ROOT_DIR}/config/publish-targets.tsv"; then
    echo "MISS config/publish-targets.tsv (缺少 ${required_target})"
    missing=1
  fi
done

for marker in "# User Preferences" "## 沟通与解释" "## 交付与安全红线" "## 工具与文档边界"; do
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

  if ! grep -Eq '^  allow_implicit_invocation: (true|false)$' "${metadata_file}"; then
    echo "MISS ${metadata_file#${ROOT_DIR}/} (调用策略缺失或不是布尔值)"
    missing=1
    continue
  fi

  echo "OK   ${metadata_file#${ROOT_DIR}/}"
done < <(
  for scan_root in \
    "${ROOT_DIR}/global" \
    "${ROOT_DIR}/project" \
    "${ROOT_DIR}/vendor/project-skills" \
    "${ROOT_DIR}/vendor/global-skills"; do
    [[ -d "${scan_root}" ]] && find "${scan_root}" -name SKILL.md -type f
  done | sort
)

if [[ "${missing}" -ne 0 ]]; then
  echo "结构检查失败：存在缺失或不一致文件。" >&2
  exit 1
fi

echo "结构检查通过。"
