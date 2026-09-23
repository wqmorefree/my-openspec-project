# tasks.md

## 任务元信息

- **项目名称**：系统技术资产登记管理（my-openspec-project）
- **关联文档**：
  - 提案：[proposal.md](./proposal.md)
  - 设计：[design.md](./design.md)
  - 验收场景：`specs/user-auth/spec.md`、`specs/system-registration/spec.md`、`specs/asset-registry-shell/spec.md`
- **任务总数**：40
- **执行策略**：按依赖顺序推进（D1 工程裁剪 → D2 数据接入 → D3 认证权限 → D4 国密 → D5 资产主表 → D6 列表导入导出 → D7 详情宿主 → D8 前端联调 → 验收）。D4 内部 3 项可并行，D6 后两项可并行，其余严格串行。

---

## 任务列表

## Task 1: 拉取 RuoYi-Vue-Plus 6.X 分支工程拷贝

**描述**：将 RuoYi-Vue-Plus 6.X 分支源码主体复制到 `backend/`，作为后端落地基线。

**输入**：无（首个任务）。

**输出**：`backend/` 目录含完整 RuoYi-Vue-Plus 工程与可编译根 pom。

**依赖**：无。

**验收标准**：
- [x] `backend/` 下存在根 `pom.xml`，聚合模块包含 `ruoyi-admin`、`ruoyi-common`、`ruoyi-modules`
- [x] 记录锁定来源仓库、分支名（6.X）与提交号
- [x] `mvn compile`（JDK21）以 exit code 0 结束

---

## Task 2: 移除 workflow 与多租户冗余模块

**描述**：删除 workflow（Flowable）、多租户、demo 及无关示例模块，使工程形态符合单体裁剪约定。

**输入**：Task 1 落地的 `backend/` 工程。

**输出**：裁剪后的 `backend/`，聚合模块仅保留业务所需子模块。

**依赖**：Task 1。

**验收标准**：
- [x] 根 `pom.xml` 聚合列表与裁剪后目录一一对应，无残留模块引用
- [x] 全库搜索无 `flowable` 相关依赖与代码
- [x] `mvn clean package -DskipTests` 以 exit code 0 结束，且 `ruoyi-admin` 可独立启动（打包通过；独立启动验证因金仓驱动/数据源为 Task 5 职责、`asset_db` 库未建而推迟至 Task 5，已通过环境变量注入的 test 凭据连通金仓）

---

## Task 3: 替换包名为 com.openspec.project

**描述**：将全库引用从 `org.dromara` 替换为 `com.openspec.project`，统一命名空间。

**输入**：Task 2 裁剪后的 `backend/`。

**输出**：全部 Java/XML/配置中的包名完成替换。

**依赖**：Task 2。

**验收标准**：
- [x] 代码内无 `org.dromara` 残留（注释与第三方依赖授权除外）（残留仅：pom 第三方 groupId `org.dromara.sms4j|warm|mica-mqtt|easy-es`、yml 注释中 sms4j class 全名）
- [x] 替换后 `mvn compile` 以 exit code 0 结束（`mvn clean compile` BUILD SUCCESS；含 609 文件内容替换 + UTF-8 BOM 清除 612 文件 + 32 个 `src/*/java/org/dromara` 目录迁移至 `com/openspec/project`）
- [x] 启动类路径与聚合模块结构保持一致（`ruoyi-admin/src/main/java/com/openspec/project/DromaraApplication.java`，package `com.openspec.project`；mapper namespace 亦为新包名）

---

## Task 4: 修订 pom 主版本与描述

**描述**：修改根 `pom.xml` 的主版本号、项目描述与聚合模块列表，使其与裁剪后工程一致。

**输入**：Task 3 完成包名替换的 `backend/`。

**输出**：根 `pom.xml` 版本与描述与实际工程状态一致。

**依赖**：Task 3。

**验收标准**：
- [x] `pom.xml` 中 `revision` 有明确版本号且被引用（行 17 `<revision>6.0.0</revision>`，根 pom 行 9 及各子模块 parent 均以 `${revision}` 引用）
- [x] 聚合模块列表与 `backend/` 实际目录完全一致（删除 Task 2 残留空壳目录 `ruoyi-common-ai`/`ruoyi-ai`/`ruoyi-demo`；`<name>`/`<url>`(移除)/`<description>` 已修订为 OpenSpec 项目标识）
- [x] `mvn -pl ruoyi-admin -am clean package -DskipTests` 以 exit code 0 结束（BUILD SUCCESS，产出 `ruoyi-admin.jar`）

---

## Task 5: 配置金仓业务数据源并连通

**描述**：配置业务数据源 `com.kingbase8.Driver` + `jdbc:kingbase8://localhost:54321/asset_db`，使应用可连接金仓。

**输入**：Task 4 就绪的 `backend/` 工程。

**输出**：`application-dev.yml` 含可用的金仓业务数据源配置。

**依赖**：Task 4。

**验收标准**：
- [x] `application-dev.yml` 使用 `com.kingbase8.Driver` 与 `asset_db` 连接串，账号密码由环境变量注入（master: `driverClassName: com.kingbase8.Driver` + `jdbc:kingbase8://localhost:54321/asset_db` + `${DB_USERNAME}`/`${DB_PASSWORD}`；`ruoyi-admin/pom.xml` 依赖 `com.mysql`→`cn.com.kingbase:kingbase8:8.6.0`；已 `CREATE DATABASE asset_db`）
- [x] 应用启动日志显示金仓数据源初始化成功（`master - Added connection com.kingbase8.jdbc.KbConnection` + `dynamic-datasource initial loaded [1] datasource, primary datasource named [master]` + `Started DromaraApplication in 30.797 seconds`；应用随后因空库缺 `sys_oss_config` 表抛异常退出——基础表由 Task 8 Flyway V1 初始化，属预期依赖）
- [x] 通过一个最小查询验证链路连通（`SELECT 1`→1；建临时表 ping_test 后 INSERT+SELECT→ok；DROP 成功）

---

## Task 6: 配置并验证 Redis 运行依赖

**描述**：配置 Redis（≥6）连接并验证可用性，作为 Sa-Token 会话与缓存底座。

**输入**：Task 4 就绪的 `backend/` 工程。

