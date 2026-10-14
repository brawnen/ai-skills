#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ASSETS_DIR="${ROOT_DIR}/global/helpers/to-html/assets"
TEMPLATE="${ROOT_DIR}/global/helpers/to-html/assets/templates/decision-brief.html"
SHELL_TEMPLATE="${ROOT_DIR}/global/helpers/to-html/assets/formal-document-shell.html"
SKILL_FILE="${ROOT_DIR}/global/helpers/to-html/SKILL.md"
ROUTING_FILE="${ROOT_DIR}/global/helpers/to-html/references/template-routing.md"
FLOW_RULES_FILE="${ROOT_DIR}/global/helpers/to-html/references/flow-diagrams.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[[ -f "${TEMPLATE}" ]] || fail "缺少 decision-brief 模板"
[[ -f "${SHELL_TEMPLATE}" ]] || fail "缺少通用 formal HTML shell"
[[ -f "${ROUTING_FILE}" ]] || fail "缺少 formal HTML 模板路由"
[[ -f "${FLOW_RULES_FILE}" ]] || fail "缺少 formal HTML 流程图规则"
grep -Fq 'template-routing.md' "${SKILL_FILE}" || fail "skill 未主动读取模板路由"
grep -Fq 'flow-diagrams.md' "${SKILL_FILE}" || fail "skill 未主动读取流程图规则"
grep -Fq '三个及以上有序阶段' "${SKILL_FILE}" || fail "skill 未定义流程图转换门槛"
grep -Fq '不能作为正式 HTML 的最终视觉表达' "${SKILL_FILE}" || fail "skill 未禁止箭头文本充当正式流程图"
grep -Fq 'assets/templates/decision-brief.html' "${SKILL_FILE}" || fail "skill 未引用 decision-brief 资产"
grep -Fq 'assets/templates/decision-brief.html' "${ROUTING_FILE}" || fail "路由未指向 decision-brief 资产"

for placeholder in DOCUMENT_TYPE TITLE SUBTITLE UPDATED_AT METADATA DECISION_SUMMARY TOC CONTENT; do
  grep -Fq "{{${placeholder}}}" "${TEMPLATE}" || fail "模板缺少 {{${placeholder}}} 占位符"
done

grep -Fq 'data-layout="decision-brief"' "${TEMPLATE}" || fail "模板缺少 decision-brief 布局标识"
grep -Fq 'data-theme="executive-sunrise"' "${TEMPLATE}" || fail "模板缺少 executive-sunrise 主题标识"
grep -Fq '@media print' "${TEMPLATE}" || fail "模板缺少打印样式"
grep -Fq '@media (max-width:' "${TEMPLATE}" || fail "模板缺少窄屏样式"
grep -Fq 'class="skip-link"' "${TEMPLATE}" || fail "模板缺少跳到正文链接"
grep -Fq '.badge-confirmed' "${TEMPLATE}" || fail "模板缺少已确认状态样式"
grep -Fq '.badge-inference' "${TEMPLATE}" || fail "模板缺少推断状态样式"
grep -Fq '.badge-unverified' "${TEMPLATE}" || fail "模板缺少未验证状态样式"
grep -Fq '.badge-pending' "${TEMPLATE}" || fail "模板缺少待确认状态样式"
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
done < <(find "${ASSETS_DIR}" -type f -name '*.html' -print0)

if grep -Eq '<(link|script)[^>]+(href|src)="https?://' "${TEMPLATE}"; then
  fail "模板包含远程 CSS 或 JavaScript"
fi
if grep -Fq 'TokenF' "${TEMPLATE}"; then
  fail "通用模板包含 TokenF 专用内容"
fi

echo "to-html tests passed"
