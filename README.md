# my-openspec-project

系统技术资产管理，遵循国密算法（SM2/SM3/SM4）安全要求。

## 项目现状

**首个纵向切片已实现并通过验收**：变更提案 `add-asset-registration-core`（任务 1–40 全部完成，2026-09-22）已交付：

- 登录认证：SM2 传输加密 + SM3 密码哈希 + Sa-Token JWT
- 资产登记：`sys_asset` 主表 CRUD、Excel 导入 / CSV 导出、菜单权限
- 详情页：12-Tab 宿主架构（当前实现「基础信息」Tab）
- 敏感字段：SM4 加密（手机号、身份证、资产密钥等）
- 质量证据：后端单测 17 用例通过，端到端探针 57/57 PASS

**代码审查加固（2026-09-23）**：针对首个切片完成一轮后端 + 前端审查并全部修复：

- 敏感字段：修复金仓驱动 `prepareThreshold` 二进制协议下 `sm4()` 密文被写成 `byte[].toString()` 的缺陷（改走 `getBytes()` + hex 编码）；SM4 密钥统一由 `Sm4KeyProvider` 提供，缺失时快速失败
- 查询性能：资产列表/详情手机列改为 SQL 内联解密，消除逐行 N+1
- 导出安全：CSV 导出分批流式写入（防 OOM），公式字符（`= + - @` 等）单元格中和，UTF-8 BOM
- 审计字段：新增/编辑自动填充 created_user / updated_user
- 前端：新增与详情表单抽取为共享组件（19 字段、编码编辑态锁定），详情页返回增加路由兜底
- 回归证据：端到端探针连续两轮 57/57 PASS，单测 17/17 通过

**待办**：

- 剩余 11 个资产子表 Tab 变更提案待创建与实施
- 主规范 `openspec/specs/` 尚为空，待 `opsx-sync` 同步
- Change 1 待归档

## 项目结构

```
my-openspec-project/
├── backend/              # 后端（RuoYi-Vue-Plus 6.0.0 裁剪版，Java 21 / Spring Boot 4.1）
├── frontend/             # 前端（plus-ui：Vue 3 + Vite + Element Plus + Pinia）
├── docs/                 # 领域规则、ADR、原型
├── openspec/             # OpenSpec 规范库（specs / changes）
├── .opencode/            # OpenSpec 工作流命令与技能
└── AGENTS.md             # 项目总览与规范索引
```

## 快速开始

**后端**（KingbaseES 数据库需已启动，端口 `54321`）：

```bash
cd backend
./mvnw spring-boot:run    # Windows: mvnw.cmd spring-boot:run
```

启动前需注入以下环境变量（dev 配置不提供默认值，SM4 密钥缺失会快速失败）：

| 变量 | 说明 |
|------|------|
| `DB_USERNAME` / `DB_PASSWORD` | 金仓业务库与 Flyway 共用凭据 |
| `REDIS_PASSWORD` | Redis 密码 |
| `SM4_KEY` | SM4 字段加密密钥（16 字节，禁止硬编码入库） |

Flyway 自动执行迁移（`V1`–`V7`），业务驱动 `com.kingbase8.Driver`，Flyway 使用 PostgreSQL 驱动。

**前端**：

```bash
cd frontend
pnpm install
pnpm run dev              # 代理转发至 http://localhost:8080
```

常用命令：`pnpm run lint`（代码检查）、`pnpm run build`（生产构建）；后端 `./mvnw test`（单元测试）。

## 快速导航

| 内容 | 位置 |
|------|------|
| 项目总览与规范索引 | `AGENTS.md` |
| 领域规则（编码/API/数据库/安全/测试/ADR/design/task） | `docs/rules/` |
| 架构决策记录（7 篇，ADR-001 ~ ADR-007） | `docs/adr/` |
| 界面原型 | `docs/prototype/` |
| 功能规范（主规范，待同步） | `openspec/specs/` |
| 变更提案（进行中：`add-asset-registration-core`） | `openspec/changes/` |
| OpenSpec 工作流命令 | `.opencode/commands/` |

## 后端模块

| 模块 | 职责 |
|------|------|
| `ruoyi-admin` | 启动器、Flyway 配置、登录认证入口 |
| `ruoyi-modules/ruoyi-system` | 系统管理 + 资产登记业务（核心） |
| `ruoyi-modules/ruoyi-gen` | 代码生成器 |
| `ruoyi-modules/ruoyi-job` | 任务调度（SnailJob） |
| `ruoyi-common/*` | 基础设施（国密、Sa-Token、MyBatis-Plus、Redis、Excel、日志等 26 个子模块） |
| `ruoyi-extend/*` | 监控与调度扩展服务 |

> 详细技术栈、目录结构、Git 约定等以 `AGENTS.md` 为准，不再在本文件重复。
