## 系统架构

### 架构总览（单体分层）

```
┌─────────────────────────────────────────────────────────────┐
│                        前端 plus-ui (Vue3+TS)                │
│  views/  login | system/list | system/detail(Tab宿主)        │
│  stores/  pinia 状态  |  api/  axios 封装 + 拦截器(JWT)      │
│  router/  权限路由守卫(登录态+菜单权限)                       │
└──────────────┬──────────────────────────────────────────────┘
               │ REST /api/v1  (JSON, Authorization: Bearer JWT)
┌──────────────▼──────────────────────────────────────────────┐
│                     后端单体 (Spring Boot)                    │
│  ruoyi-admin      ── 启动器 + 全局异常/拦截器/过滤器           │
│  ruoyi-modules/                                              │
│   ├─ ruoyi-system ── 认证(login)、用户/角色、系统资产 CRUD      │
│   └─ ruoyi-infra  ── 文件管理(导入模板/附件)                   │
│  ruoyi-common     ── 工具/常量/加密/TypeHandler/分页通用       │
│     ├─ security    SM2/SM3/SM4(kbcrypto via TypeHandler)     │
│     ├─ web         Sa-Token 拦截、响应包装 R                  │
│     └─ mybatis     MyBatis-Plus 配置(方言/自动填充/分页)      │
└──────────────┬──────────────────────────────────────────────┘
               │ MyBatis-Plus / JDBC (com.kingbase8.Driver)
┌──────────────▼──────────────────────────────────────────────┐
│                  KingbaseES V8R6 (asset_db)                  │
│  Flyway 迁移(pg驱动) │ sys_user/sys_role/sys_asset/biz_dict    │
└─────────────────────────────────────────────────────────────┘
```

依赖：Redis(≥6) 供 Sa-Token 会话/缓存；BouncyCastle 由 Hutool 转间接供国密。

### 模块间关系与通信

- **前端 → 后端**：HTTP REST，`/api/v1/**`，JSON；鉴权头 `Authorization: Bearer <token>`；统一响应体 `R<T>`（code/message/data），分页返回 `rows/total`。
- **后端模块**：同一进程内 Spring Bean 注入调用（admin → modules → common），无 RPC/消息中间件。
- **Auth 链路**：`AuthController.login` → `SysLoginService` → `sys_user` 校验(SM2解+SM3对) → 签发 JWT(Sa-Token+SM2 签名) → 前端存 token 并附于后续请求。
- **数据库连接**：业务 `com.kingbase8.Driver`；Flyway 独立 `org.postgresql.Driver`，二者互不干扰。

### 数据流向

- **查询流**：前端列表(筛选条件) → `GET /api/v1/system/page?keyword=&bizDomain=&status=` → Service 组装 QueryWrapper → Mapper 分页(方言 POSTGRE_SQL) → R 返回 → 前端渲染。
- **写入流**：前端表单 → `POST/PUT /api/v1/system` → Service 校验（编码唯一、必填）→ 敏感字段(手机)经 Sm4TypeHandler 加密落库 → 返回保存结果。
- **导入流**：上传 Excel → EasyExcel 解析校验(必填/编码唯一/文件内去重) → 批量入库 → 返回成功/失败明细。
- **导出流**：按当前筛选条件查询 → 流式输出 CSV → 响应头触发浏览器下载。

## 模块职责

| 模块 | 职责 | 本 change 交付 |
|---|---|---|
| `ruoyi-admin` | 应用启动、全局异常处理、CORS/过滤器、打包 | 参与但不改 |
| `ruoyi-system` | 认证登录、用户/角色管理、系统资产登记业务（sys_asset CRUD、导入导出） | 核心实现 |
| `ruoyi-infra` | 文件上传下载（导入模板、导出文件流） | 复用 |
| `ruoyi-common` | +`security`(国密)、`web`(Sa-Token/响应体)、`mybatis`(方言/填充)、`dict`(状态字典) | 新增/改造点 |
| `frontend/plus-ui` | 登录页、系统列表、系统详情 Tab 宿主、用户管理 | 核心实现 |

