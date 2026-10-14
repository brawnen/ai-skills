#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBLISH_SCRIPT="${ROOT_DIR}/scripts/publish-skills.sh"
EXPECTED_PROJECT_SOURCE="${ROOT_DIR}/project/specialists/design"
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
grep -Fq 'design' <<< "${catalog_output}" || fail "catalog 未列出项目级 skill"

project_dir="${test_root}/sample-project"
mkdir -p "${project_dir}"
"${PUBLISH_SCRIPT}" project --project "${project_dir}" --skills design >/dev/null

for skill_name in design ui-ux-pro-max impeccable; do
  case "${skill_name}" in
    design) expected_source="${EXPECTED_PROJECT_SOURCE}" ;;
    ui-ux-pro-max) expected_source="${EXPECTED_UIUX_SOURCE}" ;;
    impeccable) expected_source="${EXPECTED_IMPECCABLE_SOURCE}" ;;
  esac
  project_link="${project_dir}/.agents/skills/${skill_name}"
  [[ -L "${project_link}" ]] || fail "项目发布缺少 ${skill_name} 符号链接"
  [[ "$(resolve_dir "${project_link}")" == "$(resolve_dir "${expected_source}")" ]] || \
    fail "${skill_name} 符号链接没有指向规范源码"
done

"${PUBLISH_SCRIPT}" project --check --project "${project_dir}" --skills design >/dev/null

dependency_conflict_project="${test_root}/dependency-conflict-project"
mkdir -p "${dependency_conflict_project}/.agents/skills/ui-ux-pro-max"
if "${PUBLISH_SCRIPT}" project --project "${dependency_conflict_project}" \
  --skills design >/dev/null 2>&1; then
  fail "发布脚本忽略了依赖 skill 的实体目录冲突"
fi
[[ -d "${dependency_conflict_project}/.agents/skills/ui-ux-pro-max" ]] || \
  fail "依赖冲突目录被破坏"
[[ ! -e "${dependency_conflict_project}/.agents/skills/design" ]] || \
  fail "依赖冲突时留下了部分 design 发布结果"
[[ ! -e "${dependency_conflict_project}/.agents/skills/impeccable" ]] || \
  fail "依赖冲突时留下了部分 impeccable 发布结果"

conflict_project="${test_root}/conflict-project"
mkdir -p "${conflict_project}/.agents/skills/design"
if "${PUBLISH_SCRIPT}" project --project "${conflict_project}" --skills design >/dev/null 2>&1; then
  fail "发布脚本覆盖了已有实体目录"
fi
[[ -d "${conflict_project}/.agents/skills/design" ]] || fail "冲突目录被破坏"

global_target="${test_root}/global-skills"
mkdir -p "${global_target}"
ln -s "${ROOT_DIR}/global/specialists/requirements-clarification" \
  "${global_target}/requirements-clarification"
"${PUBLISH_SCRIPT}" global --target "${global_target}" --bundles core >/dev/null
for skill_name in to-decision debug tdd review-db; do
  [[ -L "${global_target}/${skill_name}" ]] || fail "core 缺少 ${skill_name} 符号链接"
done
[[ ! -L "${global_target}/requirements-clarification" ]] || fail "未清理已退役的 requirements-clarification"
"${PUBLISH_SCRIPT}" global --check --target "${global_target}" --bundles core >/dev/null

retired_target="${test_root}/retired-skills"
mkdir -p "${retired_target}"
ln -s "${ROOT_DIR}/global/helpers/codegraph-assisted-navigation" \
  "${retired_target}/codegraph-assisted-navigation"
"${PUBLISH_SCRIPT}" global --target "${retired_target}" --bundles core,architecture,docs >/dev/null
[[ ! -L "${retired_target}/codegraph-assisted-navigation" ]] || fail "未清理已退役的 CodeGraph 受管链接"
"${PUBLISH_SCRIPT}" global --check --target "${retired_target}" --bundles core,architecture,docs >/dev/null

