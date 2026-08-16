#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBLISH_SCRIPT="${ROOT_DIR}/scripts/publish-skills.sh"
EXPECTED_PROJECT_SOURCE="${ROOT_DIR}/project/specialists/design-product-ui"
EXPECTED_UIUX_SOURCE="${ROOT_DIR}/vendor/project-skills/ui-ux-pro-max"
EXPECTED_IMPECCABLE_SOURCE="${ROOT_DIR}/vendor/project-skills/impeccable"

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
catalog_output="$("${PUBLISH_SCRIPT}" list)"
grep -Fq 'design-product-ui' <<< "${catalog_output}" || fail "catalog 未列出项目级 skill"

project_dir="${test_root}/sample-project"
mkdir -p "${project_dir}"
"${PUBLISH_SCRIPT}" project --project "${project_dir}" --skills design-product-ui >/dev/null

for skill_name in design-product-ui ui-ux-pro-max impeccable; do
  case "${skill_name}" in
    design-product-ui) expected_source="${EXPECTED_PROJECT_SOURCE}" ;;
    ui-ux-pro-max) expected_source="${EXPECTED_UIUX_SOURCE}" ;;
    impeccable) expected_source="${EXPECTED_IMPECCABLE_SOURCE}" ;;
  esac
  project_link="${project_dir}/.agents/skills/${skill_name}"
  [[ -L "${project_link}" ]] || fail "项目发布缺少 ${skill_name} 符号链接"
  [[ "$(resolve_dir "${project_link}")" == "$(resolve_dir "${expected_source}")" ]] || \
    fail "${skill_name} 符号链接没有指向规范源码"
done

"${PUBLISH_SCRIPT}" project --check --project "${project_dir}" --skills design-product-ui >/dev/null

dependency_conflict_project="${test_root}/dependency-conflict-project"
mkdir -p "${dependency_conflict_project}/.agents/skills/ui-ux-pro-max"
if "${PUBLISH_SCRIPT}" project --project "${dependency_conflict_project}" \
  --skills design-product-ui >/dev/null 2>&1; then
  fail "发布脚本忽略了依赖 skill 的实体目录冲突"
fi
[[ -d "${dependency_conflict_project}/.agents/skills/ui-ux-pro-max" ]] || \
  fail "依赖冲突目录被破坏"
[[ ! -e "${dependency_conflict_project}/.agents/skills/design-product-ui" ]] || \
  fail "依赖冲突时留下了部分 design-product-ui 发布结果"
[[ ! -e "${dependency_conflict_project}/.agents/skills/impeccable" ]] || \
  fail "依赖冲突时留下了部分 impeccable 发布结果"

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
