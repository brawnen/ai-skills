---
name: to-spec
description: 需求基本明确、需要技术实现与独立验收规格时使用；确定必要架构、契约、测试缝与兼容策略。无需交接可内联简短实施顺序；独立任务图交给 to-tickets，已有有效规格只补缺口。
---

# 实施规格

读取 [规格协议](references/spec.md) 和需要的 [产物字段](references/artifacts.md#1-实施规格)。复用已确认需求与项目事实，不重新进行完整访谈。

需要模块形状判断时读取 [架构参考](references/architecture-design.md)；跨部署兼容、异步状态、迁移或信任边界有实际风险时读取 [跨边界设计](references/cross-boundary-design.md)。

初版规格完成后按 [界面设计就绪检查](references/spec.md#界面设计就绪检查) 判断是否需先做页面/交互设计；存在缺口时主动说明下一步，不能默认直接编码。已有设计或无需界面的任务直接继续。

同一会话无需独立交接且相关设计已就绪时可附简短实施顺序；需要领取、恢复、依赖状态或并行时才形成独立任务工件。用户只要求规格时说明剩余设计缺口和建议后结束；已授权完整开发时复用授权推进。

方法来源与本地适配见 [来源记录](references/upstream.md)，许可见 [MIT 许可](references/LICENSE.mattpocock)。
