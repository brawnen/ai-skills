#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/global"
DEFAULT_TARGET_DIR="${HOME}/.codex/skills"
EXTERNAL_SYSTEMATIC_DEBUGGING_DIR="${SYSTEMATIC_DEBUGGING_DIR:-${HOME}/.skillshub/superpower/skills/systematic-debugging}"

core_execution_skills=(
  "core/safe-editing"
  "workflows/task-todolist-execution"
  "core/task-report"
)

core_gate_skills=(
  "core/repo-intake-scan"
  "core/requirements-clarification"
  "core/test-first-development"
  "workflows/db-change-safety"
)

core_skills=(
  "${core_execution_skills[@]}"
  "${core_gate_skills[@]}"
)

specialist_frontend=(
  "workflows/frontend-project-flow"
)

specialist_docs=(
  "core/code-evidence-docs"
  "core/formal-html-docs"
)

specialist_incident=(
  "core/production-incident-hotfix"
  "core/project-release-scope-check"
  "core/codegraph-assisted-navigation"
  "core/architecture-friction-scan"
)

managed_skill_names=(
  "architecture-friction-scan"
  "code-evidence-docs"
  "codegraph-assisted-navigation"
  "db-change-safety"
  "frontend-project-flow"
  "formal-html-docs"
  "production-incident-hotfix"
  "project-release-scope-check"
  "repo-intake-scan"
  "requirements-clarification"
  "safe-editing"
  "task-report"
  "task-todolist-execution"
  "test-first-development"
)

retired_skill_names=(
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
  core        仓库内托管的默认 core（执行层 + 场景闸门层）
  frontend    前端交付流专项 skill
  docs        文档沉淀专项 skill（含 formal-html-docs）
  incident    生产事故 / 发布 / CodeGraph / 架构扫描专项 skill
  all         安装 core + 全部 specialist
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
    frontend)
      selected_skills+=("${specialist_frontend[@]}")
      ;;
    docs)
      selected_skills+=("${specialist_docs[@]}")
      ;;
    incident)
      selected_skills+=("${specialist_incident[@]}")
      ;;
    all)
      selected_skills+=(
        "${core_skills[@]}"
        "${specialist_frontend[@]}"
        "${specialist_docs[@]}"
        "${specialist_incident[@]}"
      )
      ;;
    *)
      echo "未知 bundle: ${bundle}" >&2
      print_bundle_list >&2
      exit 1
      ;;
  esac
}

bundle_selected() {
  local needle="$1"
  for bundle in "${bundles[@]-}"; do
    if [[ "${bundle}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

print_external_core_advice() {
  if ! bundle_selected "core" && ! bundle_selected "all"; then
    return 0
  fi

  if [[ -d "${EXTERNAL_SYSTEMATIC_DEBUGGING_DIR}" ]]; then
    echo "提示: 检测到外部 core 补充 skill systematic-debugging"
    echo "      如需常驻，请单独链接到 ${TARGET_DIR}/systematic-debugging"
    echo "      来源: ${EXTERNAL_SYSTEMATIC_DEBUGGING_DIR}"
  else
    echo "提示: 未检测到外部 core 补充 skill systematic-debugging"
    echo "      如后续恢复高频编码 / 排障工作，建议单独补装该 skill"
  fi
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
    rm -f "${target_path}"
    echo "removed retired link ${skill_name}"
  fi
done

for skill in "${deduped_skills[@]-}"; do
  link_skill "${skill}"
done

echo "完成。目标目录: ${TARGET_DIR}"
echo "已安装 bundles: ${bundles[*]}"
print_external_core_advice
