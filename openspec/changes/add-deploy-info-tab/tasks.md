# tasks.md

## 任务元信息

- **项目名称**：系统技术资产登记管理（my-openspec-project）
- **关联文档**：
  - 提案：[proposal.md](./proposal.md)
  - 设计：[design.md](./design.md)
  - 验收场景：`specs/asset-deployment/spec.md`、`specs/asset-registry-shell/spec.md`
  - 需求原型：`docs/prototype/系统技术资产登记表原型-v2.html`
- **任务总数**：14
- **执行策略**：后端按 V8 迁移 → 领域类 → Service → Controller → 导入 → 导出 → 级联接入串行；前端从 API 类型 → Tab 组件 → 抽屉 → 导入导出 → 注册串行；后端 Task 7 与前端 Task 8~12 可并行；最后统一 API 探针与浏览器验收。

---

## 任务列表

## Task 1: 编写 V8 部署节点迁移脚本

**描述**：编写 Flyway V8 脚本，创建 `sys_asset_deploy` 子表、索引与 `deploy_sys_env` 字典种子。

**输入**：design.md「数据模型」、原型部署信息字段定义。

**输出**：`ruoyi-admin/src/main/resources/db/migration/V8__create_sys_asset_deploy.sql`。

**依赖**：无（change 2 首个任务）。

**验收标准**：
- [ ] V8 脚本含 32 个业务字段列 + `asset_id` 关联列 + 全部通用字段，每个业务列与表均有 COMMENT
- [ ] 脚本含 `idx_sys_asset_deploy_asset_id` 与 `(asset_id, sys_env, ip_address) WHERE is_deleted=0` 部分唯一索引
- [ ] `deploy_sys_env` 字典类型及生产/测试/开发 3 条字典数据写入
- [ ] 应用重启 Flyway 执行成功，重复执行不报错

---

## Task 2: 实现部署节点领域类

**描述**：实现部署节点的 Entity、BO（含校验注解）、VO 领域类及对象映射。

**输入**：Task 1 的表结构。

**输出**：`com.openspec.project.system.domain` 下 `SysAssetDeploy`、`bo.SysAssetDeployBo`、`vo.SysAssetDeployVo` 及 MapStruct 映射。

**依赖**：Task 1。

**验收标准**：
- [ ] Entity 与表字段一一对应，含 `@TableLogic` 逻辑删除与自动填充注解
- [ ] BO 对模块名称/部署应用/主机名/IP地址标注 `@NotBlank`、系统环境标注 `@NotNull`，数值字段标注非负
- [ ] 三个标记字段（batch_op_flag/app_monitor_flag/domestic_flag）默认值为 0
- [ ] `mvn compile` 以 exit code 0 结束

---

## Task 3: 实现部署节点 Mapper 与 Service

**描述**：实现部署节点数据访问与业务服务：按系统查询、新增、编辑、逻辑删除、按系统批量逻辑删除、同环境 IP 重复校验。

**输入**：Task 2 领域类。

**输出**：`SysAssetDeployMapper`、`ISysAssetDeployService` 及 `SysAssetDeployServiceImpl`。

**依赖**：Task 2。

**验收标准**：
- [ ] 列表查询强制带 `asset_id`（可选 `sys_env`）条件，无 `SELECT *`
- [ ] 新增前同系统同环境 IP 已存在时抛出业务异常
- [ ] 提供 `deleteByAssetIds(Collection<String>)` 方法，执行逻辑删除并写 deleted_time
- [ ] 编辑/删除后查询自动过滤已逻辑删除记录

---

## Task 4: 实现部署节点 Controller CRUD 端点

**描述**：实现部署节点列表、新增、编辑、删除 HTTP 端点并挂权限注解。

**输入**：Task 3 的 Service。

**输出**：`controller/system/SysAssetDeployController.java`。

**依赖**：Task 3。

