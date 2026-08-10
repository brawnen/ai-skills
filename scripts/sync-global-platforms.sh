#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

GLOBAL_RULE_SOURCE="${GLOBAL_RULE_SOURCE:-${CODEX_RULE_SOURCE:-${ROOT_DIR}/rules/AGENTS.md}}"
CODEX_RULE_TARGET="${CODEX_RULE_TARGET:-${HOME}/.codex/AGENTS.md}"
CLAUDE_RULE_TARGET="${CLAUDE_RULE_TARGET:-${HOME}/.claude/CLAUDE.md}"
GEMINI_RULE_TARGET="${GEMINI_RULE_TARGET:-${HOME}/.gemini/GEMINI.md}"
RULE_BACKUP_TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"

CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-${HOME}/.codex/skills}"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
GEMINI_SKILLS_DIR="${GEMINI_SKILLS_DIR:-${HOME}/.gemini/skills}"
ANTIGRAVITY_SKILLS_DIR="${ANTIGRAVITY_SKILLS_DIR:-${HOME}/.gemini/config/skills}"

platforms=(codex antigravity)
bundles=(core)
check_mode=0
deep_mode=0
expected_dir=""

usage() {
  cat <<'EOF'
用法:
  ./scripts/sync-global-platforms.sh [--platforms codex,antigravity] [--bundles core|all]
  ./scripts/sync-global-platforms.sh --check [其他选项]
  ./scripts/sync-global-platforms.sh --deep-check [其他选项]

默认行为:
  - 同步平台: Codex、Antigravity
  - 同步 bundle: core
  - 规则事实源: rules/AGENTS.md
  - Codex 规则: ~/.codex/AGENTS.md
  - Codex skills: ~/.codex/skills
  - Antigravity 全局规则: ~/.gemini/GEMINI.md
  - Antigravity 全局 skills: ~/.gemini/config/skills

选项:
  --platforms LIST  逗号分隔的平台: codex, claude, gemini, antigravity
  --bundles LIST    逗号分隔的 install-links bundle: core, architecture, docs, all
  --check           只检查规则和本仓库托管的 skill 链接
  --deep-check      额外检查每个 skill 的解析后目标路径
  --help            显示帮助

说明:
  Antigravity 与 Gemini CLI 共用 ~/.gemini/GEMINI.md；选择 antigravity 时不会写
  ~/.gemini/skills，但全局规则文件会被两者共同读取。
EOF
}

require_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    echo "缺失文件: ${path}" >&2
    exit 1
  fi
}

require_dir() {
  local path="$1"
  if [[ ! -d "${path}" ]]; then
    echo "缺失目录: ${path}" >&2
    exit 1
  fi
}

validate_rule_file() {
  local path="$1"
  require_file "${path}"

  if [[ ! -s "${path}" ]]; then
    echo "规则文件为空: ${path}" >&2
    exit 1
  fi

  local marker=""
  for marker in "# User Preferences" "## 沟通" "## 专项 Skill 路由" "## 文档偏好"; do
    if ! grep -Fq "${marker}" "${path}"; then
      echo "规则文件缺少必要标记 '${marker}': ${path}" >&2
      exit 1
    fi
  done
}

copy_rule_file() {
  local source_file="$1"
  local target_file="$2"
  local target_dir
  local backup_dir
  local temp_file

  validate_rule_file "${source_file}"
  target_dir="$(dirname "${target_file}")"
  backup_dir="${target_dir}/rule-backups"
  temp_file="${target_file}.tmp.$$"

  mkdir -p "${target_dir}"
  if [[ -s "${target_file}" ]] && ! cmp -s "${source_file}" "${target_file}"; then
    mkdir -p "${backup_dir}"
    cp "${target_file}" "${backup_dir}/$(basename "${target_file}").${RULE_BACKUP_TIMESTAMP}.bak"
    echo "backed up $(basename "${target_file}") -> ${backup_dir}"
  fi

  cp "${source_file}" "${temp_file}"
  if ! cmp -s "${source_file}" "${temp_file}"; then
    rm -f "${temp_file}"
    echo "规则文件临时副本校验失败: ${target_file}" >&2
    exit 1
  fi

  mv -f "${temp_file}" "${target_file}"
  validate_rule_file "${target_file}"
  if ! cmp -s "${source_file}" "${target_file}"; then
    echo "规则文件写后校验失败: ${target_file}" >&2
    exit 1
  fi
  echo "copied $(basename "${source_file}") -> ${target_file}"
}

contains() {
  local needle="$1"
  shift
  local item=""
  for item in "$@"; do
    if [[ "${item}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

append_unique() {
  local array_name="$1"
  local value="$2"
  local item=""
  case "${array_name}" in
    rule_targets)
      for item in "${rule_targets[@]-}"; do
        [[ "${item}" == "${value}" ]] && return 0
      done
      rule_targets+=("${value}")
      ;;
    skill_targets)
      for item in "${skill_targets[@]-}"; do
        [[ "${item}" == "${value}" ]] && return 0
      done
      skill_targets+=("${value}")
      ;;
    *)
      echo "未知数组: ${array_name}" >&2
      exit 1
      ;;
  esac
}