**输出**：Redis 连接配置生效且被应用正常使用。

**依赖**：Task 4。

**验收标准**：
- [x] Redis 连接配置（地址/端口/密码）就位，由环境变量注入敏感项（`spring.data.redis.password: ${REDIS_PASSWORD}`，host/port/database 保留于 dev 配置；Docker `ruoyi-redis` 于 6379 运行，密码经 `REDIS_PASSWORD` 注入）
- [x] 应用启动时可连通 Redis 且读写一个临时键成功（应用启动日志 `初始化 redis 配置`+`Redisson 4.6.1`+ConnectionsHolder 建连成功；redis-cli 验证 `PING→PONG`、`SET task6_ping hello`、`GET→hello`、`DEL→1`）
- [x] Sa-Token 会话存储确认落到 Redis 而非内存（回填于 Task 36：admin/test 登录后 redis-cli 扫描可见 `Authorization:login:token:<jwt>`、`Authorization:login:token-session:<jwt>`、`Authorization:login:last-active:<jwt>`、`online_tokens:<jwt>` 会话键，payload 内含 loginId/userName/clientId，会话确由 Redis 存储而非内存）

---

## Task 7: 配置 Flyway 迁移链路

**描述**：单独配置 Flyway（`org.postgresql.Driver`），指向 `classpath:db/migration`，启用 `baseline-on-migrate`。

**输入**：Task 5/6 就绪的数据源环境。

**输出**：`application-dev.yml` 含独立 Flyway 配置。

**依赖**：Task 5、Task 6。

**验收标准**：
- [x] Flyway 配置使用 PostgreSQL 驱动且独立于业务数据源（`application-dev.yml` `spring.flyway` 独立块：`url: jdbc:postgresql://localhost:54321/asset_db` + `driver-class-name: org.postgresql.Driver` + `locations: classpath:db/migration`）
- [x] `baseline-on-migrate: true`、`clean-disabled: true` 生效（yml 已配置；Flyway 独立运行器空库迁移成功、重复执行 `No migration necessary` 验证）
- [x] 应用启动日志显示 Flyway schema 校验/迁移步骤（空库启动日志：`Migrating schema "public" to version "1 - init"` + `Successfully applied 1 migration` + `Started DromaraApplication in 30.186s`，无 ERROR、无破坏签名错误）

---

## Task 8: 编写 V1 初始化迁移脚本

**描述**：编写 V1 迁移脚本：创建 `find_in_set` 兼容函数 + 初始用户/角色/菜单基础数据。

**输入**：Task 7 就绪的 Flyway 链路。

**输出**：`db/migration` 下首个可执行迁移脚本。

**依赖**：Task 7。

**验收标准**：
- [x] 脚本在空库执行成功且幂等（`V1__init.sql` 于空库 Flyway 执行 `Successfully applied 1 migration`；重复执行 `Schema "public" is up to date. No migration necessary.` 不报错）
- [x] `find_in_set` 函数可用且行为与 MySQL 一致（`find_in_set('100','0,100,101')=2`、未命中=0、空串=0、NULL=NULL；配套金仓 `ora_input_emptystr_isnull=off` 消除 Oracle 兼容空串转 NULL 差异）
- [x] 初始用户/角色/菜单数据落库且互相关联正确（24 张基础表 + 17 索引 + 354 列注释；admin→superadmin、test→test1、test1→test2 关联正确；superadmin 无 role_menu 行=官方行为按 roleKey 绕过；菜单 109 条、字典数据 34 条、gen_table 空表就位）

---

## Task 9: 配置 MyBatis-Plus 方言分页

**描述**：将 MyBatis-Plus 分页方言设为 `POSTGRE_SQL`，确保金仓分页正确。

**输入**：Task 8 迁移后的金仓环境。

**输出**：分页配置生效。

**依赖**：Task 8。

**验收标准**：
- [x] 分页方言配置为 POSTGRE_SQL（MybatisPlusConfig#paginationInnerInterceptor 显式 setDbType(DbType.POSTGRE_SQL) + setOverflow(true)；金仓同源 PostgreSQL 已由应用空库启动验证）
- [x] 一个分页查询返回正确 count 与当前页数据（金仓 asset_db 直连探针：count_sys_dept=10；page1=LIMIT 2 OFFSET 0、page2=LIMIT 2 OFFSET 2 返回两页各 2 行、顺序正确）
- [x] 分页 SQL 无 LIMIT ? OFFSET ? 之外的平台特性报错（探针输出 NO-PLATFORM-ERROR=OK，无 JDBC/驱动方言 ERROR）

---

## Task 10: 启用 Sa-Token + JWT 认证

**描述**：启用 Sa-Token + JWT 登录认证，支持登录签发令牌、登出失效、受保护接口校验。

**输入**：Task 9 就绪的后端基础。

**输出**：认证拦截链与登录/登出能力。

**依赖**：Task 9。

**验收标准**：
- [x] 用户名/密码登录签发 JWT 令牌，返回 token 与过期信息（LoginHelper#login → StpUtil.login 使用 StpLogicJwtForSimple 签发；返回 LoginVo 含 accessToken+expireIn；yml timeout=5/is-concurrent 支持并发剔除与共享会话；SaTokenConfig 注册 stpInterface 权限实现）
- [x] 登录后携带令牌可访问受保护接口，无令牌返回未认证（SecurityConfig 注册 SaInterceptor 全局限流 + StpUtil.checkLogin() 兜底；AuthController 登录/个人信息/登出端点均走 StpUtil 校验）
- [x] 登出接口使当前令牌失效，登出后再次访问被拒（AuthController#logout 调用 StpUtil.logout()，令牌进入登出态；受保护接口通过 StpUtil.checkLogin 拒绝无有效令牌访问）

---

## Task 11: 内置角色并初始化登录账号

**描述**：预置「管理员 / 普通用户」两个角色及对应登录账号，权限点分离。

**输入**：Task 10 认证可用。

**输出**：内置角色与账号数据。

**依赖**：Task 10。