**验收标准**：
- [ ] GET `/system/asset/deploy/list` 要求 assetId 入参，带 `@SaCheckPermission("system:asset:query")`
- [ ] POST/PUT 带 `system:asset:add`/`system:asset:edit` 权限与 `@Validated`
- [ ] DELETE 带 `system:asset:remove` 与 `@SaCheckRole("superadmin")`，并记录 `@Log`
- [ ] 四个端点经探针调用返回符合 R<T> 契约的响应

---

## Task 5: 实现部署节点 Excel 批量导入

**描述**：实现部署节点导入 VO、EasyExcel 监听器与导入端点：必填校验、文件内/库内同环境 IP 去重、逐条明细。

**输入**：Task 4 的 Controller 与 Task 3 的 Service。

**输出**：`vo.SysAssetDeployImportVo`、`listener.SysAssetDeployImportListener` 及 Controller 导入端点。

**依赖**：Task 4。

**验收标准**：
- [ ] 导入文件 32 个中文表头与原型一致，节点均以 assetId 归属当前系统
- [ ] 缺必填列/字段返回明确失败行与原因；文件内重复 IP 被识别
- [ ] 与库内重复的行不导入，其余行正常入库，返回成功/失败条数明细

---

## Task 6: 实现部署节点 CSV 导出

**描述**：实现按当前系统（含环境过滤）流式导出部署节点 CSV，32 字段全量。

**输入**：Task 4 的 Controller 与 Task 3 的 Service。

**输出**：Controller 导出端点及服务导出方法。

**依赖**：Task 5。

**验收标准**：
- [ ] 导出 CSV 列顺序与原型字段一致，含 UTF-8 BOM，响应头触发浏览器下载
- [ ] CSV 文本字段做公式注入防护
- [ ] 无节点时返回"暂无符合条件的部署节点数据"，不生成空文件

---

## Task 7: 接入系统删除级联逻辑删除

**描述**：改造系统删除链路，在删除系统主行的同事务内连带逻辑删除其全部部署节点。

**输入**：Task 3 的 `deleteByAssetIds`。

**输出**：修改后的 `SysAssetServiceImpl`。

**依赖**：Task 3。

**验收标准**：
- [ ] 删除系统后同事务调用部署节点按 asset_id 逻辑删除，无孤儿节点
- [ ] 级联在同一事务内，任一失败整体回滚
- [ ] 批量删除多个系统时各系统节点均被级联

---

## Task 8: 创建前端部署节点 API 与类型

**描述**：新增前端部署节点接口封装与 TypeScript 类型定义。

**输入**：design.md「接口契约」。

**输出**：`src/api/system/asset/deploy/index.ts` 与 `types.ts`。

**依赖**：Task 4。

**验收标准**：
- [ ] 覆盖 list/add/update/remove/import/export 六个接口，路径与后端一致
- [ ] 类型定义覆盖 32 个业务字段，必填字段与 BO 一致
- [ ] `npm run build` 类型检查无报错

---

## Task 9: 实现部署信息 Tab 表格与新增编辑弹窗

**描述**：实现 deploy-info Tab 组件：10 列表格、系统环境彩色标签、环境过滤、大尺寸弹窗按 4 分组排版的新增/编辑表单与必填校验。

**输入**：Task 8 的 API 与类型。

**输出**：`src/views/system/asset/tabs/deploy-info.vue`。

**依赖**：Task 8。

**验收标准**：
- [ ] 组件经 props 接收系统 id，进入 Tab 自动加载该系统节点；模板为单根节点
- [ ] 表格显 10 列，系统环境用 dict-tag 彩色标签，操作按钮带 v-hasPermi
- [ ] 新增/编辑弹窗按原型 4 分组（基础/资源/网络/运维）排版，必填缺失前端拦截
- [ ] 保存成功后表格刷新；编辑弹窗回填原值

---

## Task 10: 实现部署节点详情抽屉

**描述**：实现行内「查看详情」抽屉，按 4 分组完整展示 32 个字段。

