#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE="${ROOT_DIR}/global/helpers/formal-html-docs/assets/templates/decision-brief.html"
SKILL_FILE="${ROOT_DIR}/global/helpers/formal-html-docs/SKILL.md"
ROUTING_FILE="${ROOT_DIR}/global/helpers/formal-html-docs/references/template-routing.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[[ -f "${TEMPLATE}" ]] || fail "缺少 decision-brief 模板"
[[ -f "${ROUTING_FILE}" ]] || fail "缺少 formal HTML 模板路由"
grep -Fq 'template-routing.md' "${SKILL_FILE}" || fail "skill 未主动读取模板路由"
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

if grep -Eq '<(link|script)[^>]+(href|src)="https?://' "${TEMPLATE}"; then
  fail "模板包含远程 CSS 或 JavaScript"
fi
if grep -Fq 'TokenF' "${TEMPLATE}"; then
  fail "通用模板包含 TokenF 专用内容"
fi

echo "formal-html-docs tests passed"
