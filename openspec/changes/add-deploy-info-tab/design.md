## 系统架构

### 架构总览（复用 change 1 单体分层，新增子表节点）

```
┌─────────────────────────────────────────────────────────────┐
│                     前端 plus-ui (Vue3+TS)                    │
│  views/system/asset/                                         │
│   ├─ detail.vue          Tab 宿主（不改，注册表驱动）          │
│   ├─ tabs/registry.ts    注册表：deploy-info 挂载新组件        │
│   └─ tabs/deploy-info.vue 新增：10列表格+4分组弹窗+详情抽屉    │
│  api/system/asset/deploy.ts 新增：axios 接口 + 类型           │
└──────────────┬──────────────────────────────────────────────┘
               │ REST（Authorization: Bearer JWT，R<T> 统一响应）
┌──────────────▼──────────────────────────────────────────────┐
│                    后端单体 (Spring Boot)                     │
│  ruoyi-modules/ruoyi-system/                                 │
│   ├─ controller/system/SysAssetDeployController 新增         │
│   ├─ service/ (ISysAssetDeployService + Impl) 新增            │
│   ├─ mapper/SysAssetDeployMapper 新增                         │
│   ├─ domain (SysAssetDeploy + Bo/Vo/ImportVo) 新增            │
│   ├─ listener/SysAssetDeployImportListener 新增               │
│   └─ service/impl/SysAssetServiceImpl 改：删除级联子表        │
│  ruoyi-common     复用：R/分页/MyBatis-Plus/Excel/权限        │
└──────────────┬──────────────────────────────────────────────┘
               │ MyBatis-Plus（业务 com.kingbase8.Driver）
┌──────────────▼──────────────────────────────────────────────┐
│                 KingbaseES V8R6 (asset_db)                   │
│  sys_asset（主表，既有）│ sys_asset_deploy（子表，V8 新增）   │
└─────────────────────────────────────────────────────────────┘
```

### 模块间关系与通信

- **前端 → 后端**：HTTP REST，JSON；鉴权头 `Authorization: Bearer <token>`；统一响应体 `R<T>`（code/msg/data）。
- **Tab → 宿主**：`deploy-info.vue` 经宿主 props 接收系统 `id`，数据仅作用于部署子表；保存后向宿主 emit `updated`（部署数据不影响主表标题，宿主可忽略重载）。
- **级联链路**：`SysAssetServiceImpl#deleteAssetByIds` 删除主行后，同事务内调用 `ISysAssetDeployService#deleteByAssetIds` 逻辑删除该系统全部节点。
- **数据库连接**：业务 `com.kingbase8.Driver`，Flyway `org.postgresql.Driver`，沿用 change 1 配置，本 change 不新增中间件。

### 数据流向

- **查询流**：进入部署信息 Tab → `GET /system/asset/deploy/list?assetId=&sysEnv=` → Service 按 `asset_id`（+可选环境）组 QueryWrapper → Mapper 查询 → 前端表格渲染 10 列。
- **写入流**：4 分组弹窗表单 → 前端必填校验 → `POST/PUT /system/asset/deploy` → 后端 `@Validated` 必填/数值校验 + 部署应用重复校验 → 落库 → 刷新表格。
- **导入流**：Tab 内选文件（带 assetId）→ EasyExcel 解析 → Listener 必填校验 + 文件内/库内（部署应用维度）去重 → 批量入库 → 返回成功/失败明细。
- **导出流**：按当前系统（及环境筛选）查询全部节点 → 流式 CSV（32 字段全量）→ 响应头触发下载。
- **删除流**：行删除（仅管理员，二次确认）→ 节点逻辑删除；系统删除 → 主行 + 节点同事务逻辑删除。

## 模块职责