# 退役清理不能删除同名的外部链接或实体目录。
for foreign_kind in link directory; do
  foreign_target="${test_root}/foreign-${foreign_kind}"
  mkdir -p "${foreign_target}"
  if [[ "${foreign_kind}" == link ]]; then
    ln -s "${test_root}/external-codegraph" "${foreign_target}/codegraph-assisted-navigation"
  else
    mkdir -p "${foreign_target}/codegraph-assisted-navigation"
  fi
  "${PUBLISH_SCRIPT}" global --target "${foreign_target}" --bundles architecture >/dev/null
  if [[ "${foreign_kind}" == link ]]; then
    [[ "$(readlink "${foreign_target}/codegraph-assisted-navigation")" == "${test_root}/external-codegraph" ]] || fail "删除了外部链接"
  else
    [[ -d "${foreign_target}/codegraph-assisted-navigation" ]] || fail "删除了实体目录"
  fi
done

legacy_target="${test_root}/legacy-global-skills"
"${ROOT_DIR}/scripts/install-links.sh" "${legacy_target}" core architecture >/dev/null
[[ -L "${legacy_target}/scan-architecture" ]] || fail "旧 install-links 入口未转交新发布器"

trial_target="${test_root}/trial-skills"
"${PUBLISH_SCRIPT}" global --target "${trial_target}" --bundles core,architecture,docs,trial >/dev/null
[[ -L "${trial_target}/show-me" ]] || fail "未发布第三方试用 skill"
[[ "$(resolve_dir "${trial_target}/show-me")" == "$(resolve_dir "${ROOT_DIR}/vendor/global-skills/show-me")" ]] || fail "试用链接未指向项目快照"
"${PUBLISH_SCRIPT}" global --check --target "${trial_target}" --bundles core,architecture,docs,trial >/dev/null
[[ ! -e "${global_target}/show-me" ]] || fail "试用 skill 意外进入 core"

# 测试目标项目中已有非受管的自定义实体 skill (如 verify-my-app)，不被破坏且支持发布与 check
unmanaged_project="${test_root}/unmanaged-project"
mkdir -p "${unmanaged_project}/.agents/skills/verify-my-app"
touch "${unmanaged_project}/.agents/skills/verify-my-app/SKILL.md"
"${PUBLISH_SCRIPT}" project --project "${unmanaged_project}" --skills design >/dev/null
[[ -d "${unmanaged_project}/.agents/skills/verify-my-app" ]] || fail "非受管项目 skill 实体目录被破坏"
[[ -L "${unmanaged_project}/.agents/skills/design" ]] || fail "受管项目 skill 符号链接未建立"
"${PUBLISH_SCRIPT}" project --check --project "${unmanaged_project}" --skills design >/dev/null

# 测试 flow bundle 正确发布与检查
flow_target="${test_root}/flow-skills"
"${PUBLISH_SCRIPT}" global --target "${flow_target}" --bundles flow >/dev/null
for skill_name in dev to-spec verify-change setup-verification; do
  [[ -L "${flow_target}/${skill_name}" ]] || fail "flow bundle 缺少 ${skill_name} 符号链接"
  [[ "$(resolve_dir "${flow_target}/${skill_name}")" == "$(resolve_dir "${ROOT_DIR}/global/specialists/${skill_name}")" ]] || \
    fail "${skill_name} 符号链接未指向规范源码"
done
"${PUBLISH_SCRIPT}" global --check --target "${flow_target}" --bundles flow >/dev/null

# 旧名称迁移必须清理失效的受管链接，同时保留非受管实体/外部链接。
rename_target="${test_root}/rename-global"
mkdir -p "${rename_target}"
ln -s "${ROOT_DIR}/global/specialists/decision-clarification" "${rename_target}/decision-clarification"
ln -s "${ROOT_DIR}/global/helpers/formal-html-docs" "${rename_target}/formal-html-docs"
"${PUBLISH_SCRIPT}" global --target "${rename_target}" --bundles core,architecture,docs,flow >/dev/null
[[ ! -L "${rename_target}/decision-clarification" && ! -L "${rename_target}/formal-html-docs" ]] || fail "全局改名未清理旧链接"
[[ -L "${rename_target}/to-decision" && -L "${rename_target}/to-html" ]] || fail "全局改名未发布新入口"
"${PUBLISH_SCRIPT}" global --check --target "${rename_target}" --bundles core,architecture,docs,flow >/dev/null

