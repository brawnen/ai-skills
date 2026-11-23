#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

./scripts/doctor.sh
./tests/publish-skills-test.sh
./tests/formal-html-docs-test.sh
PYTHONDONTWRITEBYTECODE=1 python3 tests/workflow-contract-test.py "$@"
PYTHONDONTWRITEBYTECODE=1 python3 tests/verification-flow-test.py
bash -n scripts/publish-skills.sh scripts/install-links.sh \
  scripts/sync-global-platforms.sh scripts/doctor.sh scripts/check-workflow.sh \
  tests/publish-skills-test.sh tests/formal-html-docs-test.sh
git diff --check
