#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBLISH_SCRIPT="${ROOT_DIR}/scripts/publish-skills.sh"
EXPECTED_XUI_SOURCE="${ROOT_DIR}/global/specialists/x-ui"
EXPECTED_UIUX_SOURCE="${ROOT_DIR}/vendor/global-skills/ui-ux-pro-max"
EXPECTED_IMPECCABLE_SOURCE="${ROOT_DIR}/vendor/global-skills/impeccable"

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
[[ -f "${EXPECTED_XUI_SOURCE}/SKILL.md" ]] || fail "x-ui 不在全局规范源码目录"
catalog_output="$("${PUBLISH_SCRIPT}" list)"
grep -Fq 'x-ui' <<< "${catalog_output}" || fail "catalog 未列出全局 skill x-ui"

# 1. 测试 core bundle（7 项局部增强工具）正确发布与退役清理
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
[[ ! -e "${global_target}/ui-ux-pro-max" ]] || fail "ui-deps 意外混入纯 core"
"${PUBLISH_SCRIPT}" global --check --target "${global_target}" --bundles core >/dev/null

# 2. 测试 flow bundle（11 项研发全流程 + 自动展开 x-ui 的两个全局 UI 依赖闭包）
flow_target="${test_root}/flow-skills"
"${PUBLISH_SCRIPT}" global --target "${flow_target}" --bundles flow >/dev/null
for skill_name in x-dev x-req x-domain x-api x-spec x-tasks x-review x-guard x-verify x-retro x-ui; do
  [[ -L "${flow_target}/${skill_name}" ]] || fail "flow bundle 缺少 ${skill_name} 符号链接"
  [[ "$(resolve_dir "${flow_target}/${skill_name}")" == "$(resolve_dir "${ROOT_DIR}/global/specialists/${skill_name}")" ]] || \
    fail "${skill_name} 符号链接未指向规范源码"
done
for dep_name in ui-ux-pro-max impeccable; do
  [[ -L "${flow_target}/${dep_name}" ]] || fail "flow 未展开 x-ui 的全局依赖闭包 ${dep_name}"
  [[ "$(resolve_dir "${flow_target}/${dep_name}")" == "$(resolve_dir "${ROOT_DIR}/vendor/global-skills/${dep_name}")" ]] || \
    fail "${dep_name} 依赖链接未指向 vendor/global-skills 快照"
done
"${PUBLISH_SCRIPT}" global --check --target "${flow_target}" --bundles flow >/dev/null

# 3. 测试全局依赖闭包冲突保护（ui-ux-pro-max 实体冲突时不得留下半截发布或提前删旧链接）
dep_conflict_global="${test_root}/dep-conflict-global"
mkdir -p "${dep_conflict_global}/ui-ux-pro-max"
ln -s "${ROOT_DIR}/global/specialists/to-requirement" "${dep_conflict_global}/to-requirement"
if "${PUBLISH_SCRIPT}" global --target "${dep_conflict_global}" --bundles flow >/dev/null 2>&1; then
  fail "全局发布脚本忽略了依赖 skill 的实体目录冲突"
fi
[[ -d "${dep_conflict_global}/ui-ux-pro-max" ]] || fail "依赖冲突实体目录被破坏"
[[ -L "${dep_conflict_global}/to-requirement" ]] || fail "依赖冲突时提前清理了旧入口"
[[ ! -e "${dep_conflict_global}/x-ui" ]] || fail "依赖冲突时留下了部分 x-ui 发布结果"
[[ ! -e "${dep_conflict_global}/impeccable" ]] || fail "依赖冲突时留下了部分 impeccable 发布结果"

# 4. 测试退役清理不能删除同名的外部链接或实体目录
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
[[ -L "${legacy_target}/x-arch" && -L "${legacy_target}/x-dev" && -L "${legacy_target}/x-ui" ]] || \
  fail "旧 install-links 入口未转交新发布器"