| 工程模块 | 职责 | 本 change 交付 |
|---|---|---|
| `ruoyi-system` · controller | 部署节点 HTTP 端点：列表/增/改/删/导入/导出，权限注解 | 新增 `SysAssetDeployController` |
| `ruoyi-system` · service | 节点业务：必填校验、部署应用去重、批量导入入库、按系统逻辑删除 | 新增 Service 接口与实现 |
| `ruoyi-system` · mapper | `sys_asset_deploy` 数据访问（MPJ/链式，禁 `SELECT *`） | 新增 `SysAssetDeployMapper` |
| `ruoyi-system` · domain | 节点 Entity、BO（校验）、VO、导入 VO（Excel 表头映射） | 新增 4 个领域类 |
| `ruoyi-system` · listener | EasyExcel 逐行监听器：必填/重复校验、成功失败计数、批量落库 | 新增 `SysAssetDeployImportListener` |
| `ruoyi-system` · 主资产服务 | 系统删除链路接入子表级联逻辑删除 | 改 `SysAssetServiceImpl` |
| `ruoyi-common` | 响应体、分页、权限、Excel、MyBatis-Plus 方言/填充 | 复用，不改 |
| plus-ui · views | 部署信息 Tab：10 列表格、4 分组弹窗、详情抽屉、导入导出交互 | 新增 `tabs/deploy-info.vue`；改 `tabs/registry.ts` |
| plus-ui · api | 部署节点接口封装与 TS 类型 | 新增 `api/system/asset/deploy.ts` 及类型文件 |

## 数据模型

新建子表 `sys_asset_deploy`：一行一个部署节点，平铺登记，环境以 `sys_env` 字典列区分。字段命名、类型、通用列遵循 `docs/rules/database.md`；字段集合以原型为准（32 个业务字段 + asset_id 关联）。