## 数据模型

change 1 只建一张主表 `sys_asset`，系统编码 `code` 建部分唯一索引（`WHERE is_deleted=0`，兼容逻辑删除）。字段命名、类型、通用列严格遵循 `docs/rules/database.md` 第三章通用字段规范。

```sql
CREATE TABLE IF NOT EXISTS sys_asset (
    -- 主键
    id              VARCHAR(64) PRIMARY KEY COMMENT '主键ID（UUID）',
    -- 业务字段
    code            VARCHAR(64)   NOT NULL COMMENT '系统编码（人工维护，不可改）',
    name            VARCHAR(128)  NOT NULL COMMENT '系统名称',
    biz_domain      VARCHAR(128)  NOT NULL COMMENT '所属业务域',
    owner           VARCHAR(64)   NOT NULL COMMENT '负责人',
    status          SMALLINT      NOT NULL DEFAULT 1 COMMENT '状态 1-在建 2-已上线 3-已下线 4-维护中',
    project_name    VARCHAR(128) COMMENT '项目名称',
    project_no      VARCHAR(64)  COMMENT '项目编号',
    leader_name     VARCHAR(64)  COMMENT '组长',
    leader_mobile   VARCHAR(128) COMMENT '组长手机（SM4加密）',
    pm_name         VARCHAR(64)  COMMENT '项目经理',
    pm_mobile       VARCHAR(128) COMMENT '项目经理手机（SM4加密）',
    intro           TEXT         COMMENT '系统介绍',
    category        VARCHAR(64)  COMMENT '系统类别',
    svn_doc_url     VARCHAR(256) COMMENT 'SVN文档地址',
    git_code_url    VARCHAR(256) COMMENT 'Git代码地址',
    module_name     VARCHAR(128) COMMENT '模块名',
    branch_name     VARCHAR(128) COMMENT '分支名',
    branch_desc     VARCHAR(256) COMMENT '分支描述',
    branch_url      VARCHAR(256) COMMENT '分支地址',
    -- 通用字段（database.md 第三章强制）
    created_time    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    is_deleted      SMALLINT     NOT NULL DEFAULT 0 COMMENT '是否删除 0-否 1-是',
    deleted_time    TIMESTAMP    NULL DEFAULT NULL COMMENT '删除时间（软删除）',
    created_user    VARCHAR(64)  COMMENT '创建人',
    updated_user    VARCHAR(64)  COMMENT '更新人'
);

COMMENT ON TABLE sys_asset IS '系统技术资产主表';
CREATE UNIQUE INDEX uk_sys_asset_code ON sys_asset (code) WHERE is_deleted = 0;
```

> status 枚举用 `SMALLINT`（database.md 4.1），代码层映射字典：1=在建 / 2=已上线 / 3=已下线 / 4=维护中。
> **逻辑删除**：系统删除采用软删除（`is_deleted` 置 1 + `deleted_time`），记录保留在库内供审计追溯；`code` 唯一索引为部分唯一索引（`WHERE is_deleted=0`），已删记录不占唯一名额。MyBatis mapper 统一带逻辑删除条件。
> 未来子表（`sys_asset_deploy` 等）各自独立 change 建表，删除系统时连带逻辑删除子表为该 change 的预留钩子（change 1 仅主行）。

## 接口契约

### 通用约定

- 前缀 `/api/v1`；RESTful 语义（GET 查询/POST 新增/PUT 修改/DELETE 删除）。
- 统一响应体 `R<T>`：`{code, msg, data}`；业务成功 `code=200`，权限不足 `code=403`，未认证 `code=401`。
- 分页入参 `pageNum/pageSize`，出参 `{ rows: [...], total: number }`。
- 参数校验走 `@Validated`，错误文案与 specs 场景一致（如"系统编码已存在"）。
- 敏感字段在列表/详情 JSON 中解密返回（授权场景），规则见 security.md。
- 详细契约在实现期随代码生成器产出并核验，此处定义 change 1 必须遵守的约定与关键端点。

