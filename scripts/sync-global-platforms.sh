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
ANTIGRAVITY_IDE_SKILLS_DIR="${ANTIGRAVITY_IDE_SKILLS_DIR:-${HOME}/.gemini/antigravity-ide/skills}"

SYSTEMATIC_DEBUGGING_SOURCE="${SYSTEMATIC_DEBUGGING_DIR:-${HOME}/.skillshub/superpower/skills/systematic-debugging}"
IMPECCABLE_SOURCE="${IMPECCABLE_DIR:-${HOME}/.agents/skills/impeccable}"

SYNC_BUNDLES=(core)
CODEX_EXTERNAL_SKILLS=(
  "impeccable:${IMPECCABLE_SOURCE}"
)
EXTERNAL_SKILLS=(
  "systematic-debugging:${SYSTEMATIC_DEBUGGING_SOURCE}"
  "impeccable:${IMPECCABLE_SOURCE}"
)

usage() {
  cat <<'EOF'
用法:
  ./scripts/sync-global-platforms.sh
  ./scripts/sync-global-platforms.sh --check
  ./scripts/sync-global-platforms.sh --deep-check

行为:
  1. 以仓库 rules/AGENTS.md 为事实源，同步到 Codex、Claude 和 Gemini 的用户级规则文件
  2. 用 install-links.sh 更新 Codex 的默认 core skills，并同步到:
     - ~/.claude/skills
     - ~/.gemini/skills
     - ~/.gemini/config/skills
     - ~/.gemini/antigravity-ide/skills
  3. 补齐外部 skills:
     - systematic-debugging
     - impeccable（默认设计 skill）

检查模式:
  --check 只做一致性检查,不写任何文件或目录。
  --deep-check 在 --check 基础上,额外检查每个 skill 的解析后目标路径是否与 Codex 一致。
EOF
}

require_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    echo "缺失文件: ${path}" >&2
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
  for marker in "# User Core Rules" "SKILL_ROUTING_START" "DOC_FORMAT_START" "CODEGRAPH_START"; do
    if ! grep -Fq "${marker}" "${path}"; then
      echo "规则文件缺少必要标记 '${marker}': ${path}" >&2
      exit 1
    fi
  done
}

require_dir() {
  local path="$1"
  if [[ ! -d "${path}" ]]; then
    echo "缺失目录: ${path}" >&2
    exit 1
  fi
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

sync_managed_skills() {
  local target_dir="$1"
  "${SCRIPT_DIR}/install-links.sh" "${target_dir}" "${SYNC_BUNDLES[@]}"
}

link_external_skills() {
  local target_dir="$1"
  mkdir -p "${target_dir}"

  local entry
  for entry in "${EXTERNAL_SKILLS[@]}"; do
    local skill_name="${entry%%:*}"
    local source_dir="${entry#*:}"
    require_dir "${source_dir}"
    ln -sfn "${source_dir}" "${target_dir}/${skill_name}"
    echo "linked external ${skill_name} -> ${source_dir}"
  done
}

link_codex_external_skills() {
  local entry
  for entry in "${CODEX_EXTERNAL_SKILLS[@]}"; do
    local skill_name="${entry%%:*}"
    local source_dir="${entry#*:}"
    require_dir "${source_dir}"
    ln -sfn "${source_dir}" "${CODEX_SKILLS_DIR}/${skill_name}"
    echo "linked codex external ${skill_name} -> ${source_dir}"
  done
}

verify_target_matches_codex() {
  local target_dir="$1"
  if ! diff -u <(ls -1 "${CODEX_SKILLS_DIR}" | sort) <(ls -1 "${target_dir}" | sort) >/dev/null; then
    echo "skills 集合不一致: ${target_dir}" >&2
    diff -u <(ls -1 "${CODEX_SKILLS_DIR}" | sort) <(ls -1 "${target_dir}" | sort) || true
    exit 1
  fi
  echo "verified skill set matches codex: ${target_dir}"
}

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

verify_skill_target_matches_codex() {
  local target_dir="$1"
  local skill_name="$2"
  local codex_skill_path="${CODEX_SKILLS_DIR}/${skill_name}"
  local target_skill_path="${target_dir}/${skill_name}"

  if [[ ! -e "${target_skill_path}" ]]; then
    echo "缺失 skill: ${target_skill_path}" >&2
    exit 1
  fi

  local codex_resolved
  local target_resolved
  codex_resolved="$(resolve_dir_path "${codex_skill_path}")"
  target_resolved="$(resolve_dir_path "${target_skill_path}")"

  if [[ "${codex_resolved}" != "${target_resolved}" ]]; then
    echo "skill 目标路径不一致: ${target_skill_path}" >&2
    echo "  codex:  ${codex_resolved}" >&2
    echo "  target: ${target_resolved}" >&2
    exit 1
  fi
}

verify_target_deep_matches_codex() {
  local target_dir="$1"
  verify_target_matches_codex "${target_dir}"

  local skill_name=""
  while IFS= read -r skill_name; do
    verify_skill_target_matches_codex "${target_dir}" "${skill_name}"
  done < <(ls -1 "${CODEX_SKILLS_DIR}" | sort)

  echo "verified deep skill targets match codex: ${target_dir}"
}

run_check_mode() {
  local deep_mode="${1:-0}"
  validate_rule_file "${GLOBAL_RULE_SOURCE}"

  local rule_target=""
  for rule_target in "${rule_targets[@]}"; do
    verify_rule_file_matches_source "${rule_target}"
  done

  local target_dir=""
  for target_dir in "${targets[@]}"; do
    require_dir "${target_dir}"
    if [[ "${deep_mode}" == "1" ]]; then
      verify_target_deep_matches_codex "${target_dir}"
    else
      verify_target_matches_codex "${target_dir}"
    fi
  done

  if [[ -L "${HOME}/.gemini/antigravity/skills" ]]; then
    echo "antigravity runtime skills -> $(readlink "${HOME}/.gemini/antigravity/skills")"
  fi

  echo "检查通过。"
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

validate_rule_file "${GLOBAL_RULE_SOURCE}"
require_dir "${CODEX_SKILLS_DIR}"

rule_targets=(
  "${CODEX_RULE_TARGET}"
  "${CLAUDE_RULE_TARGET}"
  "${GEMINI_RULE_TARGET}"
)

targets=(
  "${CLAUDE_SKILLS_DIR}"
  "${GEMINI_SKILLS_DIR}"
  "${ANTIGRAVITY_SKILLS_DIR}"
  "${ANTIGRAVITY_IDE_SKILLS_DIR}"
)

if [[ "${1:-}" == "--check" ]]; then
  run_check_mode 0
  exit 0
fi

if [[ "${1:-}" == "--deep-check" ]]; then
  run_check_mode 1
  exit 0
fi

rule_target=""
for rule_target in "${rule_targets[@]}"; do
  copy_rule_file "${GLOBAL_RULE_SOURCE}" "${rule_target}"
done

sync_managed_skills "${CODEX_SKILLS_DIR}"
link_codex_external_skills

target_dir=""
for target_dir in "${targets[@]}"; do
  sync_managed_skills "${target_dir}"
  link_external_skills "${target_dir}"
  verify_target_matches_codex "${target_dir}"
done

if [[ -L "${HOME}/.gemini/antigravity/skills" ]]; then
  echo "antigravity runtime skills -> $(readlink "${HOME}/.gemini/antigravity/skills")"
fi

echo "同步完成。"
