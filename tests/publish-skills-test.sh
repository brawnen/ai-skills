#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBLISH_SCRIPT="${ROOT_DIR}/scripts/publish-skills.sh"
EXPECTED_PROJECT_SOURCE="${ROOT_DIR}/project/specialists/x-ui"
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
grep -Fq 'x-ui' <<< "${catalog_output}" || fail "catalog 未列出项目级 skill x-ui"

project_dir="${test_root}/sample-project"
mkdir -p "${project_dir}"
"${PUBLISH_SCRIPT}" project --project "${project_dir}" --skills x-ui >/dev/null

for skill_name in x-ui ui-ux-pro-max impeccable; do
  case "${skill_name}" in
    x-ui) expected_source="${EXPECTED_PROJECT_SOURCE}" ;;
    ui-ux-pro-max) expected_source="${EXPECTED_UIUX_SOURCE}" ;;
    impeccable) expected_source="${EXPECTED_IMPECCABLE_SOURCE}" ;;
  esac
  project_link="${project_dir}/.agents/skills/${skill_name}"
  [[ -L "${project_link}" ]] || fail "项目发布缺少 ${skill_name} 符号链接"
  [[ "$(resolve_dir "${project_link}")" == "$(resolve_dir "${expected_source}")" ]] || \
    fail "${skill_name} 符号链接没有指向规范源码"
done

"${PUBLISH_SCRIPT}" project --check --project "${project_dir}" --skills x-ui >/dev/null

dependency_conflict_project="${test_root}/dependency-conflict-project"
mkdir -p "${dependency_conflict_project}/.agents/skills/ui-ux-pro-max"
if "${PUBLISH_SCRIPT}" project --project "${dependency_conflict_project}" \
  --skills x-ui >/dev/null 2>&1; then
  fail "发布脚本忽略了依赖 skill 的实体目录冲突"
fi
[[ -d "${dependency_conflict_project}/.agents/skills/ui-ux-pro-max" ]] || \
  fail "依赖冲突目录被破坏"
[[ ! -e "${dependency_conflict_project}/.agents/skills/x-ui" ]] || \
  fail "依赖冲突时留下了部分 x-ui 发布结果"
[[ ! -e "${dependency_conflict_project}/.agents/skills/impeccable" ]] || \
  fail "依赖冲突时留下了部分 impeccable 发布结果"

conflict_project="${test_root}/conflict-project"
mkdir -p "${conflict_project}/.agents/skills/x-ui"
if "${PUBLISH_SCRIPT}" project --project "${conflict_project}" --skills x-ui >/dev/null 2>&1; then
  fail "发布脚本覆盖了已有实体目录"
fi
[[ -d "${conflict_project}/.agents/skills/x-ui" ]] || fail "冲突目录被破坏"

# 测试 core bundle（7 项局部增强工具）正确发布与退役清理
global_target="${test_root}/global-skills"
mkdir -p "${global_target}"
ln -s "${ROOT_DIR}/global/specialists/requirements-clarification" \
  "${global_target}/requirements-clarification"
"${PUBLISH_SCRIPT}" global --target "${global_target}" --bundles core >/dev/null
for skill_name in x-debug x-db x-arch x-redteam x-biz x-html x-tdd; do
  [[ -L "${global_target}/${skill_name}" ]] || fail "core 缺少 ${skill_name} 符号链接"
done
[[ ! -L "${global_target}/requirements-clarification" ]] || fail "未清理已退役的 requirements-clarification"
[[ ! -e "${global_target}/x-rea" ]] || fail "addons 扩展意外混入 core"
"${PUBLISH_SCRIPT}" global --check --target "${global_target}" --bundles core >/dev/null

# 测试退役清理不能删除同名的外部链接或实体目录
for foreign_kind in link directory; do
  foreign_target="${test_root}/foreign-${foreign_kind}"
  mkdir -p "${foreign_target}"
  if [[ "${foreign_kind}" == link ]]; then
    ln -s "${test_root}/external-codegraph" "${foreign_target}/codegraph-assisted-navigation"
  else
    mkdir -p "${foreign_target}/codegraph-assisted-navigation"
  fi
  "${PUBLISH_SCRIPT}" global --target "${foreign_target}" --bundles core >/dev/null
  if [[ "${foreign_kind}" == link ]]; then
    [[ "$(readlink "${foreign_target}/codegraph-assisted-navigation")" == "${test_root}/external-codegraph" ]] || fail "删除了外部链接"
  else
    [[ -d "${foreign_target}/codegraph-assisted-navigation" ]] || fail "删除了实体目录"
  fi
done

legacy_target="${test_root}/legacy-global-skills"
"${ROOT_DIR}/scripts/install-links.sh" "${legacy_target}" core flow >/dev/null
[[ -L "${legacy_target}/x-arch" && -L "${legacy_target}/x-dev" ]] || fail "旧 install-links 入口未转交新发布器"