**输入**：Task 9 的 Tab 组件。

**输出**：deploy-info.vue 内详情抽屉（或同目录抽屉子组件）。

**依赖**：Task 9。

**验收标准**：
- [ ] 点击行内查看按钮打开右侧抽屉，32 字段按 4 分组全部展示
- [ ] 空字段统一显示占位符，不报错
- [ ] 关闭抽屉后仍停留在当前系统部署信息 Tab，上下文不丢失

---

## Task 11: 实现 Tab 内导入导出交互

**描述**：在部署信息 Tab 接入 Excel 导入（上传组件 + 结果提示）与 CSV 导出（按当前环境过滤）交互。

**输入**：Task 8 的导入导出 API、Task 9 的 Tab 组件。

**输出**：deploy-info.vue 导入导出功能。

**依赖**：Task 10。

**验收标准**：
- [ ] 导入按钮选择文件后带 assetId 上传，成功/失败明细有明确提示
- [ ] 导出按当前环境过滤条件下载文件，无数据时展示后端提示
- [ ] 两个按钮均带 v-hasPermi，无权限不渲染

---

## Task 12: 注册部署信息组件到 Tab 注册表

**描述**：将 deploy-info 组件注册到既有 Tab 注册表，完成挂载，宿主零改动。

**输入**：Task 11 完成的 deploy-info.vue。

**输出**：修改后的 `src/views/system/asset/tabs/registry.ts`。

**依赖**：Task 11。

**验收标准**：
- [ ] registry.ts 中 deploy-info 项通过 defineAsyncComponent 挂载 deploy-info.vue
- [ ] detail.vue 宿主文件无改动
- [ ] 浏览器中「部署信息」Tab 显示业务组件而非建设中占位

---

## Task 13: 执行 API 探针端到端验证

**描述**：对照 `specs/asset-deployment/spec.md` 与 `asset-registry-shell` delta，以 API 探针验证部署节点全部服务端场景。

**输入**：Task 6、Task 7、Task 12 完成。

**输出**：`backend/.local_tmp/` 下部署信息 e2e 探针脚本与结果文件。

**依赖**：Task 6、Task 7、Task 12。

**验收标准**：
- [ ] asset-deployment spec 全部场景逐条 PASS（CRUD/必填/IP 唯一/导入/导出/字典）
- [ ] 系统删除级联场景验证通过（主行与节点均逻辑删除）
- [ ] 普通用户删除节点返回 403，越权访问被拦截；结果文件留存于 .local_tmp

---

## Task 14: 执行浏览器端到端验收与全量测试

**描述**：浏览器验收部署信息 Tab 全交互，并运行全量 `mvn test`。

**输入**：Task 13 探针通过。

**输出**：浏览器验收结论与 mvn test 日志。

**依赖**：Task 13。

**验收标准**：
- [ ] 浏览器实测：Tab 切换、4 分组新增/编辑、详情抽屉、删除二次确认、导入导出均符合原型
- [ ] 普通用户登录无删除按钮、管理员可删除
- [ ] `mvn test` 以 exit code 0 结束，既有 17 个单测无回归，日志留存 .local_tmp

---

## 执行顺序

### 任务依赖关系图

```
Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6
                    │
                    └──────→ Task 7
Task 4 → Task 8 → Task 9 → Task 10 → Task 11 → Task 12

Task 6 + Task 7 + Task 12 → Task 13 → Task 14
```

### 推荐执行顺序

| 阶段 | 任务 | 可并行 |
|---|---|---|
| D1 数据层 | Task 1 → 2 → 3 → 4 → 5 → 6 | 无 |
| D1 级联 | Task 7（Task 3 完成后即可插入） | 与 Task 4~6 并行 |
| D2 前端 | Task 8 → 9 → 10 → 11 → 12 | Task 8 起与 D1 尾段并行 |
| D3 验收 | Task 13 → 14 | 无 |
