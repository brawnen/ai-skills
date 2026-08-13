#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBLISH_SCRIPT="${ROOT_DIR}/scripts/publish-skills.sh"
EXPECTED_PROJECT_SOURCE="${ROOT_DIR}/project/specialists/design-product-ui"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

resolve_dir() {
  (
    cd "$1"
    pwd -P
  )
}

test_root="$(mktemp -d "${TMPDIR:-/tmp}/ai-skills-publish-test.XXXXXX")"
trap 'rm -rf -- "${test_root}"' EXIT

[[ -x "${PUBLISH_SCRIPT}" ]] || fail "缺少可执行发布脚本 ${PUBLISH_SCRIPT}"
[[ -f "${EXPECTED_PROJECT_SOURCE}/SKILL.md" ]] || fail "项目级 skill 不在规范源码目录"
"${PUBLISH_SCRIPT}" list | grep -Fq 'design-product-ui' || fail "catalog 未列出项目级 skill"

project_dir="${test_root}/sample-project"
mkdir -p "${project_dir}"
"${PUBLISH_SCRIPT}" project --project "${project_dir}" --skills design-product-ui >/dev/null

project_link="${project_dir}/.agents/skills/design-product-ui"
[[ -L "${project_link}" ]] || fail "项目发布结果不是符号链接"
[[ "$(resolve_dir "${project_link}")" == "$(resolve_dir "${EXPECTED_PROJECT_SOURCE}")" ]] || \
  fail "项目符号链接没有指向规范源码"

"${PUBLISH_SCRIPT}" project --check --project "${project_dir}" --skills design-product-ui >/dev/null

conflict_project="${test_root}/conflict-project"
mkdir -p "${conflict_project}/.agents/skills/design-product-ui"
if "${PUBLISH_SCRIPT}" project --project "${conflict_project}" --skills design-product-ui >/dev/null 2>&1; then
  fail "发布脚本覆盖了已有实体目录"
fi
[[ -d "${conflict_project}/.agents/skills/design-product-ui" ]] || fail "冲突目录被破坏"

global_target="${test_root}/global-skills"
mkdir -p "${global_target}"
ln -s "${ROOT_DIR}/global/specialists/requirements-clarification" \
  "${global_target}/requirements-clarification"
"${PUBLISH_SCRIPT}" global --target "${global_target}" --bundles core >/dev/null
for skill_name in decision-clarification systematic-debugging test-first-development db-change-safety; do
  [[ -L "${global_target}/${skill_name}" ]] || fail "core 缺少 ${skill_name} 符号链接"
done
[[ ! -L "${global_target}/requirements-clarification" ]] || fail "未清理已退役的 requirements-clarification"
"${PUBLISH_SCRIPT}" global --check --target "${global_target}" --bundles core >/dev/null

legacy_target="${test_root}/legacy-global-skills"
"${ROOT_DIR}/scripts/install-links.sh" "${legacy_target}" core architecture >/dev/null
[[ -L "${legacy_target}/architecture-friction-scan" ]] || fail "旧 install-links 入口未转交新发布器"

echo "publish-skills tests passed"