# 测试 addons bundle（x-rea）按需挂载
addons_target="${test_root}/addons-skills"
"${PUBLISH_SCRIPT}" global --target "${addons_target}" --bundles core,flow,addons >/dev/null
[[ -L "${addons_target}/x-rea" ]] || fail "未发布 addons 中的 x-rea"
[[ "$(resolve_dir "${addons_target}/x-rea")" == "$(resolve_dir "${ROOT_DIR}/vendor/global-skills/x-rea")" ]] || fail "x-rea 链接未指向项目快照"
"${PUBLISH_SCRIPT}" global --check --target "${addons_target}" --bundles core,flow,addons >/dev/null

# 测试目标项目中已有非受管的自定义实体 skill (如 verify-my-app)，不被破坏且支持发布与 check
unmanaged_project="${test_root}/unmanaged-project"
mkdir -p "${unmanaged_project}/.agents/skills/verify-my-app"
touch "${unmanaged_project}/.agents/skills/verify-my-app/SKILL.md"
"${PUBLISH_SCRIPT}" project --project "${unmanaged_project}" --skills x-ui >/dev/null
[[ -d "${unmanaged_project}/.agents/skills/verify-my-app" ]] || fail "非受管项目 skill 实体目录被破坏"
[[ -L "${unmanaged_project}/.agents/skills/x-ui" ]] || fail "受管项目 skill 符号链接未建立"
"${PUBLISH_SCRIPT}" project --check --project "${unmanaged_project}" --skills x-ui >/dev/null

# 测试 flow bundle（10 项软件研发全流程）正确发布与检查
flow_target="${test_root}/flow-skills"
"${PUBLISH_SCRIPT}" global --target "${flow_target}" --bundles flow >/dev/null
for skill_name in x-dev x-req x-domain x-api x-spec x-tasks x-review x-guard x-verify x-retro; do
  [[ -L "${flow_target}/${skill_name}" ]] || fail "flow bundle 缺少 ${skill_name} 符号链接"
  [[ "$(resolve_dir "${flow_target}/${skill_name}")" == "$(resolve_dir "${ROOT_DIR}/global/specialists/${skill_name}")" ]] || \
    fail "${skill_name} 符号链接未指向规范源码"
done
"${PUBLISH_SCRIPT}" global --check --target "${flow_target}" --bundles flow >/dev/null

# 全量旧全局名称与新退役项迁移：所有旧受管链接（含 dangling）必须清理干净，全部 x-* 新链接就位
rename_target="${test_root}/rename-global"
mkdir -p "${rename_target}"
old_global_names=(
  dev to-requirement model api-contract to-spec to-tickets code-review
  setup-guardrails setup-verification retro verify-change implement-spec
  prototype debug review-db scan-architecture interrogate assess-venture
  tdd to-decision review-cross-stack-change
)
for old_name in "${old_global_names[@]}"; do
  ln -s "${ROOT_DIR}/global/specialists/${old_name}" "${rename_target}/${old_name}"
done
ln -s "${ROOT_DIR}/global/helpers/to-html" "${rename_target}/to-html"
ln -s "${ROOT_DIR}/vendor/global-skills/show-me" "${rename_target}/show-me"
ln -s "${ROOT_DIR}/vendor/global-skills/reverse-engineer-anything" "${rename_target}/reverse-engineer-anything"

"${PUBLISH_SCRIPT}" global --target "${rename_target}" --bundles core,flow >/dev/null
for old_name in "${old_global_names[@]}" to-html show-me reverse-engineer-anything; do
  [[ ! -L "${rename_target}/${old_name}" ]] || fail "全局改名未清理旧受管链接 ${old_name}"
done
for new_name in x-debug x-db x-arch x-redteam x-biz x-html x-tdd \
                x-dev x-req x-domain x-api x-spec x-tasks x-review x-guard x-verify x-retro; do
  [[ -L "${rename_target}/${new_name}" ]] || fail "全局改名未发布新入口 ${new_name}"
done
"${PUBLISH_SCRIPT}" global --check --target "${rename_target}" --bundles core,flow >/dev/null

# 项目级旧名（design-product-ui 与 design）迁移清理及外部同名保护
rename_project="${test_root}/rename-project"
mkdir -p "${rename_project}/.agents/skills"
ln -s "${ROOT_DIR}/project/specialists/design-product-ui" "${rename_project}/.agents/skills/design-product-ui"
ln -s "${ROOT_DIR}/project/specialists/design" "${rename_project}/.agents/skills/design"
if "${PUBLISH_SCRIPT}" project --check --project "${rename_project}" --skills x-ui >/dev/null 2>&1; then
  fail "check 未发现退役项目链接 design"
