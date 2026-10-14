#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILL_CATALOG="${SKILL_CATALOG:-${ROOT_DIR}/config/skills.tsv}"
TARGET_CATALOG="${TARGET_CATALOG:-${ROOT_DIR}/config/publish-targets.tsv}"
RULE_SOURCE="${GLOBAL_RULE_SOURCE:-${CODEX_RULE_SOURCE:-${ROOT_DIR}/rules/AGENTS.md}}"

usage() {
  cat <<'EOF'
用法:
  ./scripts/publish-skills.sh list
  ./scripts/publish-skills.sh global [--platforms codex,antigravity] [--bundles core]
  ./scripts/publish-skills.sh global --target <skills-dir> [--bundles core,architecture]
  ./scripts/publish-skills.sh project --project <repo> --skills design
  ./scripts/publish-skills.sh <global|project> --check [其他选项]

说明:
  - skills 源码由 config/skills.tsv 声明，发布结果始终为符号链接。
  - 全局平台落点由 config/publish-targets.tsv 声明。
  - 项目级 skill 默认链接到目标项目的 .agents/skills。
  - --target 仅发布 skills，不同步全局规则文件。
  - 已有实体文件或其他来源的符号链接不会被覆盖。
EOF
}

die() {
  echo "$*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || die "缺失文件: $1"
}

csv_contains() {
  local csv="$1"
  local needle="$2"
  local item=""
  local values=()
  IFS=',' read -r -a values <<< "${csv}"
  for item in "${values[@]}"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done
  return 1
}

array_contains() {
  local needle="$1"
  shift
  local item=""
  for item in "$@"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done
  return 1
}

expand_config_path() {
  local path="$1"
  case "${path}" in
    '$HOME') printf '%s\n' "${HOME}" ;;
    '$HOME/'*) printf '%s/%s\n' "${HOME}" "${path#\$HOME/}" ;;
    *) printf '%s\n' "${path}" ;;
  esac
}

resolve_dir() {
  (
    cd "$1" >/dev/null 2>&1
    pwd -P
  )
}

validate_skill_source() {
  local name="$1"
  local source="$2"
  [[ -d "${source}" ]] || die "skill 源目录不存在: ${source}"
  [[ -f "${source}/SKILL.md" ]] || die "skill 缺少 SKILL.md: ${source}"
  [[ "$(basename "${source}")" == "${name}" ]] || \
    die "skill 名称与目录不一致: ${name} -> ${source}"
}

selected_names=()
selected_sources=()
selected_dependencies=()
retired_names=()