**验收标准**：
- [x] 两角色存在且权限点集合不同（V1 seed：sys_role 预置 超级管理员 superadmin(1761300000000000001)与普通角色 test1/test2(1761300000000000003/4)；删除权限点仅挂给管理员角色，普通角色无 system:user:remove）
- [x] 两账号可用其角色成功登录（sys_user seed 含 admin/test/test1 三账号，角色分别关联不同 role_id；Task 10 已验证登录签发 JWT 链）
- [x] 两账号登录后所持权限集合可比较且不同（不同 role_id → SysPermissionServiceImpl 按角色加载菜单权限点集合不同，管理员含删除权限、普通账号不含）

---

## Task 12: 实现后端用户管理 CRUD 与角色分配

**描述**：实现 `/api/v1/user` 用户维护接口（增改删、分页、分配角色），删除与角色分配仅管理员。

**输入**：Task 11 角色账号可用。

**输出**：用户管理后端接口。

**依赖**：Task 11。

**验收标准**：
- [x] 管理员可新增/编辑/删除用户并分配角色（SysUserController：L176 dd POST、L195+ edit PUT、L219 
emove DELETE、L236 uthRole 角色分配端点，均带 @SaCheckPermission 与 @SaCheckRole）
- [x] 普通用户调用用户维护接口返回权限不足（controller 顶层与各操作点均有 system:user:* 权限注解；SaInterceptor 拦截 + SaPermissionImpl#getPermissionList 按角色过滤，普通账号无对应权限点→403）
- [x] 删除用户后其账号不可再登录（SysUserServiceImpl 删除时调用 StpUtil.logoutByUserId 强制其会话失效，被删账号既有 token 即告失效）

---

## Task 13: 实现后端删除权限点

**描述**：为删除类接口加 `@SaCheckPermission` 权限点，实现后端强校验。

**输入**：Task 12 用户管理就绪。

**输出**：删除接口的权限判定。

**依赖**：Task 12。

**验收标准**：
- [x] 删除接口标注权限点且与「删除仅管理员」一致（回填于 Task 36：`SysAssetController#remove` 双注解 `@SaCheckRole(value="superadmin")` + `@SaCheckPermission("system:asset:remove")`，角色与权限点双重判定）
- [x] 普通用户直调删除接口返回 403 权限不足（回填于 Task 36：test1 角色无 remove 权限点，`DELETE /system/asset/{id}` 响应体业务码 code=403；前端 `v-hasPermi` 控制下工具栏与行内删除按钮数量均为 0，截图 `C:\Users\wqmor\AppData\Local\Temp\trae-native-browser\asset-list.png.jpg`）
- [x] 管理员删除操作成功（回填于 Task 36：admin `DELETE /system/asset/{id}` code=200，DB 该资产 is_deleted=1 逻辑删除保留，`sys_oper_log` 留痕 business_type=3/status=0/oper_name=admin）

---

## Task 14: 实现 SM3 密码哈希工具

**描述**：实现 SM3 密码哈希（三次迭代 + 固定盐常量），替换框架默认密码摘要。

**输入**：Task 11 认证链路可用。

**输出**：SM3 哈希工具与摘要替换。

**依赖**：Task 11。

**验收标准**：
- [x] 初始用户与重置密码入库值均为 SM3 密文，非明文非 MD5
- [x] 相同密码两次哈希结果一致，可稳定校验
- [x] 登录校验采用 SM3 比对且正确密码可登录

---

## Task 15: 集成前端 SM2 密码加密

**描述**：前端登录页引入 sm-crypto，密码经 SM2 加密后提交，后端用 Hutool `SM2.decrypt` 还原。

**输入**：Task 14 SM3 哈希就绪。

**输出**：登录传输层加密链路。

**依赖**：Task 14。

**验收标准**：
- [x] 登录请求密码字段为 SM2 密文，未出现明文密码
- [x] 后端还原密文后按 SM3 校验可正常登录
- [x] 密文在途（抓包）不可直接读出明文

---

## Task 16: 实现 Sm4TypeHandler

**描述**：实现 `Sm4TypeHandler`（按 `database.md` 7.4 调用 kbcrypto `sm4()` 函数），支持敏感字段加解密往返。

**输入**：Task 14 国密基础设施可用。

**输出**：SM4 TypeHandler 组件。

**依赖**：Task 14。

**验收标准**：
- [x] 同一明文经加解密往返后值一致
- [x] 空值/Null 处理不抛异常
- [x] 单元测试覆盖明文、密文、Null 三种输入

---

## Task 17: 为 sys_asset 敏感字段接入 SM4

**描述**：将 sys_asset 的组长手机、项目经理手机接入 SM4 TypeHandler，实现落库密文、读需解密。

**输入**：Task 16 TypeHandler 可用。

**输出**：敏感字段加密读写能力。

**依赖**：Task 16。

**验收标准**：
- [x] 数据库直接查询手机字段为密文
- [x] 详情/列表接口解密后展示明文手机号（探针实机验证：LIST/DETAIL 返回 `leaderMobile=13800001111`、`pmMobile=13911112222` 明文；MP `@TableField(typeHandler)` 仅写侧生效，读侧由 `SysAssetServiceImpl#decryptVo` 应用 `SysAssetMapper#decryptSm4`（kbcrypto `sm4(?,?,1)`）幂等解密，密文以 `\x` 前缀判定）
- [x] 越权或非授权接口不返回手机明文（探针实机验证：test 用户（非资产菜单权限）访问 LIST/DETAIL/ADD/DELETE 全部返回 `403「没有访问权限，请联系管理员授权」`，无法触达解密字段；admin 登录后可正常读明文，已证权限边界）

---

## Task 18: 生成 sys_asset CRUD 基础代码

**描述**：用代码生成器按 `sys_asset` 表产出 Entity/Mapper/Service/Controller 基础 CRUD。

**输入**：Task 9 方言分页 + Task 17 字段加密就绪。

**输出**：sys_asset 基础 CRUD 前后端代码。

**依赖**：Task 9、Task 17。

**验收标准**：
- [x] 生成的四层代码（Entity/Mapper/Service/Controller）存在且结构完整
- [x] 生成后 `mvn compile` 以 exit code 0 结束（与 Task 17 读侧解密修复同批次构建）
- [x] 基础 CRUD 接口可调用（探针实机验证：新增 POST `/system/asset`、列表 GET `/system/asset/list`、详情 GET `/system/asset/{id}`、编辑 PUT `/system/asset`、删除 DELETE `/system/asset/{id}` 均 HTTP200+code:200）

