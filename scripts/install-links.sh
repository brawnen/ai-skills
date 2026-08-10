#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/global"
DEFAULT_TARGET_DIR="${HOME}/.codex/skills"
global_specialist_skills=(
  "specialists/requirements-clarification"
  "specialists/systematic-debugging"
  "specialists/test-first-development"
  "specialists/db-change-safety"
)

core_skills=(
  "${global_specialist_skills[@]}"
)

optional_architecture_skills=(
  "specialists/architecture-friction-scan"
  "specialists/review-cross-stack-change"
  "specialists/domain-modeling"
  "helpers/codegraph-assisted-navigation"
)

optional_doc_helpers=(
  "helpers/formal-html-docs"
)

managed_skill_names=(
  "architecture-friction-scan"
  "codegraph-assisted-navigation"
  "db-change-safety"
  "domain-modeling"
  "formal-html-docs"
  "requirements-clarification"
  "review-cross-stack-change"
  "systematic-debugging"
  "test-first-development"
)

retired_skill_names=(
  "code-review"
  "code-evidence-docs"
  "doc-converter"
  "frontend-project-flow"
  "pdf"
  "production-incident-hotfix"
  "project-release-scope-check"
  "repo-intake-scan"
  "safe-editing"
  "taste-skill"
  "task-report"
  "task-todolist-execution"
  "validation-required"
  "verification-before-completion"
)

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "未找到全局 skills 目录: ${SOURCE_DIR}" >&2
  exit 1
fi

print_bundle_list() {
  cat <<'EOF'
可用 bundles:
  core          默认专项：需求收敛、系统调试、TDD、数据库安全
  architecture  可选的架构扫描、跨栈评审、领域建模与 CodeGraph 辅助
  docs          可选的自包含正式 HTML helper
  all           安装 core + 全部可选能力
EOF
}

TARGET_DIR="${DEFAULT_TARGET_DIR}"
bundles=()

if [[ "${1:-}" == "--list" ]]; then
  print_bundle_list
  exit 0
fi

if [[ "${1:-}" == /* || "${1:-}" == "~/"* ]]; then
  TARGET_DIR="${1/#\~/${HOME}}"
  shift
fi

if [[ "$#" -eq 0 ]]; then
  bundles=("core")
else
  bundles=("$@")
fi

mkdir -p "${TARGET_DIR}"

link_skill() {
  local relative_path="$1"
  local skill_path="${SOURCE_DIR}/${relative_path}"
  local skill_name
  skill_name="$(basename "${skill_path}")"
  if [[ ! -d "${skill_path}" ]]; then
    echo "缺失 skill 目录: ${skill_path}" >&2
    exit 1
  fi
  ln -sfn "${skill_path}" "${TARGET_DIR}/${skill_name}"
  echo "linked ${skill_name} -> ${skill_path}"
}

append_bundle() {
  local bundle="$1"
  case "${bundle}" in
    core)
      selected_skills+=("${core_skills[@]}")
      ;;
    architecture)
      selected_skills+=("${optional_architecture_skills[@]}")
      ;;
    docs)
      selected_skills+=("${optional_doc_helpers[@]}")
      ;;
    all)
      selected_skills+=(
        "${core_skills[@]}"
        "${optional_architecture_skills[@]}"
        "${optional_doc_helpers[@]}"
      )
      ;;
    *)
      echo "未知 bundle: ${bundle}" >&2
      print_bundle_list >&2
      exit 1
      ;;
  esac
}

selected_skills=()
for bundle in "${bundles[@]}"; do
  append_bundle "${bundle}"
done

deduped_skills=()
for skill in "${selected_skills[@]-}"; do
  skip=0
  for seen in "${deduped_skills[@]-}"; do
    if [[ "${seen}" == "${skill}" ]]; then
      skip=1
      break
    fi
  done
  if [[ "${skip}" -eq 0 ]]; then
    deduped_skills+=("${skill}")
  fi
done

selected_names=()
for skill in "${deduped_skills[@]-}"; do
  selected_names+=("$(basename "${skill}")")
done

for skill_name in "${managed_skill_names[@]}"; do
  target_path="${TARGET_DIR}/${skill_name}"
  keep=0
  for selected_name in "${selected_names[@]-}"; do
    if [[ "${selected_name}" == "${skill_name}" ]]; then
      keep=1
      break
    fi
  done
  if [[ "${keep}" -eq 0 && -L "${target_path}" ]]; then
    current_target="$(readlink "${target_path}" || true)"
    if [[ "${current_target}" == "${SOURCE_DIR}/"* ]]; then
      rm -f "${target_path}"
      echo "removed stale managed link ${skill_name}"
    fi
  fi
done

for skill_name in "${retired_skill_names[@]}"; do
  target_path="${TARGET_DIR}/${skill_name}"
  if [[ -L "${target_path}" ]]; then
    current_target="$(readlink "${target_path}" || true)"
    if [[ "${current_target}" == "${SOURCE_DIR}/"* ]]; then
      rm -f "${target_path}"
      echo "removed retired managed link ${skill_name}"
    fi
  fi
done

for skill in "${deduped_skills[@]-}"; do
  link_skill "${skill}"
done

echo "完成。目标目录: ${TARGET_DIR}"
echo "已安装 bundles: ${bundles[*]}"
