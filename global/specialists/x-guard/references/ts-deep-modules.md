# TypeScript 深模块边界硬约束（dependency-cruiser）

适用于包含多模块/多包的 TypeScript / JavaScript 仓库（Web App、跨端 App、Node 后端或 Monorepo 子包），让每个业务包真正成为**深模块（小公共接口 + 隐藏内部实现）**，防止 Agent 在跨模块修改时随意穿透内部目录或堆砌巨型重导出 Barrel。

方法参考 Matt Pocock `setup-ts-deep-modules`（MIT 许可）。

## 1. 目标目录与四条硬规则

```text
src/packages/          # 或 packages/（按仓库实际根目录调整 PACKAGES_ROOT）
  <name>/
    index.ts           ← 公共入口文件（Entry Point），外部允许直接 import
    client.ts          ← 另一个小公共入口（包根文件均为公开入口，优于单个巨型 Barrel）
    lib/               ← 私有实现子目录（外部严禁直接 import）
    tests/             ← 包内测试与夹具子目录（外部严禁 import，且测试自身也只能调入口文件）
```

通过路径深度而非硬编码文件夹名实施 4 条 `error` 级规则（任何子目录天然私有，后续新增子目录无需改配置）：

1. **外部仅走入口文件**：包外代码（应用层或其他包）只能 import `<pkg>/*` 根目录文件，严禁穿透 `<pkg>/<subfolder>/*`。
2. **包内自由协作**：同一包内部非测试文件可自由互相 import。
3. **测试走公共入口**：`<pkg>/tests/*` 只能 import 任意包的根入口文件及本包 `tests/` 夹具，严禁 import 本包或他包的 `lib/` 内部实现（逼迫测试锚定稳定公共测试缝）。
4. **禁止循环依赖**：拦截跨文件/跨包环状引用。

**反 Barrel 约定**：因为包根下的每个文件都是合法入口，鼓励按职责暴露多个小入口（如 `index.ts`、`client.ts`、`server.ts`），明确反对在一个 `index.ts` 中无脑 `export *` 重导出整棵子树。

## 2. 标准配置模板（`.dependency-cruiser.cjs`）

使用 `.cjs` 扩展名以兼容 `"type": "module"` 仓库；通常只需按仓库实际结构修改 `PACKAGES_ROOT`：

```javascript
// @ts-check
const PACKAGES_ROOT = "src/packages";

const R = PACKAGES_ROOT;
const PACKAGE_INTERNALS = `^${R}/[^/]+/[^/]+/`;

/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  forbidden: [
    {
      name: "entrypoint-boundary-from-app",
      comment: "包外代码只能导入包的根目录入口文件，禁止直接导入子目录私有实现。",
      severity: "error",
      from: { pathNot: `^${R}/` },
      to: { path: PACKAGE_INTERNALS },
    },
    {
      name: "entrypoint-boundary-across-packages",
      comment: "跨包调用只能导入对方根目录入口文件，禁止穿透对方内部子目录。",
      severity: "error",
      from: { path: `^${R}/([^/]+)/`, pathNot: `^${R}/[^/]+/tests/` },
      to: { path: PACKAGE_INTERNALS, pathNot: `^${R}/$1/` },
    },
    {
      name: "tests-through-entrypoints",
      comment: "测试必须通过包根公共入口验证行为，除自身 tests/ 夹具外禁止直接导入内部子目录实现。",
      severity: "error",
      from: { path: `^${R}/([^/]+)/tests/` },
      to: { path: PACKAGE_INTERNALS, pathNot: `^${R}/$1/tests/` },
    },
    {
      name: "tests-folder-is-private",
      comment: "非测试代码禁止导入任何包的 tests/ 目录。",
      severity: "error",
      from: { pathNot: `^${R}/[^/]+/tests/` },
      to: { path: `^${R}/[^/]+/tests/` },
    },
    {
      name: "no-circular",
      comment: "禁止循环依赖。",
      severity: "error",
      from: {},
      to: { circular: true },
    },
  ],
  options: {
    doNotFollow: { path: "node_modules" },
    tsConfig: { fileName: "tsconfig.json" },
    enhancedResolveOptions: { extensions: [".ts", ".tsx", ".js", ".jsx", ".json"] },
  },
};
```

> 若仓库已有 `.dependency-cruiser.*`，合并上述规则而非粗暴覆盖；不修改 `tsconfig.json` 路径别名。

## 3. 接线、咬合实证与指针登记

1. **统一入口接线**：用仓库检测到的包管理器安装 `dependency-cruiser`（`devDependencies`），新增 `lint:boundaries`（`depcruise <PACKAGES_ROOT>`）并挂入与 `typecheck` 同级的统一检查脚本（如 `check` / `ci` / `validate`）。
2. **三步咬合实证（未见红灯不算完成）**：
   - 在干净状态实跑 `lint:boundaries` 确认 **PASS**；
   - 在隔离测试文件临时加一行越界深导入（如 `import ... from "../lib/..."`），再次运行必须以 `tests-through-entrypoints`（或对应边界规则）**FAIL**；
   - 撤销临时越界导入，复跑确认恢复 **PASS**。
3. **就近文档与单行指针**：在 `<PACKAGES_ROOT>/README.md` 用简短示例写明包根入口约定与反 Barrel 原则，并在仓库根 `AGENTS.md` / `CLAUDE.md` 留一行条件指针（如 `新增或跨包引用模块前先读 <PACKAGES_ROOT>/README.md`），让后续 Agent 提前发现边界而非撞墙。