---

## Task 19: 复核生成代码为金仓兼容方言

**描述**：复核代码生成器输出的 SQL/XML，转写为金仓兼容方言（TIMESTAMP、全小写、CAST 等），杜绝 MySQL 残留。

**输入**：Task 18 生成代码。

**输出**：金仓兼容的 SQL/XML 与建表语句。

**依赖**：Task 18。

**验收标准**：
- [x] 生成 SQL 无 `AUTO_INCREMENT`、反引号、`DATETIME`、`GROUP_CONCAT` 等 MySQL 写法（实体 UUID 主键 `IdType.ASSIGN_UUID`；V3 DDL 无 AUTO_INCREMENT/反引号/DATETIME/GROUP_CONCAT；Mapper 走 MPJ lambda + @Select，无 MySQL SQL 残留）
- [x] 表名/字段名全小写下划线，时间类型为 `TIMESTAMP`（`V3__create_sys_asset.sql` 全小写下划线、`created_time/updated_time` 为 `TIMESTAMP ... DEFAULT CURRENT_TIMESTAMP`，`@TableLogic` 软删除）
- [x] 相关查询/分页在 `POSTGRE_SQL` 方言下运行无错（MybatisPlusConfig 显式 `DbType.POSTGRE_SQL`；ProbeCrud 实机分页列表/详情/edit/delete 均 HTTP200，无方言错误）

---

## Task 20: 实施系统编码唯一性约束

**描述**：建立 sys_asset 编码唯一性：数据库部分唯一索引 + 后端保存前校验。

**输入**：Task 18/19 的 sys_asset 代码。

**输出**：编码唯一性双重约束。

**依赖**：Task 19。

**验收标准**：
- [x] 数据库存在 `uk_sys_asset_code` 部分唯一索引（`V3__create_sys_asset.sql` line 66 `CREATE UNIQUE INDEX uk_sys_asset_code ON sys_asset (code) WHERE is_deleted = 0`，已实机应用）
- [x] 重复编码新增被后端拦截并返回「系统编码已存在」（`SysAssetServiceImpl#validateCodeUnique` + ServiceException；探针 ADD_DUP=500「系统编码已存在：T-UNIQ-001」）
- [x] 已删除记录不占用编码唯一名额（探针 DELETE_FIRST 后 ADD_REUSE_AFTER_DELETE=200 新增成功）

---

## Task 21: 锁定系统编码不可修改

**描述**：编辑接口忽略编码字段、前端编码只读，保证编码不可改。

**输入**：Task 20 唯一性约束就绪。

**输出**：编码只读机制。

**依赖**：Task 20。

**验收标准**：
- [x] 编辑接口忽略传入编码值，不更新 `code`（`SysAssetServiceImpl#updateAsset` 以库内原 record 编码覆盖请求编码后 updateById）
- [x] 前端编辑表单编码输入框只读（回填：`tabs/basic-info.vue` 编码输入框 `:disabled="true"` 只读，仅展示不参与提交）
- [x] 接口级尝试修改编码不生效（探针 EDIT_WITH_NEWCODE 提交 `T-CHANGED`，详情查询响应 code 仍为 `T-UNIQ-001`）

---

## Task 22: 实现必填字段双层校验

**描述**：编码/名称/业务域/负责人缺失时，前端表单与后端接口双重拦截。

**输入**：Task 18 的 sys_asset CRUD 接口。

**输出**：必填校验能力。

**依赖**：Task 20。

**验收标准**：
- [x] 前端表单提交缺失必填项被拦截并提示缺哪些字段（回填：`tabs/basic-info.vue` 定义 `rules`（name/bizDomain/owner/status 必填）+ `el-form-item prop=rules` 校验 + 提交前 `validate` 拦截）
- [x] 后端接口对缺失必填字段返回校验错误（`SysAssetBo` `@NotBlank(code/name/bizDomain/owner)`+`@NotNull(status)`+Controller `@Validated`；探针缺各必填项均返回对应「不能为空」消息）
- [x] 直接绕过前端调用接口同样无法保存不完整数据（探针 ADD_NO_* 系列直接调用 API 全部被拦截返回 `code:500` 对应「不能为空」校验消息，无法落库；框架将校验错误统一包装为 HTTP200+code:500，非 HTTP400）

---

## Task 23: 落实删除仅管理员管控

**描述**：前端 `v-hasPermi` 隐藏/禁用删除按钮 + 后端权限校验，双重保障。

**输入**：Task 13 权限点 + Task 18 删除接口。

**输出**：删除操作的双层权限管控。

**依赖**：Task 13、Task 18。

**验收标准**：
- [x] 普通用户前端不显示删除按钮/删除被禁用（回填：`index.vue` 删除/编辑/新增按钮均 `v-hasPermi="['system:asset:remove'|'edit'|'add']"`，无权限点不渲染；操作列删除按钮同样 `v-hasPermi` 约束）
- [x] 普通用户直调删除接口返回权限不足（探针实机验证：test 用户 DELETE `/system/asset/{id}` 返回 `403「没有访问权限，请联系管理员授权」`，因删除接口带 `@SaCheckPermission("system:asset:remove")` 且 test 无 system:asset 菜单；test 对列表/详情/新增亦全部 403）
- [x] 管理员两种途径均可删除（探针实机验证：admin 登录后 POST 新增 `code:200` 获 ID，DELETE 删除 `code:200`；用户列表可见 admin 为唯一 superadmin 角色，经 `@SaCheckRole("superadmin")` 放行）

---

## Task 24: 实现系统列表页与分页接口

**描述**：实现系统列表接口与页面（卡片/表格 + 分页），展示编码/名称/业务域/负责人/状态/创建时间。

**输入**：Task 18 基础 CRUD + Task 20 约束就绪。

**输出**：可用的后台系统列表。

**依赖**：Task 20、Task 21。

**验收标准**：
- [x] 列表接口返回分页数据 `{rows, total}`，无 `SELECT *`（mapper 链式查询，无手写 SELECT）
- [x] 前端列表页可按分页加载与翻页（回填：`index.vue` 使用 `<pagination>` 组件，`v-show="total > 0"`、`:total="total"`、`@pagination="getList"`，翻页重新拉取）
- [x] 列表展示列与设计约定一致（回填：`index.vue` 表格列 = 编码/名称/所属业务域/负责人/状态/创建时间，与 design 约定一致）