# 5. 测试 addons bundle（x-rea）按需挂载
addons_target="${test_root}/addons-skills"
"${PUBLISH_SCRIPT}" global --target "${addons_target}" --bundles core,flow,addons >/dev/null
[[ -L "${addons_target}/x-rea" ]] || fail "未发布 addons 中的 x-rea"
[[ "$(resolve_dir "${addons_target}/x-rea")" == "$(resolve_dir "${ROOT_DIR}/vendor/global-skills/x-rea")" ]] || fail "x-rea 链接未指向项目快照"
"${PUBLISH_SCRIPT}" global --check --target "${addons_target}" --bundles core,flow,addons >/dev/null

# 6. 全量旧全局名称与新退役项迁移：所有旧受管链接必须清理干净，全部 20 个新链接（18 x-* + 2 依赖）就位
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
                x-dev x-req x-domain x-api x-spec x-tasks x-review x-guard x-verify x-retro \
                x-ui ui-ux-pro-max impeccable; do
  [[ -L "${rename_target}/${new_name}" ]] || fail "全局改名未发布新入口或依赖 ${new_name}"
done
"${PUBLISH_SCRIPT}" global --check --target "${rename_target}" --bundles core,flow >/dev/null

# 7. 使用隔离 fixture 继续完整验证 project 模式的依赖闭包、冲突保护、非受管实体保护与退役项目链接清理
fixture_repo="${test_root}/fixture-repo"
mkdir -p "${fixture_repo}/project/specialists/p-route" "${fixture_repo}/vendor/project-skills/p-dep" "${fixture_repo}/config" "${fixture_repo}/scripts"
fixture_repo="$(resolve_dir "${fixture_repo}")"
printf -- '---\nname: p-route\ndescription: test\n---\n' > "${fixture_repo}/project/specialists/p-route/SKILL.md"
printf -- '---\nname: p-dep\ndescription: test\n---\n' > "${fixture_repo}/vendor/project-skills/p-dep/SKILL.md"
cp "${ROOT_DIR}/config/publish-targets.tsv" "${fixture_repo}/config/publish-targets.tsv"
cat > "${fixture_repo}/config/skills.tsv" <<'EOF'
# name|scope|source|bundles|status|dependencies
design-product-ui|project|-|-|retired|-
design|project|-|-|retired|-
p-route|project|project/specialists/p-route|ui|active|p-dep
p-dep|project|vendor/project-skills/p-dep|ui|active|-
EOF
mkdir -p "${fixture_repo}/scripts"
cp "${PUBLISH_SCRIPT}" "${fixture_repo}/scripts/publish-skills.sh"
chmod +x "${fixture_repo}/scripts/publish-skills.sh"

unmanaged_project="${test_root}/unmanaged-project"
mkdir -p "${unmanaged_project}/.agents/skills/verify-my-app"
touch "${unmanaged_project}/.agents/skills/verify-my-app/SKILL.md"
ln -s "${fixture_repo}/project/specialists/design" "${unmanaged_project}/.agents/skills/design"
"${fixture_repo}/scripts/publish-skills.sh" project --project "${unmanaged_project}" --skills p-route >/dev/null
[[ -d "${unmanaged_project}/.agents/skills/verify-my-app" ]] || fail "非受管项目 skill 实体目录被破坏"
[[ ! -L "${unmanaged_project}/.agents/skills/design" ]] || fail "项目模式未清理退役 design 链接"
[[ -L "${unmanaged_project}/.agents/skills/p-route" && -L "${unmanaged_project}/.agents/skills/p-dep" ]] || \
  fail "项目模式未展开完整依赖闭包"
"${fixture_repo}/scripts/publish-skills.sh" project --check --project "${unmanaged_project}" --skills p-route >/dev/null

partial_project="${test_root}/partial-project"
mkdir -p "${partial_project}/.agents/skills/p-dep"
ln -s "${fixture_repo}/project/specialists/design" "${partial_project}/.agents/skills/design"
if "${fixture_repo}/scripts/publish-skills.sh" project --project "${partial_project}" --skills p-route >/dev/null 2>&1; then
  fail "项目模式覆盖了冲突依赖实体"
fi
[[ -L "${partial_project}/.agents/skills/design" ]] || fail "项目冲突前提前清理了旧入口"
[[ ! -L "${partial_project}/.agents/skills/p-route" ]] || fail "项目冲突留下了部分发布结果"

# 8. 校验全局规则同步完整性
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
