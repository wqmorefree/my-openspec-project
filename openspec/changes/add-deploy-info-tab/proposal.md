## Why

Change 1 交付了系统技术资产登记的核心底座与详情页 12-Tab 宿主，但「部署信息」Tab 目前只有「建设中」占位。运维与登记人员需要在单个系统下登记其全部部署节点：模块、应用、主机/IP、机房与资源规格、系统环境等，才能回答"这个系统部署在哪、跑在什么资源上"。按 change 1 确立的"每个 Tab 一个 change"节奏，本 change 交付第二个纵向切片：部署信息 Tab 的端到端能力，并落地 change 1 预留的"删除系统连带子表逻辑删除"钩子。

需求以原型 `docs/prototype/系统技术资产登记表原型-v2.html` 为准：部署信息是字段最多的子表，共 32 个业务字段、4 个分组；表格显 10 列，完整字段走「查看详情」；Tab 自带导入/导出按钮。

## What Changes

- 新建子表 `sys_asset_deploy`：一行 = 一个部署节点，按「系统环境」区分生产/测试/开发，平铺登记（不拆环境/节点两层）
- 后端部署节点 CRUD：按系统查询节点列表、新增、编辑、删除；复用 change 1 的 `system:asset:*` 权限点，**删除仅管理员**
- 部署节点 Excel 批量导入（必填校验、文件内与库内重复识别、逐条明细）与 CSV 导出
- 主表 `sys_asset` 删除时，SHALL 连带逻辑删除 `sys_asset_deploy` 中该系统的全部节点（change 1 预留钩子首次落地）
- 前端新增「部署信息」Tab 组件：10 列表格 + 大尺寸新增/编辑弹窗（4 分组排版）+ 查看详情抽屉（32 字段全量）+ Tab 内导入导出；注册到既有 Tab 注册表，宿主零改动
- 新增 `deploy_sys_env` 字典（生产/测试/开发），「是否」类字段统一用框架 `sys_yes_no` 字典

**Non-goals（本 change 明确不做）**

- 主机内运行的数据库实例明细（→ change 4 数据库 Tab）、中间件实例（→ change 5 中间件 Tab）
- 防火墙策略/访问控制规则（→ change 6 网络策略 Tab）；备份策略明细（→ change 7 备份策略 Tab，本 change 的「快照备份需求」仅为需求标记文本）
- 环境与节点的两级主从建模、节点资源的自动发现/监控指标采集
- 容器镜像仓库与发布流水线管理、部署架构图（→ change 12）
- 其余未开放 Tab（接口依赖、数据库、中间件等）

## Capabilities

### New Capabilities

- `asset-deployment`: 单系统下部署节点的登记与维护——节点列表（10 列）、32 字段新增/编辑/查看、删除（仅管理员）、Excel 导入/CSV 导出、系统环境字典

### Modified Capabilities

- `asset-registry-shell`: 「部署信息」Tab 由"未开放占位"变为已挂载业务组件；Tab 顺序与宿主机制不变

## Impact

- **代码**：`ruoyi-system` 新增部署节点领域类（Entity/BO/VO/Mapper/Service/Controller/导入 Listener）；`SysAssetServiceImpl` 删除链路接入级联；plus-ui 新增 `tabs/deploy-info.vue`、部署 API 与类型，改 `tabs/registry.ts`
- **数据库**：KingbaseES 新增 `sys_asset_deploy` 表（含 `asset_id` 索引、`(asset_id, sys_env, ip_address)` 部分唯一索引）；新增 `deploy_sys_env` 字典数据；Flyway 新增 V8
- **API**：新增 `/system/asset/deploy/list`、POST/PUT `/system/asset/deploy`、DELETE `/system/asset/deploy/{ids}`、`/system/asset/deploy/import`、`/system/asset/deploy/export`；不新增菜单，沿用 change 1 权限点
- **配置**：无新增环境变量；复用 change 1 的 EasyExcel/CSV 与金仓/国密基础设施
- **规范**：所有产物遵循 `docs/rules/` 与 AGENTS.md 约定（金仓方言、通用字段、分层、组件规范）；关键取舍新增 ADR-008