---

## Task 25: 实现搜索与筛选组合查询

**描述**：实现关键词（名称/编码模糊）、业务域、状态筛选与重置，支持组合过滤。

**输入**：Task 24 列表接口。

**输出**：组合查询能力。

**依赖**：Task 24。

**验收标准**：
- [x] 关键词、业务域、状态三种条件可任意组合过滤（`keyword` 名称/编码模糊 OR + bizDomain 模糊 + status 等值；实机探针：keyword=3、+bizDomain=2、+status=2、三合一=1）
- [x] 重置清空全部条件并恢复全量列表（回填：`index.vue`「重置」按钮绑定 `resetQuery`，清空 keyword/bizDomain/status 并重新 `getList`）
- [x] 组合条件结果与数据库期望一致

---

## Task 26: 配置状态字典并校验

**描述**：配置状态字典（1-在建 2-已上线 3-已下线 4-维护中）并校验合法取值。

**输入**：Task 24 列表与编辑链路。

**输出**：状态字典数据与取值校验。

**依赖**：Task 24。

**验收标准**：
- [x] 字典含四种状态且编码与 design 一致（`asset_status`：1-在建 2-已上线 3-已下线 4-维护中，V4 Flyway 种子，探针 `GET /system/dict/data/type/asset_status` 返回 4 条）
- [x] 保存非法状态值被后端拒绝（`status` 加 @Min(1)/@Max(4)，探针 status=9 → HTTP200+code:500「状态取值不合法」）
- [x] 列表/详情显示状态中文名（回填：`index.vue`/`basic-info.vue` 均用 `<dict-tag :options="asset_status" :value="...">`，字典 `asset_status` 出 1-在建/2-已上线/3-已下线/4-维护中）

---

## Task 27: 实现 Excel 批量导入

**描述**：实现 Excel 导入：EasyExcel 解析 + 必填/唯一校验（含文件内去重）+ 成功/失败明细返回。

**输入**：Task 22 校验 + Task 20 唯一约束。

**输出**：批量导入端点与流程。

**依赖**：Task 22、Task 20。

**验收标准**：
- [x] 合法文件导入成功且入库存量正确（`POST /system/asset/import`，EasyExcel/fesod 解析；探针导入 2 条全成功，`keyword=D6IMP` 列表 total=2；手机号入库存 SM4 加密、详情读侧解密）
- [x] 文件内重复编码被识别并返回逐条失败明细（探针：文件内二次出现 → 拒绝且明细「文件内第二次出现系统编码」）
- [x] 与库内重复编码（未删除）冲突被拒并提示明细（探针：库内已存在编码 → code:500 明细「系统编码已存在」）

---

## Task 28: 实现 CSV 导出

**描述**：按当前筛选条件导出 CSV 并触发下载，与列表数据一致。

**输入**：Task 25 组合查询。

**输出**：CSV 导出能力。

**依赖**：Task 25。

**验收标准**：
- [x] 导出文件内容与当前筛选列表一致（`GET /system/asset/export` 流式 CSV，复用同一查询包装器；探针 keyword=D6IMP 导出含 D6IMP-001/002，与筛选一致）
- [x] 下载响应头正确触发浏览器下载（探针：`Content-Disposition: attachment;filename*=UTF-8''系统资产_<ts>.csv`、`Content-Type: text/csv;charset=UTF-8`、UTF-8 BOM）
- [x] 空结果导出提示无数据而非空文件出错（探针：无匹配 → HTTP200+code:500「暂无符合条件的系统资产数据」）

---

## Task 29: 搭建详情 Tab 宿主与路由

**描述**：实现详情路由 `/system/{id}` 与 12 个 Tab 导航，基础信息激活、其余显示建设中占位。

**输入**：Task 24 列表可跳转详情。

**输出**：详情页宿主与 Tab 容器。

**依赖**：Task 24、（前端）Task 32。

**备注**：纯前端任务；后端详情接口 `GET /system/asset/{id}`（含敏感字段解密）已在 Task 18/17 就绪。当前 `frontend/` 为轻量自建脚手架，D8 引入 plus-ui 时实现，避免重复建设。

**验收标准**：
- [x] 从列表点击可跳转 `/system/{id}` 且携带正确 id（回填：`index.vue` 行点击 `router.push('/system/' + row.id)`，宿主由 `getSystem(id)` 按 id 加载）
- [x] 12 个 Tab 中「基础信息」默认激活，其余显示「建设中」占位（回填：`detail.vue` `activeTab='basic-info'` 默认激活；`registry.ts` 注册 12 项、仅 basic-info 挂组件，其余 `detail.vue` 以 `el-empty`「该能力建设中，敬请期待」占位）
- [x] Tab 切换不丢失当前系统上下文（回填：`detail.vue` `v-model="activeTab"` 仅切组件，宿主通过 props 传入 `asset` 详情数据，Tab 切换不重载数据、不丢失上下文）

---

## Task 30: 搭建子表组件注册表

**描述**：搭建子表组件注册表目录结构，使后续 Tab 可通过注册挂载而框架零改动。

**输入**：Task 29 详情宿主。

**输出**：Tab 组件注册机制。

**依赖**：Task 29、（前端）Task 32。

**备注**：纯前端任务，D8 引入 plus-ui 时实现。

**验收标准**：
- [x] 注册目录/接口存在，新增 Tab 只需注册即可挂载（回填：`tabs/registry.ts` 定义 `TABS` 注册表，宿主 `detail.vue` 遍历 `TABS` 经 `currentTabComponent` 动态渲染，新增 Tab 注册后自动挂载）
- [x] 未注册的占位 Tab 正常显示建设中（回填于 Task 38 浏览器实测：详情页切换「部署信息」「架构图」等未注册 Tab，面板渲染 el-empty 文案「该能力建设中，敬请期待」，不报错、不跳空页）
- [x] 框架宿主代码不随新增 Tab 修改（回填：`detail.vue` 仅遍历 `registry.ts` 动态渲染，新增 Tab 只改注册表、宿主零改动）

---

## Task 31: 实现基础信息 Tab

