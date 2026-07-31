#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/global"
DEFAULT_TARGET_DIR="${HOME}/.codex/skills"
EXTERNAL_SYSTEMATIC_DEBUGGING_DIR="${SYSTEMATIC_DEBUGGING_DIR:-${HOME}/.skillshub/superpower/skills/systematic-debugging}"

workflow_core_skills=(
  "workflows/task-todolist-execution"
)

global_specialist_skills=(
  "specialists/repo-intake-scan"
  "specialists/requirements-clarification"
  "specialists/safe-editing"
  "specialists/test-first-development"
  "specialists/db-change-safety"
  "specialists/code-evidence-docs"
  "specialists/production-incident-hotfix"
  "specialists/project-release-scope-check"
)

global_helper_skills=(
  "helpers/formal-html-docs"
)

core_skills=(
  "${workflow_core_skills[@]}"
  "${global_specialist_skills[@]}"
  "${global_helper_skills[@]}"
)

optional_frontend_workflows=(
  "workflows/frontend-project-flow"
)

optional_architecture_skills=(
  "specialists/architecture-friction-scan"
  "helpers/codegraph-assisted-navigation"
)

optional_tool_helpers=(
  "helpers/doc-converter"
)

compat_docs=(
  "specialists/code-evidence-docs"
  "helpers/formal-html-docs"
)

compat_incident=(
  "specialists/production-incident-hotfix"
  "specialists/project-release-scope-check"
)

managed_skill_names=(
  "architecture-friction-scan"
  "code-evidence-docs"
  "codegraph-assisted-navigation"
  "db-change-safety"
  "doc-converter"
  "frontend-project-flow"
  "formal-html-docs"
  "production-incident-hotfix"
  "project-release-scope-check"
  "repo-intake-scan"
  "requirements-clarification"
  "safe-editing"
  "task-todolist-execution"
  "test-first-development"
)

retired_skill_names=(
  "code-review"
  "pdf"
  "taste-skill"
  "task-report"
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
  core          默认全局集合（通用流程 + 自动触发专项 + 内部 helper）
  frontend      可选的完整前端交付流程
  architecture  可选的架构扫描与 CodeGraph 辅助
  tools         可选的本机文档转换 helper
  docs          兼容别名：代码证据文档 + formal-html-docs（已包含在 core）
  incident      兼容别名：生产事故 + 发布核对（已包含在 core）
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
    frontend)
      selected_skills+=("${optional_frontend_workflows[@]}")
      ;;
    architecture)
      selected_skills+=("${optional_architecture_skills[@]}")
      ;;
    tools)
      selected_skills+=("${optional_tool_helpers[@]}")
      ;;
    docs)
      selected_skills+=("${compat_docs[@]}")
      ;;
    incident)
      selected_skills+=("${compat_incident[@]}")
      ;;
    all)
      selected_skills+=(
        "${core_skills[@]}"
        "${optional_frontend_workflows[@]}"
        "${optional_architecture_skills[@]}"
        "${optional_tool_helpers[@]}"
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