append_dependency_skill() {
  local dependency_name="$1"
  local expected_scope="$2"
  local name=""
  local row_scope=""
  local relative_source=""
  local bundles=""
  local status=""
  local dependencies=""

  while IFS='|' read -r name row_scope relative_source bundles status dependencies; do
    [[ -z "${name}" || "${name}" == \#* || "${name}" != "${dependency_name}" ]] && continue
    [[ "${status}" == "active" ]] || die "依赖 skill 未启用: ${dependency_name}"
    [[ "${row_scope}" == "${expected_scope}" ]] || \
      die "依赖 skill scope 不一致: ${dependency_name} (${row_scope})"
    case "${row_scope}:${relative_source}" in
      global:global/*|global:vendor/global-skills/*|project:project/*|project:vendor/project-skills/*) ;;
      *) die "skill 源码目录与 scope 不一致: ${name} -> ${relative_source}" ;;
    esac
    local source="${ROOT_DIR}/${relative_source}"
    validate_skill_source "${name}" "${source}"
    selected_names+=("${name}")
    selected_sources+=("${source}")
    selected_dependencies+=("${dependencies:--}")
    return 0
  done < "${SKILL_CATALOG}"

  die "依赖 skill 不存在: ${dependency_name}"
}

expand_dependencies() {
  local scope="$1"
  local index=0
  local dependency_csv=""
  local dependency_name=""
  local dependency_names=()

  while [[ "${index}" -lt "${#selected_names[@]}" ]]; do
    dependency_csv="${selected_dependencies[index]:--}"
    if [[ -n "${dependency_csv}" && "${dependency_csv}" != "-" ]]; then
      dependency_names=()
      IFS=',' read -r -a dependency_names <<< "${dependency_csv}"
      for dependency_name in "${dependency_names[@]}"; do
        [[ -n "${dependency_name}" ]] || die "skill 依赖名称不能为空: ${selected_names[index]}"
        if ! array_contains "${dependency_name}" "${selected_names[@]}"; then
          append_dependency_skill "${dependency_name}" "${scope}"
        fi
      done
    fi
    index=$((index + 1))
  done
}

load_selection() {
  local scope="$1"
  local selector="$2"
  local name=""
  local row_scope=""
  local relative_source=""
  local bundles=""
  local status=""
  local dependencies=""
  local matched="0"

  selected_names=()
  selected_sources=()
  selected_dependencies=()
  retired_names=()

  while IFS='|' read -r name row_scope relative_source bundles status dependencies; do
    [[ -z "${name}" || "${name}" == \#* ]] && continue
    [[ "${row_scope}" == "${scope}" ]] || continue

    if [[ "${status}" == "retired" ]]; then
      retired_names+=("${name}")
      continue
    fi
    [[ "${status}" == "active" ]] || die "未知 skill 状态: ${name} (${status})"
    case "${row_scope}:${relative_source}" in
      global:global/*|global:vendor/global-skills/*|project:project/*|project:vendor/project-skills/*) ;;
      *) die "skill 源码目录与 scope 不一致: ${name} -> ${relative_source}" ;;
    esac

    matched=0
    if [[ "${selector}" == "all" ]]; then
      matched=1
    elif [[ "${scope}" == "global" ]]; then
      local requested_bundle=""
      local requested_bundles=()
      IFS=',' read -r -a requested_bundles <<< "${selector}"
      for requested_bundle in "${requested_bundles[@]}"; do
        if csv_contains "${bundles}" "${requested_bundle}"; then
          matched=1
          break
        fi
      done
    elif csv_contains "${selector}" "${name}"; then
      matched=1
    fi

    if [[ "${matched}" -eq 1 ]]; then
      local source="${ROOT_DIR}/${relative_source}"
      validate_skill_source "${name}" "${source}"
      selected_names+=("${name}")
      selected_sources+=("${source}")
      selected_dependencies+=("${dependencies:--}")
    fi
  done < "${SKILL_CATALOG}"

  [[ "${#selected_names[@]}" -gt 0 ]] || die "没有匹配的 ${scope} skills: ${selector}"

  expand_dependencies "${scope}"

  if [[ "${scope}" == "project" && "${selector}" != "all" ]]; then
    local requested_name=""
    local requested_names=()
    IFS=',' read -r -a requested_names <<< "${selector}"
    for requested_name in "${requested_names[@]}"; do
      array_contains "${requested_name}" "${selected_names[@]}" || \
        die "未知或非项目级 skill: ${requested_name}"
    done
  fi
}

managed_link_belongs_here() {
  local link_path="$1"
  local link_target=""
  [[ -L "${link_path}" ]] || return 1
  link_target="$(readlink "${link_path}" || true)"
  [[ "${link_target}" == "${ROOT_DIR}/"* ]]
}

publish_link() {
  local name="$1"
  local source="$2"
  local target_dir="$3"
  local check_only="$4"
  local target_path="${target_dir}/${name}"

  if [[ "${check_only}" -eq 1 ]]; then
    [[ -L "${target_path}" ]] || die "缺失托管 skill 符号链接: ${target_path}"
    [[ "$(resolve_dir "${target_path}")" == "$(resolve_dir "${source}")" ]] || \
      die "skill 链接目标不一致: ${target_path}"
    echo "verified ${name} -> ${source}"
    return 0
  fi

  mkdir -p "${target_dir}"
  if [[ -e "${target_path}" || -L "${target_path}" ]]; then
    [[ -L "${target_path}" ]] || die "拒绝覆盖已有实体路径: ${target_path}"
    managed_link_belongs_here "${target_path}" || \
      die "拒绝覆盖其他来源的符号链接: ${target_path}"
  fi

  ln -sfn "${source}" "${target_path}"
  echo "linked ${name} -> ${source}"
}

preflight_selected_links() {
  local target_dir="$1"
  local index=0
  local name=""
  local target_path=""

  for ((index=0; index<${#selected_names[@]}; index++)); do
    name="${selected_names[index]}"
    target_path="${target_dir}/${name}"
    if [[ -e "${target_path}" || -L "${target_path}" ]]; then
      [[ -L "${target_path}" ]] || die "拒绝覆盖已有实体路径: ${target_path}"
      managed_link_belongs_here "${target_path}" || \
        die "拒绝覆盖其他来源的符号链接: ${target_path}"
    fi
  done
}

prune_global_links() {
  local target_dir="$1"
  local check_only="$2"
  local target_path=""
  local skill_name=""

  [[ -d "${target_dir}" ]] || {
    [[ "${check_only}" -eq 1 ]] && die "目标目录不存在: ${target_dir}"
    return 0
  }

  while IFS= read -r target_path; do
    managed_link_belongs_here "${target_path}" || continue
    skill_name="$(basename "${target_path}")"
    if array_contains "${skill_name}" "${selected_names[@]}"; then
      continue
    fi
    if [[ "${check_only}" -eq 1 ]]; then
      die "存在未选 bundle 的托管 skill: ${target_path}"
    fi
    rm -f -- "${target_path}"
    echo "removed stale managed link ${skill_name}"
  done < <(find "${target_dir}" -mindepth 1 -maxdepth 1 -type l -print | sort)
}

prune_retired_project_links() {
  local target_dir="$1"
  local check_only="$2"
  local name=""
  local target_path=""

  for name in "${retired_names[@]-}"; do
    [[ -n "${name}" ]] || continue
    target_path="${target_dir}/${name}"
    managed_link_belongs_here "${target_path}" || continue
    [[ "${check_only}" -eq 0 ]] || die "存在已退役的托管项目 skill: ${target_path}"
    rm -f -- "${target_path}"
    echo "removed retired project link ${name}"
  done
}

publish_selected_to() {
  local target_dir="$1"
  local check_only="$2"
  local scope="$3"
  local index=0

  if [[ "${check_only}" -eq 0 ]]; then
    preflight_selected_links "${target_dir}"
  fi

  if [[ "${scope}" == "global" ]]; then
    prune_global_links "${target_dir}" "${check_only}"
  else
    if [[ "${check_only}" -eq 1 && ! -d "${target_dir}" ]]; then
      die "目标目录不存在: ${target_dir}"
    fi
    prune_retired_project_links "${target_dir}" "${check_only}"
  fi

  for ((index=0; index<${#selected_names[@]}; index++)); do
    publish_link "${selected_names[index]}" "${selected_sources[index]}" \
      "${target_dir}" "${check_only}"
  done
}

operation_label() {
  if [[ "$1" -eq 1 ]]; then
    printf '%s\n' "检查"
  else
    printf '%s\n' "发布"
  fi
}

validate_rule_file() {
  local path="$1"
  require_file "${path}"
  [[ -s "${path}" ]] || die "规则文件为空: ${path}"
  local marker=""
  for marker in "# User Preferences" "## 沟通" "## 专项 Skill 路由" "## 文档偏好"; do
    grep -Fq "${marker}" "${path}" || die "规则文件缺少必要标记 '${marker}': ${path}"
  done
}

publish_rule() {
  local target="$1"
  local check_only="$2"
  validate_rule_file "${RULE_SOURCE}"

  if [[ "${check_only}" -eq 1 ]]; then
    [[ -f "${target}" ]] || die "缺失规则文件: ${target}"
    cmp -s "${RULE_SOURCE}" "${target}" || die "规则文件不一致: ${target}"
    echo "verified rule ${target}"
    return 0
  fi

  local target_dir="$(dirname "${target}")"
  local backup_dir="${target_dir}/rule-backups"
  local timestamp="$(date '+%Y%m%d-%H%M%S')"
  local temp_file="${target}.tmp.$$"
  mkdir -p "${target_dir}"
  if [[ -s "${target}" ]] && ! cmp -s "${RULE_SOURCE}" "${target}"; then
    mkdir -p "${backup_dir}"
    cp "${target}" "${backup_dir}/$(basename "${target}").${timestamp}.bak"
    echo "backed up $(basename "${target}") -> ${backup_dir}"
  fi
  cp "${RULE_SOURCE}" "${temp_file}"
  cmp -s "${RULE_SOURCE}" "${temp_file}" || die "规则临时副本校验失败: ${target}"
  mv -f "${temp_file}" "${target}"
  echo "published rule ${target}"
}

find_target_row() {
  local platform="$1"
  local expected_scope="$2"
  local row_platform=""
  local row_scope=""
  local skills_target=""
  local rule_target=""
  while IFS='|' read -r row_platform row_scope skills_target rule_target; do
    [[ -z "${row_platform}" || "${row_platform}" == \#* ]] && continue
    if [[ "${row_platform}" == "${platform}" && "${row_scope}" == "${expected_scope}" ]]; then
      printf '%s|%s\n' "${skills_target}" "${rule_target}"
      return 0
    fi
  done < "${TARGET_CATALOG}"
  return 1
}

list_catalog() {
  printf '%-34s %-9s %-14s %-32s %s\n' "skill" "scope" "bundle" "dependencies" "source"
  local name="" scope="" source="" bundles="" status="" dependencies=""
  while IFS='|' read -r name scope source bundles status dependencies; do
    [[ -z "${name}" || "${name}" == \#* || "${status}" != "active" ]] && continue
    printf '%-34s %-9s %-14s %-32s %s\n' \
      "${name}" "${scope}" "${bundles}" "${dependencies:--}" "${source}"
  done < "${SKILL_CATALOG}"
}

require_file "${SKILL_CATALOG}"
require_file "${TARGET_CATALOG}"

mode="${1:-}"
[[ -n "${mode}" ]] || { usage; exit 1; }
shift

if [[ "${mode}" == "list" || "${mode}" == "--list" ]]; then
  list_catalog
  exit 0
fi
[[ "${mode}" == "global" || "${mode}" == "project" ]] || die "未知发布模式: ${mode}"

platforms="codex,antigravity"
bundles="core"
skills=""
project_dir=""
target_override=""
check_only=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --platforms) [[ "$#" -ge 2 ]] || die "--platforms 缺少值"; platforms="$2"; shift 2 ;;
    --platforms=*) platforms="${1#*=}"; shift ;;
    --bundles) [[ "$#" -ge 2 ]] || die "--bundles 缺少值"; bundles="$2"; shift 2 ;;
    --bundles=*) bundles="${1#*=}"; shift ;;
    --skills) [[ "$#" -ge 2 ]] || die "--skills 缺少值"; skills="$2"; shift 2 ;;
    --skills=*) skills="${1#*=}"; shift ;;
    --project) [[ "$#" -ge 2 ]] || die "--project 缺少值"; project_dir="$2"; shift 2 ;;
    --project=*) project_dir="${1#*=}"; shift ;;
    --target) [[ "$#" -ge 2 ]] || die "--target 缺少值"; target_override="$2"; shift 2 ;;
    --target=*) target_override="${1#*=}"; shift ;;
    --check|--deep-check) check_only=1; shift ;;
    --help) usage; exit 0 ;;
    *) die "未知选项: $1" ;;
  esac
done

if [[ "${mode}" == "project" ]]; then
  [[ -n "${project_dir}" ]] || die "project 模式必须提供 --project"
  [[ -d "${project_dir}" ]] || die "项目目录不存在: ${project_dir}"
  [[ -n "${skills}" ]] || die "project 模式必须提供 --skills"
  load_selection project "${skills}"

  if [[ -z "${target_override}" ]]; then
    target_row="$(find_target_row agents project)" || die "缺少 agents 项目发布目标配置"
    target_override="${target_row%%|*}"
  fi
  if [[ "${target_override}" != /* ]]; then
    target_override="${project_dir}/${target_override}"
  fi
  publish_selected_to "${target_override}" "${check_only}" project
  echo "项目 skills $(operation_label "${check_only}")完成: ${project_dir}"
  exit 0
fi

load_selection global "${bundles}"
if [[ -n "${target_override}" ]]; then
  publish_selected_to "${target_override}" "${check_only}" global
  echo "全局 skills $(operation_label "${check_only}")完成: ${target_override}"
  exit 0
fi

platform_values=()
IFS=',' read -r -a platform_values <<< "${platforms}"
for platform in "${platform_values[@]}"; do
  target_row="$(find_target_row "${platform}" global)" || die "未知全局平台: ${platform}"
  skills_target="$(expand_config_path "${target_row%%|*}")"
  rule_target="$(expand_config_path "${target_row#*|}")"
  case "${platform}" in
    codex)
      skills_target="${CODEX_SKILLS_DIR:-${skills_target}}"
      rule_target="${CODEX_RULE_TARGET:-${rule_target}}"
      ;;
    claude)
      skills_target="${CLAUDE_SKILLS_DIR:-${skills_target}}"
      rule_target="${CLAUDE_RULE_TARGET:-${rule_target}}"
      ;;
    gemini)
      skills_target="${GEMINI_SKILLS_DIR:-${skills_target}}"
      rule_target="${GEMINI_RULE_TARGET:-${rule_target}}"
      ;;
    antigravity)
      skills_target="${ANTIGRAVITY_SKILLS_DIR:-${skills_target}}"
      rule_target="${GEMINI_RULE_TARGET:-${rule_target}}"
      ;;
  esac
  publish_selected_to "${skills_target}" "${check_only}" global
  [[ "${rule_target}" == "-" ]] || publish_rule "${rule_target}" "${check_only}"
done

echo "全局发布完成。平台: ${platforms}; bundles: ${bundles}"