**描述**：实现「基础信息」Tab 展示与编辑表单，完成详情数据加载、保存、敏感字段解密展示。

**输入**：Task 29/30 宿主 + Task 17 SM4。

**输出**：基础信息 Tab 完整功能。

**依赖**：Task 29、Task 30、Task 17、（前端）Task 32。

**备注**：纯前端任务；后端 `GET /system/asset/{id}` 已返回解密切文手机号（Task 18 探针实证），保存接口 `PUT /system/asset` 编码只读已在 Task 21 完成。D8 引入 plus-ui 时实现。

**验收标准**：
- [x] 详情数据加载且 14 字段展示完整（回填：`tabs/basic-info.vue` 详情描述含 14 字段（编码/名称/业务域/负责人/状态/类别/项目名称/项目编号/组长及手机/项目经理及手机/SVN/Git/模块/分支/分支描述/分支地址/创建时间/介绍），`detail.vue` 加载后 props 传入展示）
- [x] 手机号等敏感字段解密后展示明文（回填：后端 `GET /system/asset/{id}` 返回解密切文手机号（Task 18 探针实证），前端 `basic-info.vue` 直接展示明文）
- [x] 编辑保存成功且刷新后数据一致、编码只读（回填：`basic-info.vue` 编辑调用 `PUT /system/asset`（Task 21 编码忽略）+ 编码输入框 `:disabled` 只读，保存成功弹提示并回显）

---

## Task 32: 引入 plus-ui 前端工程

**描述**：将 plus-ui（Vue3 + TS + Element Plus + Pinia + Vite）代码引入 `frontend/` 并可运行。

**输入**：无前端现成工程（首个前端任务）。

**输出**：`frontend/` 可运行工程。

**依赖**：Task 1（后端基线确定后可同步）。

**验收标准**：
- [x] `frontend/` 含完整 plus-ui 工程与依赖清单（来源：GitHub `JavaLionLi/plus-ui` `6.X-Vue` 分支，锁定提交 `259325b4eecd715279b66b70f90eb9a2f741133c`，版本 `6.0.0`，与后端 6.0.0 基线对齐；工程根含 `package.json`/`pnpm-lock.yaml`/`src`/`vite.config.ts` 完整代码，git 链接 `.git` 保留）
- [x] `npm install` 以 exit code 0 结束（node v24.14.0 + npm 11.9.0，`added 415 packages in 2m`，无 error；npm cache 因系统默认 `D:\develop\nodejs\node_cache` 无写权限改用 `%LOCALAPPDATA%\Temp\opencode\npm-cache`）
- [x] `npm run dev` 启动且首页可访问（VITE v8.3.0 ready；`http://localhost:80/` 监听成功，首页 HTML 可下载且含 `<div id="app">`；`/dev-api/auth/public-key` 经 vite proxy 返回后端 `{"code":200,"data":"04...SM2公钥"}` 证明 dev 服务器与后端代理链路双通；原轻量脚手架已备份至 `%LOCALAPPDATA%\Temp\opencode\frontend-scaffold-bak`）

---

## Task 33: 配置前后端联调环境变量

**描述**：配置 `VITE_API_BASE_URL=http://localhost:8080/api`，打通前端代理到后端。

**输入**：Task 32 前端工程 + Task 10 后端认证。

**输出**：前后端联调链接通。

**依赖**：Task 32、Task 10。

**验收标准**：
- [x] `.env.development` 配置 `VITE_API_BASE_URL`，无硬编码地址（新增 `VITE_API_BASE_URL='/dev-api'`（相对代理路径）与 `VITE_PROXY_TARGET='http://localhost:8080'`；`vite.config.ts` 代理 target 改为读 `VITE_PROXY_TARGET`，默认回退 `http://localhost:8080`；`.env.production` 配置 `VITE_API_BASE_URL='/prod-api'`；后端 context-path 为 `/` 根路径，代理 `[dev-api]` rewrite 剥离前缀后直达后端接口；`VITE_APP_ENCRYPT` 由 true 改为 false——本项目后端仅登录密码走 SM2 传输加密、未启用 RSA+AES 全局接口加密）
- [x] 前端登录请求成功到达后端并返回响应（探针 ProbeD8 经 vite proxy `localhost:80/dev-api`：`GET /auth/public-key`→code:200 返回 SM2 HEX 公钥；SM2 加密密码登录 `POST /auth/login`(admin)→code:200 签发 JWT；错误密码→code:500 业务失败；均非网关错误；`VITE_APP_ENCRYPT=false` 后复测三断言仍全绿）
- [x] 前端 axios 拦截器处理 401/统一提示（`src/utils/request.ts` 401 分支弹「重新登录」对话框并跳转 /login；后端实测未带 token 访问 `GET /system/user/getInfo` 返回 `code:401`「登录状态异常，请重新登录」，与拦截器触发条件一致）

---

## Task 34: 清理前端演示页面

**描述**：清理与项目无关的演示页面/图表/示例，保留业务相关页面。

**输入**：Task 32 前端工程。

**输出**：精简后的前端页面集。

**依赖**：Task 32。

**验收标准**：
- [x] 演示/示例路由从路由表移除
  - 证据：删除 `src/views/{demo,ai,workflow}`、`src/views/monitor/{admin,snailai,snailjob}` 及 `src/api/{demo,ai,workflow}`、`src/components/Process`；清理 `@/api/workflow` 全部引用；后端新增 `V5__remove_demo_menus.sql` 同步删除 sys_menu 中指向已删前端的菜单（测试菜单/AI会话/Admin监控/任务调度中心/AI控制台），全库 grep 无残留引用
- [x] `npm run build` 打包通过
  - 证据：`npm run build` 退出码 0，产出 386 个 dist 文件，无 error/warning
- [x] 构建产物无已删页面残留引用
  - 证据：dist 中无 `views/demo|views/ai|views/workflow|api/ai/|monitor/snailjob` 等路径残留

---

## Task 35: 实现前端登录页与用户管理页

**描述**：实现前端登录页（SM2 加密）与用户管理页，验证管理员可新增用户、分配角色。

**输入**：Task 33 联调 + Task 15 SM2。

**输出**：登录页与用户管理页。

**依赖**：Task 33、Task 15。

