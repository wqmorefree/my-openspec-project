# 项目规范索引

> 本文档是 `my-openspec-project` 项目的**规范总索引**。
>
> 详细的领域规范按需读取，请勿在本文件中堆砌细节。
>
> **项目背景**：系统技术资产登记管理

---

## 一、项目概览

### 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| **基座** | RuoYi-Vue-Plus（RuoYi 的 dromara 社区增强版） | Spring Boot 4.x，单体形态 |
| **后端** | Java + Spring Boot | Java 21 / Spring Boot 4.x |
| **构建工具** | Maven | 3.9+ |
| **ORM** | MyBatis-Plus | 3.5+ |
| **权限认证** | Sa-Token + JWT | 官方内置 |
| **缓存** | Redis | >= 6 |
| **数据库** | KingbaseES | V8R6（人大金仓） |
| **数据库驱动（业务）** | Kingbase 官方驱动 | `com.kingbase8.Driver` |
| **数据库驱动（Flyway）** | PostgreSQL 驱动 | `org.postgresql.Driver` |
| **加密** | 国密算法（SM2/SM3/SM4） | Hutool + BouncyCastle |
| **国密库** | Hutool + BouncyCastle | 5.8+ / 1.78+ |
| **前端** | Vue 3 + TypeScript + Composition API（plus-ui） | Vue 3.4+ |
| **前端构建** | Vite | 5.x |
| **UI 框架** | Element Plus | 最新 LTS |
| **状态管理** | Pinia | 2.x |

### 项目结构

本项目采用 **Monorepo**（单一代码仓库）结构：

```
my-openspec-project/
├── backend/              # 后端代码（Java + Spring Boot）
├── frontend/             # 前端代码（Vue 3 + Vite）
├── docs/rules/           # 领域规则文件（本索引引用）
├── docs/adr/             # 架构决策记录（ADR），change 的 design.md 引用
├── docs/prototype/       # 需求原型 HTML（需求澄清权威来源）
├── openspec/             # OpenSpec 规范库
│   ├── specs/            # 功能规范（业务场景）
│   └── changes/          # 变更提案
├── AGENTS.md             # 本文件（总索引）
├── README.md
└── .gitignore
```

---

## 二、规则文件索引

> **重要**：处理对应领域的任务时，**请先读取相关规则文件**再开始工作。

| 规则文件 | 适用场景 | 内容摘要 |
|---------|---------|---------|
| `docs/rules/backend-coding.md` | 所有 `.java` 文件 | Java 命名、分层、日志、工具类、常量枚举、事务、SQL |
| `docs/rules/frontend-coding.md` | 所有 `.vue` / `.ts` 文件 | 组件分类命名、Props/Emits、TS 类型、Pinia、Composables、路由 |
| `docs/rules/api-design.md` | Controller、API 相关 | 响应格式、RESTful、分页、批量操作、版本管理 |
| `docs/rules/database.md` | Mapper、SQL、实体类 | KingbaseES 表设计、通用字段、Flyway、国密加密 |
| `docs/rules/security.md` | 所有涉及安全边界的代码 | 国密算法（SM2/SM3/SM4）、SQL 注入、XSS、越权防护 |
| `docs/rules/testing.md` | 所有测试文件 | 测试命名、覆盖率、国密测试、CI 集成 |
| `docs/rules/adr.md` | 生成 ADR 或 design.md「技术选型」章节 | ADR 模板、编号规则、写作要求、与 design.md 联动 |
| `docs/rules/design.md` | 创建/修改 change 的 `design.md` | design.md 固定六章结构、写作要求、禁止事项 |
| `docs/rules/task.md` | 创建/修改 change 的 `tasks.md` | tasks.md 三层结构、任务粒度标准、任务模板格式、验收标准三特征 |

---

## 三、快速参考

| 项目 | 值 |
|------|-----|
| 包名 | `com.openspec.project` |
| API 前缀 | `/api/v1` |
| 提交规范 | Conventional Commits |
| 数据库迁移 | Flyway |
| 数据库端口 | `54321` |
| 业务连接串 | `jdbc:kingbase8://localhost:54321/asset_db` |
| Flyway 连接串 | `jdbc:postgresql://localhost:54321/asset_db` |
| 主键策略 | UUID（`VARCHAR(64)`） |
| 状态管理 | Pinia |
| **加密策略** | **国密（SM2/SM3/SM4）** |
| **密码存储** | **SM3 哈希（加固定常量迭代）** |
| **敏感字段** | **SM4 加密**（手机号、身份证、资产密钥、数据库用户名） |
| **金仓适配** | 分页方言 `POSTGRE_SQL`；表/字段全小写下划线；`DATETIME`→`TIMESTAMP`；补 `find_in_set` 函数 |

### RuoYi-Vue-Plus 二次开发约定

1. **形态**：单体应用，**彻底移除工作流（Flowable）模块**，不用多租户
2. **代码生成**：所有 CRUD 用内置代码生成器产出，人工修改须符合本索引与 `docs/rules/` 约定
3. **模块裁剪**：保留系统管理（用户/角色/菜单/部门/字典/日志）、文件管理；其余按需删除

---

## 四、前后端联调约定

