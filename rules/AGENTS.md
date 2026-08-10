# User Preferences

## 沟通

- 始终使用中文回复；代码注释遵循项目现有风格，无法判断时默认中文。
- 默认简洁，先结论后细节，保持高信息密度。
- 明确区分「已验证」「推断」「未验证」；报错和异常先保留原文再分析。
- 任务交付、出现阻塞或存在明显高价值后续动作时，给出一个最优下一步；没有实际价值时不强行推荐。

## 专项 Skill 路由

- 用户明确要求梳理需求、进行需求访谈、比较方案或形成 PRD/spec 时使用 `requirements-clarification`；普通实施中的局部歧义由 Codex 原生澄清处理。
- 根因未知、难复现、偶发、并发、性能或跨组件故障使用 `systematic-debugging`；生产影响仍在扩大时先执行其 Operational Gate 控制影响。根因明确的普通 bugfix 使用 Codex 原生能力。
- 存在稳定自动化测试缝的新功能、bugfix、行为变更和重构保护使用 `test-first-development` 执行 RED-GREEN-REFACTOR；根因未知时先调试，该 skill 只负责内层实现循环，外层构建、全量测试、E2E 和替代验证仍由 Codex harness 负责。
- DDL、索引、迁移、回填、数据修复或生产写入使用 `db-change-safety`；纯只读查询不触发。
- `architecture-friction-scan`、`review-cross-stack-change`、`domain-modeling` 和 `codegraph-assisted-navigation` 属于 architecture 可选能力，只在已安装且满足各自 description 的条件时使用。
- `formal-html-docs` 属于可选产物 helper，只在用户明确要求自包含、可打印的正式 HTML 时使用。
- 所需专项 skill 未安装时，使用 Codex 原生能力完成能安全完成的部分；不要为此自动安装第三方能力。

## 文档偏好

- README、AGENTS、轻量 ADR、开发说明和短记录默认使用 Markdown。
- 用户明确要求正式、自包含、可打印的 HTML 文档时，使用 `formal-html-docs`；不因内容较长就自动改成 HTML。
- Word、PDF、幻灯片、表格、网站和产品设计优先使用 Codex 官方对应 skills/plugins。
- 用户明确指定格式或项目已有约定时，以用户和项目约定为准。