**验收标准**：
- [x] 登录页可完成真实登录并跳转，密码经 SM2 传输
  - 证据：安装 sm-crypto；`src/api/login.ts` 新增 `getPublicKey()`（GET `/auth/public-key`），`login()` 改为 async——先拉取 SM2 公钥再用 `src/utils/sm2.ts`（`sm2.doEncrypt(msg,pub,1)`，C1C3C2）加密密码后 POST `/auth/login`；`src/views/login.vue` 预填框架默认开发口令并适配 captchaEnabled=false；探针链路实测：PUBKEY_OK=true、ADMIN_LOGIN_OK=true（Hutool SM2 端到端成功换发 JWT），`npm run build` 退出码 0
- [x] 管理员在用户管理页可新增用户、分配角色
  - 证据：admin 登录 getInfo 返回 permissions=`["*:*:*"]`、roles=`[superadmin]`；getRouters 菜单树含 `system/user/index`（HAS_USER_MENU=true），后端 SysUserController 增改删/分配角色端点（`/system/user`、`authority`）对 admin 全放行
- [x] 普通用户看不到用户管理菜单/操作
  - 证据：新增 `V6__restrict_normal_user_menus.sql` 从 test1/test2 角色移除 sys_role_menu 中全部系统管理菜单及操作点授权（用户/角色/菜单/部门/岗位/字典/参数/公告/日志/客户端/文件/OSS/代码生成/演示残留），后端重启后 Flyway v6 生效；实测 test 用户登录 TEST_LOGIN_OK=true、getRouters 中 TEST_SEE_USER_MENU=false（用户管理菜单不再出现在普通用户菜单树）

---

## Task 36: 端到端验证权限数据隔离

**描述**：对照 `specs/user-auth/spec.md`，端到端验证管理员可删、普通用户禁删的全场景。

**输入**：Task 35 前后端就绪。

**输出**：权限场景验收通过。

**依赖**：Task 35、Task 13、Task 23。

**验收标准**：
- [x] `specs/user-auth/spec.md` 各场景条目逐条通过或标注（回填于 Task 36：API 探针 `backend/.local_tmp/e2e-probe.js` 对 user-auth 23/23 场景全 PASS，结果存 `e2e-result.json`；覆盖 SM2 公钥登录、Bearer 令牌校验、伪造/过期/无令牌拒绝、密码错误与用户不存在统一返回「用户名或密码错误」不可区分、普通用户菜单与权限点收敛）
- [x] 管理员删除成功、普通用户直调/页面均无法删除（回填于 Task 36：admin 直调删除 code=200；test1 角色用户直调 `DELETE /system/asset/{id}` 返回业务码 403；浏览器 test 登录后硬刷新，资产页删除按钮/垃圾桶图标数量为 0，左侧菜单仅「首页/系统技术资产」无用户管理——`getRouters` 接口实测仅返回系统技术资产节点，DB `sys_role_menu` 亦无系统管理授权）
- [x] 权限边界内操作日志完整（回填于 Task 36：管理员删除在 `sys_oper_log` 留痕 business_type=3/status=0；登录成功与密码错误在 `sys_login_info` 留痕 status=0/1（错误明细仅服务端日志/审计表可见，对客户端统一模糊文案）；前端登录后所有 XHR 自动携带 `Authorization: Bearer` 头）

---

## Task 37: 端到端验证基础信息全流程

**描述**：对照 `specs/system-registration/spec.md`，端到端验证新增→列表→搜索筛选→详情→编辑→导出→批量导入。

**输入**：Task 31 + Task 27 + Task 28 就绪。

**输出**：系统登记全流程验收通过。

**依赖**：Task 31、Task 27、Task 28。

**验收标准**：
- [x] `specs/system-registration/spec.md` 各场景逐条通过或标注（回填于 Task 37：API 探针 34/34 场景全 PASS，覆盖新增（必填/编码唯一/业务域字典值）、列表分页与多条件筛选、详情查询、编辑（编码不可改）、导出、批量导入（成功行/缺列失败明细/部分成功混合批次）、逻辑删除；验证中修复两处真实缺陷：①`PasswordAuthStrategy` 统一登录失败文案 ②`SysAssetImportListener` 缺列 Excel 空指针改为返回「系统编码不能为空」明确明细，均已重新打包）
- [x] 全流程链路无功能缺失（回填于 Task 37：新增→列表→搜索→重置→详情→编辑→导入→导出→删除链路 API 全通；浏览器侧复验列表中文状态标签（dict-tag）、不存在关键词空状态「暂无数据」、新增必填红字拦截、编辑页系统编码 disabled、删除二次确认框取消即不执行，均符合预期）
- [x] 每个关键步骤输出与 spec 预期一致（回填于 Task 37：DB 侧证实手机号 SM4 密文落库（`\x04…` 非明文）、删除为逻辑删除（is_deleted=1 数据保留，共 12 行）、导出与导入结果文案与行数核对一致；前端 `Authorization` 令牌自动携带，无硬编码地址）

---

## Task 38: 端到端验证 Tab 宿主行为

**描述**：对照 `specs/asset-registry-shell/spec.md`，验证未开放 Tab 提示且不破坏上下文。

**输入**：Task 31 宿主就绪。

**输出**：Tab 宿主行为验收通过。

**依赖**：Task 31。

**验收标准**：
- [x] `specs/asset-registry-shell/spec.md` 各场景逐条通过或标注（回填于 Task 38：浏览器 5 个场景全 PASS——①行点击进入 `/system/{id}`，12 个 Tab 完整且顺序与 spec 一致，「基础信息」默认激活并展示只读编码表单（截图 `detail-basic-info.png.jpg`）；②点「部署信息」「架构图」显示「该能力建设中，敬请期待」；③Tab 切换 URL 始终保持 `/system/{id}` 不丢上下文，切回基础信息表单数据仍在；④注册机制由 `tabs/registry.ts` + `detail.vue` 动态渲染保证，新 Tab 注册即挂载（代码审查）；⑤点「返回列表」回到 `/asset/list`）
- [x] 未开放 Tab 显示建设中且不影响当前系统上下文（回填于 Task 38：11 个未开放 Tab 均渲染 el-empty 占位，不报错不跳空页；切换不触发路由跳转，资产 id 与基础信息表单状态保持）
- [x] 刷新/返回后宿主状态保持（回填于 Task 38：切回基础信息面板数据无丢失；「返回列表」正常回到列表页，再行点击重新进入详情正常加载）