parse_csv() {
  local value="$1"
  local array_name="$2"
  local parsed=()
  IFS=',' read -r -a parsed <<< "${value}"
  if [[ "${#parsed[@]}" -eq 0 ]]; then
    echo "空选项: ${array_name}" >&2
    exit 1
  fi
  case "${array_name}" in
    platforms) platforms=("${parsed[@]}") ;;
    bundles) bundles=("${parsed[@]}") ;;
    *)
      echo "未知数组: ${array_name}" >&2
      exit 1
      ;;
  esac
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --platforms)
      [[ "$#" -ge 2 ]] || { echo "--platforms 缺少值" >&2; exit 1; }
      parse_csv "$2" platforms
      shift 2
      ;;
    --platforms=*)
      parse_csv "${1#*=}" platforms
      shift
      ;;
    --bundles)
      [[ "$#" -ge 2 ]] || { echo "--bundles 缺少值" >&2; exit 1; }
      parse_csv "$2" bundles
      shift 2
      ;;
    --bundles=*)
      parse_csv "${1#*=}" bundles
      shift
      ;;
    --check)
      check_mode=1
      shift
      ;;
    --deep-check)
      check_mode=1
      deep_mode=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "未知选项: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

for platform in "${platforms[@]}"; do
  case "${platform}" in
    codex|claude|gemini|antigravity) ;;
    *)
      echo "未知平台: ${platform}" >&2
      exit 1
      ;;
  esac
done

validate_rule_file "${GLOBAL_RULE_SOURCE}"

rule_targets=()
skill_targets=()
for platform in "${platforms[@]}"; do
  case "${platform}" in
    codex)
      append_unique rule_targets "${CODEX_RULE_TARGET}"
      append_unique skill_targets "${CODEX_SKILLS_DIR}"
      ;;
    claude)
      append_unique rule_targets "${CLAUDE_RULE_TARGET}"
      append_unique skill_targets "${CLAUDE_SKILLS_DIR}"
      ;;
    gemini)
      append_unique rule_targets "${GEMINI_RULE_TARGET}"
      append_unique skill_targets "${GEMINI_SKILLS_DIR}"
      ;;
    antigravity)
      append_unique rule_targets "${GEMINI_RULE_TARGET}"
      append_unique skill_targets "${ANTIGRAVITY_SKILLS_DIR}"
      ;;
  esac
done

cleanup() {
  if [[ -n "${expected_dir}" && -d "${expected_dir}" ]]; then
    rm -rf -- "${expected_dir}"
  fi
}
trap cleanup EXIT

expected_dir="$(mktemp -d "${TMPDIR:-/tmp}/ai-skills-sync.XXXXXX")"
"${SCRIPT_DIR}/install-links.sh" "${expected_dir}" "${bundles[@]}" >/dev/null

verify_rule_file_matches_source() {
  local target_file="$1"
  validate_rule_file "${target_file}"
  if ! cmp -s "${GLOBAL_RULE_SOURCE}" "${target_file}"; then
    echo "规则文件不一致: ${target_file}" >&2
    diff -u "${GLOBAL_RULE_SOURCE}" "${target_file}" || true
    exit 1
  fi
  echo "verified rule file matches source: ${target_file}"
}

resolve_dir_path() {
  local path="$1"
  (
    cd "${path}" >/dev/null 2>&1
    pwd -P
  )
}

verify_managed_skills() {
  local target_dir="$1"
  local verify_resolved="$2"
  local expected_path=""
  local skill_name=""
  local target_path=""
  local link_target=""

  require_dir "${target_dir}"

  while IFS= read -r expected_path; do
    skill_name="$(basename "${expected_path}")"
    target_path="${target_dir}/${skill_name}"
    if [[ ! -e "${target_path}" ]]; then
      echo "缺失托管 skill: ${target_path}" >&2
      exit 1
    fi
    if [[ "${verify_resolved}" == "1" ]] && \
       [[ "$(resolve_dir_path "${expected_path}")" != "$(resolve_dir_path "${target_path}")" ]]; then
      echo "skill 解析后目标不一致: ${target_path}" >&2
      exit 1
    fi
  done < <(find "${expected_dir}" -mindepth 1 -maxdepth 1 -print | sort)

  while IFS= read -r target_path; do
    link_target="$(readlink "${target_path}" || true)"
    if [[ "${link_target}" != "${ROOT_DIR}/global/"* ]]; then
      continue
    fi
    skill_name="$(basename "${target_path}")"
    if [[ ! -e "${expected_dir}/${skill_name}" ]]; then
      echo "存在未选 bundle 的托管 skill: ${target_path}" >&2
      exit 1
    fi
  done < <(find "${target_dir}" -mindepth 1 -maxdepth 1 -type l -print | sort)

  if [[ "${verify_resolved}" == "1" ]]; then
    echo "verified deep managed skills: ${target_dir}"
  else
    echo "verified managed skills: ${target_dir}"
  fi
}

if [[ "${check_mode}" == "0" ]]; then
  for rule_target in "${rule_targets[@]}"; do
    copy_rule_file "${GLOBAL_RULE_SOURCE}" "${rule_target}"
  done

  for target_dir in "${skill_targets[@]}"; do
    "${SCRIPT_DIR}/install-links.sh" "${target_dir}" "${bundles[@]}"
  done
fi

for rule_target in "${rule_targets[@]}"; do
  verify_rule_file_matches_source "${rule_target}"
done

for target_dir in "${skill_targets[@]}"; do
  verify_managed_skills "${target_dir}" "${deep_mode}"
done

if [[ "${check_mode}" == "1" ]]; then
  echo "检查通过。平台: ${platforms[*]}; bundles: ${bundles[*]}"
else
  echo "同步完成。平台: ${platforms[*]}; bundles: ${bundles[*]}"
fi