| 环境 | 后端 API 地址 | 前端环境变量 |
|------|--------------|-------------|
| 开发环境 | `http://localhost:8080/api` | `VITE_API_BASE_URL=http://localhost:8080/api` |
| 生产环境 | `https://api.example.com/api` | `VITE_API_BASE_URL=https://api.example.com/api` |

前端通过环境变量 `VITE_API_BASE_URL` 引用后端地址，**禁止硬编码 API 地址**。

---

## 五、Git 工作流

### 5.1 分支命名

| 分支类型 | 命名格式 | 示例 |
|----------|----------|------|
| 主分支 | `main` | 线上稳定代码 |
| 开发分支 | `develop` | 集成分支 |
| 功能分支 | `feature/描述` | `feature/add-asset-register` |
| 修复分支 | `bugfix/描述` | `bugfix/fix-login-error` |
| 发布分支 | `release/v版本号` | `release/v1.0.0` |

### 5.2 Commit 规范

```
<type>(<scope>): <subject>
```

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 Bug |
| `docs` | 文档更新 |
| `style` | 代码格式 |
| `refactor` | 重构 |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具/依赖更新 |

**示例**：
```
feat(asset): 添加资产登记功能

- 实现资产信息录入
- 支持资产分类
- 添加资产唯一性校验
```

---

## 六、AGENTS.md 与 OpenSpec 的关系

### 6.1 三者的定位

| 文件/目录 | 作用 | 范围 |
|----------|------|------|
| `AGENTS.md` | **总索引**：技术栈、项目结构、快速参考 | 所有开发活动 |
| `docs/rules/` | **领域规则**：编码、API、数据库、安全、测试 | 按领域按需加载 |
| `docs/adr/` | **架构决策记录（ADR）**：关键技术决策与取舍 | change 的 design.md 引用 |
| `docs/prototype/` | **需求原型**：字段集合、Tab 划分、交互行为、导入导出等需求语义的权威来源 | 需求澄清时优先查阅 |
| `openspec/specs/` | **功能规范**：具体功能的验收场景 | 按功能模块维护 |
| `openspec/changes/` | **变更提案**：进行中的变更 | 按变更独立维护 |

### 6.2 协同规则

1. **`AGENTS.md` + `docs/rules/` 是基础约束**：AI 在生成代码和规范时，必须遵循所有约定
2. **`openspec/specs/` 是功能说明书**：描述"系统应该做什么"，而非"怎么做"
3. **冲突时的优先级**：`openspec/specs/` 中的功能需求优先于通用约定
4. **需求澄清以原型为准**：字段集合、Tab 划分、交互行为、导入导出按钮等需求语义，一律以 `docs/prototype/` 下的原型 HTML 为准（当前为 `系统技术资产登记表原型-v2.html`）；与既有文档或 AI 假设冲突时以原型为准，不再就此反问用户。技术实现层面的取舍仍遵循本索引与 `docs/rules/`
5. **design.md 技术选型章节必须联动 ADR**：生成 change 的 `design.md` 时，每个关键决策须同步在 `docs/adr/` 创建独立 ADR 文件并编号 `ADR-NNN`，design.md 按 `ADR-001 -> ruoyi-vue-plus-6x` 格式标注编号 + 语义短名。已有 ADR 直接引用，新增决策才新建 ADR。**撰写规则见 `docs/rules/adr.md`**。
6. **design.md 固定六章结构**：所有 change 的 `design.md` 必须按固定六章结构生成，不得增删章节（系统架构 / 模块职责 / 数据模型 / 接口契约 / 技术选型(ADR) / 非功能性约束）。**完整模板与写作要求见 `docs/rules/design.md`**。

### 6.3 OpenSpec 标准工作流

| 命令 | 用途 |
|------|------|
| `/opsx-propose` | 创建变更提案 + 规范文档 |
| `/opsx-apply` | 按 `tasks.md` 实现代码 |
| `/opsx-sync` | 将 delta 规范同步到主规范 |
| `/opsx-archive` | 归档变更，必要时内联同步主规范 |
| `/opsx-explore` | 探索模式：思考、调研、澄清需求 |
| `/opsx-update` | 修订规划产物并保持一致性 |

---

## 七、常用开发命令

### 后端（Maven）

```bash
mvn clean package -DskipTests   # 编译打包
mvn test                        # 运行测试
mvn spring-boot:run             # 启动开发
```

### 前端（Vue + Vite）

```bash
npm install          # 安装依赖
npm run dev          # 开发启动
npm run build        # 构建生产包
npm run lint         # 代码检查
npm run test         # 运行测试
```

---

## 八、环境配置

### 后端多环境（Spring Boot）

```yaml
# application.yml
spring:
  profiles:
    active: dev

# application-dev.yml（业务数据源：Kingbase 官方驱动）
spring:
  datasource:
    url: jdbc:kingbase8://localhost:54321/asset_db
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    driver-class-name: com.kingbase8.Driver

  # Flyway：单独配置，使用 PostgreSQL 驱动
  flyway:
    enabled: true
    url: jdbc:postgresql://localhost:54321/asset_db
    user: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    locations: classpath:db/migration
    baseline-on-migrate: true
    clean-disabled: true
```

### 前端环境变量

```bash
# .env.development
VITE_API_BASE_URL=http://localhost:8080/api

# .env.production
VITE_API_BASE_URL=https://api.example.com
```

---

**详细规范请见 `docs/rules/` 目录下的各规则文件。**