fi
"${PUBLISH_SCRIPT}" project --project "${rename_project}" --skills x-ui >/dev/null
[[ ! -L "${rename_project}/.agents/skills/design-product-ui" && ! -L "${rename_project}/.agents/skills/design" ]] || \
  fail "项目改名未清理旧链接"
[[ -L "${rename_project}/.agents/skills/x-ui" ]] || fail "项目改名未发布新入口 x-ui"
"${PUBLISH_SCRIPT}" project --check --project "${rename_project}" --skills x-ui >/dev/null

for foreign_kind in link directory; do
  foreign_project="${test_root}/foreign-retired-project-${foreign_kind}"
  mkdir -p "${foreign_project}/.agents/skills"
  for retired_proj in design-product-ui design; do
    if [[ "${foreign_kind}" == link ]]; then
      ln -s "${test_root}/outside-${retired_proj}" "${foreign_project}/.agents/skills/${retired_proj}"
    else
      mkdir -p "${foreign_project}/.agents/skills/${retired_proj}"
      touch "${foreign_project}/.agents/skills/${retired_proj}/keep"
    fi
  done
  "${PUBLISH_SCRIPT}" project --project "${foreign_project}" --skills x-ui >/dev/null
  for retired_proj in design-product-ui design; do
    if [[ "${foreign_kind}" == link ]]; then
      [[ "$(readlink "${foreign_project}/.agents/skills/${retired_proj}")" == "${test_root}/outside-${retired_proj}" ]] || fail "删除了外部退役链接"
    else
      [[ -f "${foreign_project}/.agents/skills/${retired_proj}/keep" ]] || fail "删除了非受管实体"
    fi
  done
  "${PUBLISH_SCRIPT}" project --check --project "${foreign_project}" --skills x-ui >/dev/null
done

# 新名称冲突时不能先清理旧入口，避免留下部分迁移
partial_project="${test_root}/partial-rename"
mkdir -p "${partial_project}/.agents/skills/x-ui"
ln -s "${ROOT_DIR}/project/specialists/design" "${partial_project}/.agents/skills/design"
if "${PUBLISH_SCRIPT}" project --project "${partial_project}" --skills x-ui >/dev/null 2>&1; then
  fail "改名覆盖了实体"
fi
[[ -L "${partial_project}/.agents/skills/design" ]] || fail "冲突前清理了旧入口"
[[ ! -L "${partial_project}/.agents/skills/impeccable" ]] || fail "冲突留下了部分依赖"

workflow_conflict="${test_root}/workflow-conflict"
mkdir -p "${workflow_conflict}/x-req"
ln -s "${ROOT_DIR}/global/specialists/to-requirement" "${workflow_conflict}/to-requirement"
if "${PUBLISH_SCRIPT}" global --target "${workflow_conflict}" --bundles core,flow >/dev/null 2>&1; then
  fail "新流程名称冲突未被拒绝"
fi
[[ -L "${workflow_conflict}/to-requirement" ]] || fail "冲突时提前清理旧入口"
[[ ! -e "${workflow_conflict}/x-tasks" ]] || fail "冲突时留下部分流程发布"

# 校验全局规则同步完整性（含 Codex 浏览器操作与直白解释约定）
platform_rule_root="${test_root}/platform-rules"
CODEX_SKILLS_DIR="${platform_rule_root}/codex-skills" \
CODEX_RULE_TARGET="${platform_rule_root}/codex-AGENTS.md" \
ANTIGRAVITY_SKILLS_DIR="${platform_rule_root}/ag-skills" \
GEMINI_RULE_TARGET="${platform_rule_root}/GEMINI.md" \
  "${PUBLISH_SCRIPT}" global --platforms codex,antigravity --bundles core >/dev/null
grep -Fq "## 浏览器操作" "${platform_rule_root}/codex-AGENTS.md" || fail "codex 规则缺少浏览器操作段"
grep -Fq "先用直白的中文说清现象、原因和影响" "${platform_rule_root}/codex-AGENTS.md" || fail "codex 规则缺少技术解释约定"
cmp -s "${ROOT_DIR}/rules/AGENTS.md" "${platform_rule_root}/codex-AGENTS.md" || fail "codex 规则未与事实源一致"
cmp -s "${ROOT_DIR}/rules/AGENTS.md" "${platform_rule_root}/GEMINI.md" || fail "antigravity 规则未与事实源一致"
CODEX_SKILLS_DIR="${platform_rule_root}/codex-skills" \
CODEX_RULE_TARGET="${platform_rule_root}/codex-AGENTS.md" \
ANTIGRAVITY_SKILLS_DIR="${platform_rule_root}/ag-skills" \
GEMINI_RULE_TARGET="${platform_rule_root}/GEMINI.md" \
  "${PUBLISH_SCRIPT}" global --check --platforms codex,antigravity --bundles core >/dev/null

echo "publish-skills tests passed"