```sql
CREATE TABLE IF NOT EXISTS sys_asset_deploy (
    id                  VARCHAR(64) PRIMARY KEY,
    asset_id            VARCHAR(64)   NOT NULL,
    -- 分组一：基础信息
    module_name         VARCHAR(128)  NOT NULL,
    deploy_app          VARCHAR(128)  NOT NULL,
    host_name           VARCHAR(128)  NOT NULL,
    ip_address          VARCHAR(64)   NOT NULL,
    app_desc            TEXT,
    sys_env             SMALLINT      NOT NULL,
    runtime_env         VARCHAR(128),
    -- 分组二：资源配置
    container_ip        VARCHAR(64),
    idc                 VARCHAR(128),
    cpu_cores           SMALLINT,
    memory_gb           NUMERIC(8,2),
    sys_disk_gb         NUMERIC(8,2),
    data_disk_gb        NUMERIC(8,2),
    os_info             VARCHAR(128),
    server_type         VARCHAR(64),
    node_count          SMALLINT,
    -- 分组三：网络配置
    link_template       VARCHAR(256),
    tenant              VARCHAR(64),
    vpc                 VARCHAR(128),
    security_group      VARCHAR(256),
    deploy_subnet       VARCHAR(128),
    domain_name         VARCHAR(256),
    network_qos         VARCHAR(256),
    -- 分组四：运维配置
    snapshot_need       VARCHAR(256),
    path_info           VARCHAR(256),
    file_mount          VARCHAR(256),
    batch_op_flag       SMALLINT      NOT NULL DEFAULT 0,
    batch_sched_platform VARCHAR(128),
    app_monitor_flag    SMALLINT      NOT NULL DEFAULT 0,
    domestic_flag       SMALLINT      NOT NULL DEFAULT 0,
    etl_tool            VARCHAR(128),
    remark              VARCHAR(256),
    -- 通用字段
    created_user        VARCHAR(64),
    updated_user        VARCHAR(64),
    created_time        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted          SMALLINT      NOT NULL DEFAULT 0,
    deleted_time        TIMESTAMP
);

COMMENT ON TABLE sys_asset_deploy IS '系统部署节点子表（部署信息 Tab）';
COMMENT ON COLUMN sys_asset_deploy.id IS '主键ID（UUID）';
COMMENT ON COLUMN sys_asset_deploy.asset_id IS '所属系统ID（逻辑外键，指向 sys_asset.id）';
COMMENT ON COLUMN sys_asset_deploy.module_name IS '模块名称';
COMMENT ON COLUMN sys_asset_deploy.deploy_app IS '部署应用';
COMMENT ON COLUMN sys_asset_deploy.host_name IS '主机名';
COMMENT ON COLUMN sys_asset_deploy.ip_address IS 'IP地址';
COMMENT ON COLUMN sys_asset_deploy.container_ip IS '容器IP';
COMMENT ON COLUMN sys_asset_deploy.link_template IS '链接模版';
COMMENT ON COLUMN sys_asset_deploy.idc IS '机房';
COMMENT ON COLUMN sys_asset_deploy.cpu_cores IS 'CPU（核）';
COMMENT ON COLUMN sys_asset_deploy.memory_gb IS '内存（G）';
COMMENT ON COLUMN sys_asset_deploy.sys_disk_gb IS '系统盘（G）';
COMMENT ON COLUMN sys_asset_deploy.data_disk_gb IS '数据盘（G）';
COMMENT ON COLUMN sys_asset_deploy.os_info IS '操作系统';
COMMENT ON COLUMN sys_asset_deploy.snapshot_need IS '快照备份需求';
COMMENT ON COLUMN sys_asset_deploy.server_type IS '服务器类型';
COMMENT ON COLUMN sys_asset_deploy.node_count IS '节点数量';
COMMENT ON COLUMN sys_asset_deploy.tenant IS '租户';
COMMENT ON COLUMN sys_asset_deploy.vpc IS 'VPC';
COMMENT ON COLUMN sys_asset_deploy.security_group IS '安全组';
COMMENT ON COLUMN sys_asset_deploy.app_desc IS '应用描述';
COMMENT ON COLUMN sys_asset_deploy.sys_env IS '系统环境 1-生产 2-测试 3-开发';
COMMENT ON COLUMN sys_asset_deploy.runtime_env IS '运行环境';
COMMENT ON COLUMN sys_asset_deploy.deploy_subnet IS '部署网段';
COMMENT ON COLUMN sys_asset_deploy.path_info IS '路径信息';
COMMENT ON COLUMN sys_asset_deploy.file_mount IS '文件挂载';
COMMENT ON COLUMN sys_asset_deploy.batch_op_flag IS '是否涉及批量操作 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.batch_sched_platform IS '批量调度平台';
COMMENT ON COLUMN sys_asset_deploy.app_monitor_flag IS '是否纳入应用监控 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.network_qos IS '网络QoS策略';
COMMENT ON COLUMN sys_asset_deploy.domain_name IS '域名';
COMMENT ON COLUMN sys_asset_deploy.domestic_flag IS '国产化 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.etl_tool IS 'ETL工具';
COMMENT ON COLUMN sys_asset_deploy.remark IS '备注';
COMMENT ON COLUMN sys_asset_deploy.created_user IS '创建人';
COMMENT ON COLUMN sys_asset_deploy.updated_user IS '更新人';
COMMENT ON COLUMN sys_asset_deploy.created_time IS '创建时间';
COMMENT ON COLUMN sys_asset_deploy.updated_time IS '更新时间';
COMMENT ON COLUMN sys_asset_deploy.is_deleted IS '是否删除 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.deleted_time IS '删除时间（软删除）';

CREATE INDEX IF NOT EXISTS idx_sys_asset_deploy_asset_id
    ON sys_asset_deploy (asset_id);
CREATE UNIQUE INDEX IF NOT EXISTS uk_sys_asset_deploy_app
    ON sys_asset_deploy (asset_id, deploy_app) WHERE is_deleted = 0;
```

字段约定：