### change 1 关键端点（草案）

| Method | Path | 说明 | 权限 |
|---|---|---|---|
| POST | `/api/v1/auth/login` | 登录，入参为 SM2 密文密码 | 公开 |
| POST | `/api/v1/auth/logout` | 登出，失效 token | 登录 |
| GET | `/api/v1/user/page` | 用户列表 | 登录 |
| POST/PUT/DELETE | `/api/v1/user` | 用户增改删（删/分配角色仅管理员） | 管理员 |
| GET | `/api/v1/system/page` | 系统资产分页+搜索筛选 | 登录 |
| GET | `/api/v1/system/{id}` | 系统详情 | 登录 |
| POST | `/api/v1/system` | 新增系统 | 登录 |
| PUT | `/api/v1/system/{id}` | 编辑系统（编码只读） | 登录 |
| DELETE | `/api/v1/system/{id}` | 逻辑删除（连带子表逻辑删除预留） | 仅管理员 |
| POST | `/api/v1/system/import` | Excel 批量导入 | 登录 |
| GET | `/api/v1/system/export` | CSV 导出当前筛选结果 | 登录 |

## 技术选型（ADR）

> 完整决策内容（状态 / 背景 / 选项 / 决策 / 理由）见 `docs/adr/` 对应文件，design.md 只做引用。ADR 编号全局递增。

- ADR-001 -> ruoyi-vue-plus-fast
- ADR-002 -> kingbase-flyway-dialect
- ADR-003 -> sa-token-auth
- ADR-004 -> gm-encryption-layers
- ADR-005 -> sys-asset-datamodel
- ADR-006 -> tab-host-registry
- ADR-007 -> easyexcel-import-csv-export

## 非功能性约束

### 安全

- 密码：SM2 传输加密 → SM3 哈希(三次迭代+固定盐)存储，全程无明文。
- 敏感字段：组长手机/项目经理手机经 kbcrypto `sm4()` 落库密文，读取按需解密。
- 越权：前端 `v-hasPermi` + 后端 `@SaCheckPermission` 双层拦截；删除仅管理员。
- 注入/XSS：MyBatis-Plus 参数绑定(`#{}`)、Hutool 转义，遵循 security.md。

### 性能

- 分页查询全部走数据库索引（code 部分唯一索引、status/created_time 查询索引）；列表禁止 `SELECT *`。
- 导入导出使用流式处理（EasyExcel / CSV 流式输出），不整体加载入内存。
- Redis 缓存字典、token 会话，减少数据库压力。

### 可运维性

- Flyway 管理全部 DDL/DML，版本幂等、禁止改已执行脚本；`baseline-on-migrate` + `clean-disabled`。
- 日志按 docs/rules/backend-coding.md 分层（业务日志/操作日志），登录尝试与删除操作留痕。
- 配置多环境 `dev/prod` 分离，密钥经环境变量注入（`SM4_KEY`、`DB_USERNAME/PASSWORD`）。
- **代码生成器风险**：RuoYi-Vue-Plus 内置代码生成器产出的 SQL/XML 模板默认 MySQL 风格（如 `AUTO_INCREMENT`、反引号、`DATETIME`、`GROUP_CONCAT`），直接用于金仓会报错或语义不符。**要求**：代码生成器产出后人工转写/复核为金仓兼容方言（`TIMESTAMP`、全小写、`CAST` 等），任一改动须符合 `docs/rules/database.md`。
- 实施顺序：D1 剪裁工程 → D2 连接金仓并执行初始化迁移 → D3 认证权限 → D4 国密 → 建 sys_asset → 列表/导入导出 → 详情壳 → 联调测试（详细任务见 tasks.md）。

### 错误处理

- 全局异常处理器统一映射：参数错误→400、未认证→401、无权限→403、业务失败→业务码、未捕获→500（不泄露堆栈）。
- 前端 axios 拦截器统一提示（非 2xx 弹出 msg），401 时清除 token 跳转登录页。
- 导入错误逐条明细返回，不因单行失败丢弃整批。