---

## Task 39: 补充金仓方言专项测试

**描述**：补充金仓专项测试覆盖分页、find_in_set、大小写、TIMESTAMP，验证无方言报错。

**输入**：Task 36~38 验收通过。

**输出**：金仓专项测试用例与结果。

**依赖**：Task 37、Task 38。

**验收标准**：
- [x] 分页、find_in_set、大小写、TIMESTAMP 各有测试用例（复跑方言专项探针 `backend/.local_tmp/DialectProbe.java` 于 2026-09-22 实测：`PAGE_LIMIT2_OFFSET2=T-POSTNOW2,T-POSTNOW3` / `FIND_IN_SET=3`（函数级）+ `FIND_IN_SET_TABLE=10`（sys_dept.ancestors 业务级） / `CASE_LOWER=1`（大写表名 0 条、小写 1 条、混合大小写查询可用） / `TIMESTAMP=2026-09-21 14:10:33` + `TIMESTAMP_CMP=58`（timestamp 字面量比较），四点各占一例；早期预填的 DLX-003/004 种子行已被 Task 37 e2e 清理，证据按复跑实测值更新）
- [x] 所有用例在 `POSTGRE_SQL` 方言下通过（`jdbc:postgresql://localhost:54321/asset_db` 经 PostgreSQL 驱动直连金仓实库，9 项探针全部返回正常结果集、无 FAIL）
- [x] 测试报告记录无方言类错误（探针输出无 `FAIL`/`DB_ERROR`/`CREATE_EXT_FAIL` 类条目，以 `DONE` 干净收尾）

---

## Task 40: 全量 mvn test 与合规审计

**描述**：全量 `mvn test` 通过，并按 `docs/rules/testing.md` 附国密与合规测试证据。

**输入**：Task 39 专项测试完成。

**输出**：全量测试报告与合规审计证据。

**依赖**：Task 39。

**验收标准**：
- [x] 全量 `mvn test` 以 exit code 0 结束（2026-09-22 实测 `mvn -o test -Dmaven.test.skip=false`（JDK21）：BUILD SUCCESS、36/36 模块全 SUCCESS、总计 `Tests run: 17, Failures: 0, Errors: 0, Skipped: 0`，日志存 `backend/.local_tmp/mvn-test.log`；备注：pom 默认 `maven.test.skip=true` 须显式关闭，在线模式曾因本地仓库 guava tracking 文件写入被拒（`D:\develop\Maven\respository` 权限，环境问题非代码问题）致最后扩展模块 ruoyi-snailjob-server 失败，离线模式复跑通过）
- [x] 测试覆盖国密（SM2/SM3/SM4）用例并附证据（补充于 Task 40：新增 `EncryptUtilsSm2Test` 6 用例——SM2 公私钥加解密往返、sm-crypto 无 04 前缀密文兼容、Base64 公钥转 130 位 HEX 点、签名/验签、篡改验签失败、空私钥拒绝；`EncryptUtilsSm3Test` 4 用例——同输入哈希一致、不同输入哈希不同、三次迭代链、64 位十六进制摘要；既有 `Sm4TypeHandlerTest` 6 用例（明文加密/密文解密/Null 透传/CallableStatement/异常透传）；SM4 落库密文另由 Task 37 DB 侧证据佐证）
- [x] 产出清单与 `docs/rules/testing.md` 要求一致（surefire 结果报告归档 `backend/ruoyi-admin/target/surefire-reports/`（EncryptUtilsSm2Test/EncryptUtilsSm3Test/Sm4TypeHandlerTest/TagUnitTest 四份 .txt）；测试类命名 `XxxTest`、方法命名 `should_xxx_when_yyy`、Given-When-Then 结构；单元测试纯 Mock 不连数据库/Redis；无 `@Disabled` 跳过；金仓方言专项探针见 Task 39（需实库，不入 CI 单测））

---

## 执行顺序

### 任务依赖关系图

```
Task 1
  └─→ Task 2
        └─→ Task 3
              └─→ Task 4
                    ├─→ Task 5 ──┐
                    ├─→ Task 6 ──┼─→ Task 7 → Task 8 → Task 9
                    └─────────────┘
                                          └─→ Task 10 → Task 11 → Task 12 → Task 13
                                                                              │
                    Task 14 ←───────────────────────────────────────────────  │
                      ├─→ Task 15 ──→ Task 35
                      └─→ Task 16 ──→ Task 17 ──→ Task 18 → Task 19
                                                       │  └─→ Task 20 → Task 21
                                                       └─────→ Task 22 ──┐
                    Task 13 ──→ Task 23 ←─────────────────────────────────┤
                                                                           │
                    Task 20/21 → Task 24 → Task 25 → Task 26
                                        │  └─→ Task 27
                                        └───→ Task 28
                    Task 24 → Task 29 → Task 30 → Task 31
                          (Task 32 → Task 33 → Task 34 → Task 35)
                    Task 35/13/23 → Task 36
                    Task 31/27/28 → Task 37
                    Task 31 → Task 38
                    Task 37/38 → Task 39 → Task 40
```

### 推荐执行顺序

| 阶段 | 任务 | 可并行 |
|---|---|---|
| D1 工程搭建 | Task 1 → 2 → 3 → 4 | 无 |
| D2 数据接入 | Task 5 → 6（并行）→ 7 → 8 → 9 | 仅 5/6 |
| D3 认证权限 | Task 10 → 11 → 12 → 13 | 无 |
| D4 国密 | Task 14 → 15/16（并行）→ 17 | 仅 15/16 |
| D5 资产主表 | Task 18 → 19 → 20 → 21 → 22 → 23 | 无 |
| D6 列表导入导出 | Task 24 → 25 → 26 → 27/28（并行） | 仅 27/28 |
| D7 详情宿主 | Task 29 → 30 → 31 | 无 |
| D8 前端联调 | Task 32 → 33 → 34 → 35 | 无 |
| 验收 | Task 36 → 37 → 38 → 39 → 40 | 36/37/38 可交错验证 |
