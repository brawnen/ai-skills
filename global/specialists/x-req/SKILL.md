---
name: x-req
description: 用户需要将模糊想法收敛为需求、访谈比较关键取舍、对想法与计划做压力测试，或统一业务术语、澄清身份/状态/生命周期与上下文边界（按需维护 GLOSSARY.md 与 ADR）时使用；普通局部澄清、简单 CRUD 或已有明确需求的实施不触发。
---

# 需求澄清与领域建模

融合依赖感知访谈（`grilling`）与领域术语建模（`grill-with-docs` / `domain-modeling`），读取 [需求与访谈协议](references/requirements.md)，按目标自动选择压力测试、需求收敛或领域术语对齐，不额外反问模式。

## 核心工作流

1. **价值切口与决策树访谈**：对 0→1 新产品或新功能，先追问现状替代方案与最小首日价值切口（砍掉周边 80% 后哪 20% 让用户第一天跑通核心价值）；按前置依赖逐轮只问当前 `frontier` 中信息增益最高的 1~3 个问题，附推荐默认项。
2. **业务术语与状态边界对齐（存在概念歧义或显式要求领域建模时）**：
   - 先读取项目已有 `GLOSSARY.md` / `CONTEXT.md`、`GLOSSARY-MAP.md`、ADR、schema 与接口，无文件时不提前建空模板；
   - 识别同义、重载或冲突概念（如 User / Account / Tenant，或 Cancel / Close / Refund / Delete），明确实体身份 vs 值对象、状态不变量、允许/禁止转换，以及命令（期望动作）与事件（已发生事实）命名；
   - 用具体边缘场景攻击定义：部分成功、重复提交、并发/重试、跨租户、过期、撤销与历史数据兼容；发现业务陈述与现有代码/schema 冲突时摆出证据交用户拍板，不因建模强行引入重型 DDD 框架。
3. **收敛产物与按需沉淀文档**：
   - 需求收敛交付目标、非目标、场景、状态/规则约束、业务验收与待决项；纯压力测试仅交付假设、风险与取舍。
   - 用户要求沉淀领域词汇表时读取 [领域词汇表格式](references/context-format.md) 更新 `GLOSSARY.md`（多上下文用 `GLOSSARY-MAP.md`）；仅当决策同时满足“难回退、缺上下文令人意外、存在真实取舍”时读取 [ADR 格式](references/adr-format.md) 建议 ADR。跨边界技术风险按需读取 [跨边界设计参考](references/cross-boundary-design.md)。

方法来源与本地适配见 [来源记录](references/upstream.md)，许可见 [MIT 许可](references/LICENSE.mattpocock)。
