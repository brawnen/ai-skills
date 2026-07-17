#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

CODEX_RULE_SOURCE="${CODEX_RULE_SOURCE:-${HOME}/.codex/AGENTS.md}"
CLAUDE_RULE_TARGET="${CLAUDE_RULE_TARGET:-${HOME}/.claude/CLAUDE.md}"
GEMINI_RULE_TARGET="${GEMINI_RULE_TARGET:-${HOME}/.gemini/GEMINI.md}"

CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-${HOME}/.codex/skills}"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
GEMINI_SKILLS_DIR="${GEMINI_SKILLS_DIR:-${HOME}/.gemini/skills}"
ANTIGRAVITY_SKILLS_DIR="${ANTIGRAVITY_SKILLS_DIR:-${HOME}/.gemini/config/skills}"
ANTIGRAVITY_IDE_SKILLS_DIR="${ANTIGRAVITY_IDE_SKILLS_DIR:-${HOME}/.gemini/antigravity-ide/skills}"

SYSTEMATIC_DEBUGGING_SOURCE="${SYSTEMATIC_DEBUGGING_DIR:-${HOME}/.skillshub/superpower/skills/systematic-debugging}"
CODE_REVIEW_SOURCE="${CODE_REVIEW_DIR:-${HOME}/.skillshub/code-review}"
PDF_SOURCE="${PDF_SKILL_DIR:-${CODEX_SKILLS_DIR}/pdf}"
TASTE_SKILL_SOURCE="${TASTE_SKILL_DIR:-${CODEX_SKILLS_DIR}/taste-skill}"

DOC_BUNDLES=(core docs)
EXTERNAL_SKILLS=(
  "systematic-debugging:${SYSTEMATIC_DEBUGGING_SOURCE}"
  "code-review:${CODE_REVIEW_SOURCE}"
  "pdf:${PDF_SOURCE}"
  "taste-skill:${TASTE_SKILL_SOURCE}"
)

usage() {
  cat <<'EOF'
用法:
  ./scripts/sync-global-platforms.sh
  ./scripts/sync-global-platforms.sh --check
  ./scripts/sync-global-platforms.sh --deep-check

行为:
  1. 以 ~/.codex/AGENTS.md 为事实源，同步到 ~/.claude/CLAUDE.md 和 ~/.gemini/GEMINI.md
  2. 用 install-links.sh 把仓库托管的 core+docs skills 同步到:
     - ~/.claude/skills
     - ~/.gemini/skills
     - ~/.gemini/config/skills
     - ~/.gemini/antigravity-ide/skills
  3. 补齐外部 skills:
     - systematic-debugging
     - code-review
     - pdf
     - taste-skill

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
  mkdir -p "$(dirname "${target_file}")"
  cp "${source_file}" "${target_file}"
  echo "copied $(basename "${source_file}") -> ${target_file}"
}

sync_managed_skills() {
  local target_dir="$1"
  "${SCRIPT_DIR}/install-links.sh" "${target_dir}" "${DOC_BUNDLES[@]}"
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

verify_target_matches_codex() {
  local target_dir="$1"
  if ! diff -u <(ls -1 "${CODEX_SKILLS_DIR}" | sort) <(ls -1 "${target_dir}" | sort) >/dev/null; then
    echo "skills 集合不一致: ${target_dir}" >&2
    diff -u <(ls -1 "${CODEX_SKILLS_DIR}" | sort) <(ls -1 "${target_dir}" | sort) || true
    exit 1
  fi
  echo "verified skill set matches codex: ${target_dir}"
}

verify_rule_file_matches_codex() {
  local target_file="$1"
  if ! cmp -s "${CODEX_RULE_SOURCE}" "${target_file}"; then
    echo "规则文件不一致: ${target_file}" >&2
    diff -u "${CODEX_RULE_SOURCE}" "${target_file}" || true
    exit 1
  fi
  echo "verified rule file matches codex: ${target_file}"
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
  require_file "${CLAUDE_RULE_TARGET}"
  require_file "${GEMINI_RULE_TARGET}"

  verify_rule_file_matches_codex "${CLAUDE_RULE_TARGET}"
  verify_rule_file_matches_codex "${GEMINI_RULE_TARGET}"

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

require_file "${CODEX_RULE_SOURCE}"
require_dir "${CODEX_SKILLS_DIR}"

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

copy_rule_file "${CODEX_RULE_SOURCE}" "${CLAUDE_RULE_TARGET}"
copy_rule_file "${CODEX_RULE_SOURCE}" "${GEMINI_RULE_TARGET}"

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
