#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/global"
TARGET_DIR="${1:-${HOME}/.codex/skills/local}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "未找到全局 skills 目录: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}"

link_skill() {
  local skill_path="$1"
  local skill_name
  skill_name="$(basename "${skill_path}")"
  ln -sfn "${skill_path}" "${TARGET_DIR}/${skill_name}"
  echo "linked ${skill_name} -> ${skill_path}"
}

link_skill "${SOURCE_DIR}/core/safe-editing"
link_skill "${SOURCE_DIR}/core/validation-required"
link_skill "${SOURCE_DIR}/core/task-report"
link_skill "${SOURCE_DIR}/workflows/legacy-safe-mode"
link_skill "${SOURCE_DIR}/workflows/db-change-safety"

echo "完成。目标目录: ${TARGET_DIR}"
