#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ASSETS_DIR="${ROOT_DIR}/global/helpers/x-html/assets"
TEMPLATE="${ROOT_DIR}/global/helpers/x-html/assets/templates/decision-brief.html"
ENG_TEMPLATE="${ROOT_DIR}/global/helpers/x-html/assets/templates/engineering-review.html"
SHELL_TEMPLATE="${ROOT_DIR}/global/helpers/x-html/assets/formal-document-shell.html"
SKILL_FILE="${ROOT_DIR}/global/helpers/x-html/SKILL.md"
ROUTING_FILE="${ROOT_DIR}/global/helpers/x-html/references/template-routing.md"
FLOW_RULES_FILE="${ROOT_DIR}/global/helpers/x-html/references/flow-diagrams.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[[ -f "${TEMPLATE}" ]] || fail "缺少 decision-brief 模板"
[[ -f "${ENG_TEMPLATE}" ]] || fail "缺少 engineering-review 工程模板"
[[ -f "${SHELL_TEMPLATE}" ]] || fail "缺少通用 formal HTML shell"
[[ -f "${ROUTING_FILE}" ]] || fail "缺少 formal HTML 模板路由"
[[ -f "${FLOW_RULES_FILE}" ]] || fail "缺少 formal HTML 流程图规则"
grep -Fq 'template-routing.md' "${SKILL_FILE}" || fail "skill 未主动读取模板路由"
grep -Fq 'flow-diagrams.md' "${SKILL_FILE}" || fail "skill 未主动读取流程图规则"
grep -Fq '三个及以上有序阶段' "${SKILL_FILE}" || fail "skill 未定义流程图转换门槛"
grep -Fq '不能作为正式 HTML 的最终视觉表达' "${SKILL_FILE}" || fail "skill 未禁止箭头文本充当正式流程图"
grep -Fq 'assets/templates/decision-brief.html' "${SKILL_FILE}" || fail "skill 未引用 decision-brief 资产"
grep -Fq 'assets/templates/engineering-review.html' "${SKILL_FILE}" || fail "skill 未引用 engineering-review 资产"
grep -Fq 'assets/templates/decision-brief.html' "${ROUTING_FILE}" || fail "路由未指向 decision-brief 资产"
grep -Fq 'assets/templates/engineering-review.html' "${ROUTING_FILE}" || fail "路由未指向 engineering-review 资产"

for placeholder in DOCUMENT_TYPE TITLE SUBTITLE UPDATED_AT METADATA DECISION_SUMMARY TOC CONTENT; do
  grep -Fq "{{${placeholder}}}" "${TEMPLATE}" || fail "decision-brief 缺少 {{${placeholder}}} 占位符"
done

for placeholder in DOCUMENT_TYPE TITLE SUBTITLE UPDATED_AT METADATA SUMMARY_STRIP TOC CONTENT; do
  grep -Fq "{{${placeholder}}}" "${ENG_TEMPLATE}" || fail "engineering-review 缺少 {{${placeholder}}} 占位符"
done

grep -Fq 'data-layout="decision-brief"' "${TEMPLATE}" || fail "模板缺少 decision-brief 布局标识"
grep -Fq 'data-theme="executive-sunrise"' "${TEMPLATE}" || fail "模板缺少 executive-sunrise 主题标识"
grep -Fq 'data-layout="engineering-review"' "${ENG_TEMPLATE}" || fail "工程模板缺少 engineering-review 布局标识"
grep -Fq 'data-theme="blueprint-slate"' "${ENG_TEMPLATE}" || fail "工程模板缺少 blueprint-slate 主题标识"

for tpl in "${TEMPLATE}" "${ENG_TEMPLATE}"; do
  grep -Fq '@media print' "${tpl}" || fail "模板缺少打印样式: ${tpl}"
  grep -Fq '@media (max-width:' "${tpl}" || fail "模板缺少窄屏样式: ${tpl}"
  grep -Fq 'class="skip-link"' "${tpl}" || fail "模板缺少跳到正文链接: ${tpl}"
done

for eng_cls in .compare-grid .compare-before .compare-after .process-flow details.evidence-fold .priority-blocker; do
  grep -Fq "${eng_cls}" "${ENG_TEMPLATE}" || fail "engineering-review 缺少工程语义样式 ${eng_cls}"
done

for badge_cls in .badge-confirmed .badge-user .badge-inference .badge-unverified .badge-pending; do
  grep -Fq "${badge_cls}" "${TEMPLATE}" || fail "decision-brief 模板缺少 ${badge_cls} 状态样式"
  grep -Fq "${badge_cls}" "${ENG_TEMPLATE}" || fail "engineering-review 模板缺少 ${badge_cls} 状态样式"
  grep -Fq "${badge_cls}" "${SHELL_TEMPLATE}" || fail "通用 shell 缺少 ${badge_cls} 状态样式"
done

grep -Fq '<ol class="process-flow">' "${FLOW_RULES_FILE}" || fail "流程图规则缺少语义化 HTML 示例"
grep -Fq '不依赖 Mermaid' "${FLOW_RULES_FILE}" || fail "流程图规则未声明自包含边界"
grep -Fq '窄屏改为纵向节点' "${FLOW_RULES_FILE}" || fail "流程图规则缺少窄屏降级要求"

while IFS= read -r -d '' branded_template; do
  grep -Fq 'data-brand="brawnen"' "${branded_template}" || fail "正式 HTML 资产缺少 brawnen 作品标记: ${branded_template}"
  grep -Fq 'content: attr(data-brand)' "${branded_template}" || fail "正式 HTML 资产未从 data-brand 呈现作品标记: ${branded_template}"
  grep -Fq 'pointer-events: none' "${branded_template}" || fail "作品标记可能拦截页面交互: ${branded_template}"
  grep -Fq 'user-select: none' "${branded_template}" || fail "作品标记可能进入复制文本: ${branded_template}"
  grep -Eq -- '--brand-mark: rgba\([^;]+, 0\.018\);' "${branded_template}" || fail "屏幕作品标记未使用极低透明度: ${branded_template}"
  grep -Eq -- '--brand-mark: rgba\([^;]+, 0\.022\);' "${branded_template}" || fail "打印作品标记未使用极低透明度: ${branded_template}"
  if grep -Eq '<(link|script)[^>]+(href|src)="https?://' "${branded_template}"; then
    fail "模板包含远程 CSS 或 JavaScript: ${branded_template}"
  fi
done < <(find "${ASSETS_DIR}" -type f -name '*.html' -print0)

if grep -Fq 'TokenF' "${TEMPLATE}" || grep -Fq 'TokenF' "${ENG_TEMPLATE}"; then
  fail "通用模板包含特定项目专用内容"
fi

echo "x-html tests passed"