- `sys_env` 取字典 `deploy_sys_env`：1-生产 2-测试 3-开发（原型彩色标签：生产红/测试蓝/开发绿）。
- `batch_op_flag`/`app_monitor_flag`/`domestic_flag` 为 0/1 标记，取框架 `sys_yes_no` 字典；三个资源量字段（内存/盘）允许小数，`cpu_cores`/`node_count` 为非负整数。
- 必填：`module_name`、`deploy_app`、`host_name`、`ip_address`、`sys_env`（BO 校验 + DDL NOT NULL）。
- 唯一性：`(asset_id, deploy_app)` 部分唯一索引防同系统重复录入部署应用；已逻辑删除记录不占名额。
- 每个业务列必须加 `COMMENT`（V8 脚本内随表补全）；`asset_id` 为逻辑外键（不建物理外键，与 change 1 约定一致），指向 `sys_asset.id`。
- 字典种子在 V8 一并写入 `sys_dict_type`/`sys_dict_data`。

## 接口契约

### 通用约定

- RESTful 语义（GET 查询/POST 新增/PUT 修改/DELETE 逻辑删除）；统一响应体 `R<T>`：成功 code=200，未认证 401，权限不足 403。
- 节点按系统查询，数据量小不做分页；入参 `assetId` 必传，`sysEnv` 可选过滤。
- 参数校验走 `@Validated`，错误文案与 specs 场景一致；导入错误逐条明细返回。
- 不新增菜单与权限点，沿用 change 1：`system:asset:query/add/edit/remove/import/export`。

### 关键端点（草案）

| Method | Path | 说明 | 权限 |
|---|---|---|---|
| GET | `/api/v1/system/asset/deploy/list` | 按 assetId（可选 sysEnv）查部署节点 | `system:asset:query` |
| POST | `/api/v1/system/asset/deploy` | 新增部署节点 | `system:asset:add` |
| PUT | `/api/v1/system/asset/deploy` | 编辑部署节点 | `system:asset:edit` |
| DELETE | `/api/v1/system/asset/deploy/{ids}` | 逻辑删除节点（仅管理员，二次确认在前端） | `system:asset:remove` |
| POST | `/api/v1/system/asset/deploy/import` | Excel 导入（multipart，assetId 入参） | `system:asset:import` |
| GET | `/api/v1/system/asset/deploy/export` | 按系统导出节点 CSV（32 字段全量） | `system:asset:export` |

## 技术选型（ADR）

- ADR-002 -> kingbase-flyway-dialect
- ADR-003 -> sa-token-auth
- ADR-005 -> sys-asset-datamodel
- ADR-006 -> tab-host-registry
- ADR-007 -> easyexcel-import-csv-export
- ADR-008 -> deploy-node-flat-table

## 非功能性约束

### 安全

- 越权：前端 `v-hasPermi` 隐藏操作按钮 + 后端 `@SaCheckPermission` 双层拦截；节点删除带 `@SaCheckRole("superadmin")`，仅管理员。
- 只能操作本系统节点：所有查询/写入强制带 `asset_id` 条件，导入以 assetId 限定归属，禁止跨系统串改。
- 注入/XSS：MyBatis-Plus 参数绑定、CSV 公式注入防护沿用 change 1 处理。

### 性能

- 节点查询走 `idx_sys_asset_deploy_asset_id`；单系统节点量级小，不分页、不引入额外缓存。
- 导入导出使用流式处理（EasyExcel 分批落库 / CSV 流式输出），不整体加载入内存。

### 可运维性

- 表结构与字典数据全部经 V8 Flyway 迁移管理，版本幂等、禁止改已执行脚本。
- 新增/编辑/删除/导入/导出操作复用 `@Log` 操作日志留痕；级联删除与主删除同事务，避免残留孤儿节点。
- 遗留数据风险：V8 上线前已登记系统无节点属正常空态，不做补数据。

### 错误处理

- 全局异常映射沿用 change 1（校验错误/未认证/无权限/业务失败/未捕获）。
- 部署应用重复返回业务失败并提示；导入按行返回成功/失败明细（缺必填、文件内重复、库内重复），不因单行失败丢弃整批。
- 空结果导出提示"暂无符合条件的部署节点数据"，不生成空文件。
