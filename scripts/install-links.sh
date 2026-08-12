#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${1:-}" == "--list" ]]; then
  exec "${SCRIPT_DIR}/publish-skills.sh" list
fi

target="${HOME}/.codex/skills"
if [[ "${1:-}" == /* || "${1:-}" == "~/"* ]]; then
  target="${1/#\~/${HOME}}"
  shift
fi

if [[ "$#" -eq 0 ]]; then
  bundles="core"
else
  bundles="$(IFS=','; echo "$*")"
fi

exec "${SCRIPT_DIR}/publish-skills.sh" global --target "${target}" --bundles "${bundles}"
