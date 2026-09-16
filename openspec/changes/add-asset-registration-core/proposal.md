## Why

系统技术资产登记管理需要一个可运行的核心底座：用户能登录系统，管理员能登记/维护「系统」主数据（基础信息），普通用户可查看维护但不可删除。当前仓库仅有规范与原型，无任何可运行代码。此 change 交付第一个可验收的纵向切片，同时确立 RuoYi-Vue-Plus 二次开发的全部工程基线，为后续 11 大类资产子表 Tab change 提供复用范式。

## What Changes

- 从零建立后端工程：RuoYi-Vue-Plus（单体、去 Flowable 模块）接入 KingbaseES + Flyway + MyBatis-Plus（PostgreSQL 方言）
- 从零建立前端工程：plus-ui（Vue3 + TS + Element Plus + Pinia + Vite），与后端 `/api/v1` 打通
- 登录认证：自建用户表 + SM2 传输加密 + SM3 密码哈希（三次迭代 + 固定盐常量）+ JWT 令牌
- 角色权限：内置「管理员 / 普通用户」两种角色；**普通用户不可删除**任何资产记录
- 系统登记主能力（本 change 范围 = 「基础信息系统」）：
  - 系统列表页（卡片 + 搜索 + 业务域/状态筛选 + 重置）
  - 系统详情「基础信息」Tab（14 字段 + 敏感字段 SM4 加密存储）
  - 系统新增 / 编辑 / 查看 / 删除（删除仅管理员）
  - 系统编码唯一性硬约束（人工维护）
  - Excel 导入（新增）/ CSV 导出（骨架级，主列表先跑通）
- 通用行级管控：前端按角色隐藏/禁用删除按钮，后端接口校验权限

**Non-goals（本 change 明确不做）**

系统详情页共 12 大类 Tab：**系统（基础信息）、部署信息、接口依赖、数据库、中间件、网络策略、备份策略、配置项、数据分布、文件交换、技术栈、架构图**。本 change 仅实现「基础信息」；其余 11 大类 Tab 归并为 11 个独立 change 后续交付：

| 后续 change | 覆盖 Tab |
|---|---|
| change 2 | 部署信息 |
| change 3 | 接口依赖 |
| change 4 | 数据库 |
| change 5 | 中间件 |
| change 6 | 网络策略 |
| change 7 | 备份策略 |
| change 8 | 配置项 |
| change 9 | 数据分布 |
| change 10 | 文件交换 |
| change 11 | 技术栈 |
| change 12 | 架构图（总体/应用/技术/部署 4 张合并） |

- 审计留痕（变更日志 + 审计查询）——后续独立 change
- 生命周期状态机 / 审核流（登记为主，无动作流）
- 多租户

## Capabilities

### New Capabilities

- `user-auth`: 用户登录、JWT 会话、角色权限（管理员/普通用户），确定「谁可登录、谁能删除」
- `system-registration`: 系统资产登记核心——系统列表、基础信息 Tab 的维护（增/改/查/删）、搜索筛选、导入导出，SM4 敏感字段加密存储
- `asset-registry-shell`: 系统详情页的 12+ Tab 容器框架（路由、Tab 切换、通用子表骨架），本次仅承载「基础信息」Tab，为后续 Tab change 提供宿主

### Modified Capabilities

无（`openspec/specs/` 目前为空，无既有能力被修改）。

## Impact

- **代码**：新建 `backend/`（RuoYi-Vue-Plus 单体裁剪版）与 `frontend/`（plus-ui）两套工程
- **数据库**：KingbaseES 新增基础表（用户、角色、及 `sys_asset` 主表），Flyway 管理迁移；补 `find_in_set` 自定义函数
- **依赖**：引入 RuoYi-Vue-Plus、Sa-Token、MyBatis-Plus、kingbase8 驱动、Hutool/BouncyCastle（国密）；运行时新增 Redis（≥6）
- **API**: 新增 `/api/v1/auth/login`、用户/角色管理接口、`/api/v1/system/...` 系统登记 CRUD 与导入导出接口
- **配置**：后端多环境配置（dev 连接金仓 `jdbc:kingbase8://localhost:54321/asset_db`）、前端 `VITE_API_BASE_URL`
- **规范**：所有产物遵循 `docs/rules/` 与 AGENTS.md 约定（金仓适配、国密、分层、组件规范）