# 补齐其余建议名称：四个失效旧链接必须清理，strategy 仍按选择发布。
remaining_rename_target="${test_root}/remaining-renames"
mkdir -p "${remaining_rename_target}"
for old_name in test-first-development verification-harness architecture-friction-scan venture-feasibility; do
  ln -s "${ROOT_DIR}/global/specialists/${old_name}" "${remaining_rename_target}/${old_name}"
done
"${PUBLISH_SCRIPT}" global --target "${remaining_rename_target}" --bundles core,architecture,flow,strategy >/dev/null
for old_name in test-first-development verification-harness architecture-friction-scan venture-feasibility; do
  [[ ! -L "${remaining_rename_target}/${old_name}" ]] || fail "补充改名未清理 ${old_name}"
done
for new_name in tdd setup-verification scan-architecture assess-venture; do
  [[ -L "${remaining_rename_target}/${new_name}" ]] || fail "补充改名未发布 ${new_name}"
done
"${PUBLISH_SCRIPT}" global --check --target "${remaining_rename_target}" --bundles core,architecture,flow,strategy >/dev/null

rename_project="${test_root}/rename-project"
mkdir -p "${rename_project}/.agents/skills"
ln -s "${ROOT_DIR}/project/specialists/design-product-ui" "${rename_project}/.agents/skills/design-product-ui"
if "${PUBLISH_SCRIPT}" project --check --project "${rename_project}" --skills design >/dev/null 2>&1; then
  fail "check 未发现退役项目链接"
fi
"${PUBLISH_SCRIPT}" project --project "${rename_project}" --skills design >/dev/null
[[ ! -L "${rename_project}/.agents/skills/design-product-ui" ]] || fail "项目改名未清理旧链接"
[[ -L "${rename_project}/.agents/skills/design" ]] || fail "项目改名未发布新入口"
"${PUBLISH_SCRIPT}" project --check --project "${rename_project}" --skills design >/dev/null

for foreign_kind in link directory; do
  foreign_project="${test_root}/foreign-retired-project-${foreign_kind}"
  mkdir -p "${foreign_project}/.agents/skills"
  if [[ "${foreign_kind}" == link ]]; then
    ln -s "${test_root}/outside" "${foreign_project}/.agents/skills/design-product-ui"
  else
    mkdir -p "${foreign_project}/.agents/skills/design-product-ui"
    touch "${foreign_project}/.agents/skills/design-product-ui/keep"
  fi
  "${PUBLISH_SCRIPT}" project --project "${foreign_project}" --skills design >/dev/null
  if [[ "${foreign_kind}" == link ]]; then
    [[ "$(readlink "${foreign_project}/.agents/skills/design-product-ui")" == "${test_root}/outside" ]] || fail "删除了外部退役链接"
  else
    [[ -f "${foreign_project}/.agents/skills/design-product-ui/keep" ]] || fail "删除了非受管实体"
  fi
  "${PUBLISH_SCRIPT}" project --check --project "${foreign_project}" --skills design >/dev/null
 done

# 新名称冲突时不能先清理旧入口，避免留下部分迁移。
partial_project="${test_root}/partial-rename"
mkdir -p "${partial_project}/.agents/skills/design"
ln -s "${ROOT_DIR}/project/specialists/design-product-ui" "${partial_project}/.agents/skills/design-product-ui"
if "${PUBLISH_SCRIPT}" project --project "${partial_project}" --skills design >/dev/null 2>&1; then
  fail "改名覆盖了实体"
fi
[[ -L "${partial_project}/.agents/skills/design-product-ui" ]] || fail "冲突前清理了旧入口"
[[ ! -L "${partial_project}/.agents/skills/impeccable" ]] || fail "冲突留下了部分依赖"

echo "publish-skills tests passed"
