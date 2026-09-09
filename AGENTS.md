# 项目规范文档

> 本文档定义了`my-openspec-project`项目的技术标准、编码规范和开发流程。所有 AI 助手和开发者都应遵循。

---

## 一、项目概览

### 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| **后端** | Java + Spring Boot | Java 17 / Spring Boot 3.x |
| **构建工具** | Maven | 3.9+ |
| **ORM** | MyBatis-Plus | 3.5+ |
| **数据库** | MySQL | 8.0 |
| **前端** | Vue 3 + TypeScript + Composition API | Vue 3.4+ |
| **前端构建** | Vite | 5.x |
| **UI 框架** | Element Plus / Ant Design Vue | 最新 LTS |
| **状态管理** | Pinia | 2.x |

---

## 二、项目目录结构

> **物理位置**：本项目采用 Monorepo （单一代码仓库）结构，所有代码在项目根目录下组织。

```
my-openspec-project/          ← 项目根目录
├── backend/                  ← 所有后端代码（Java + Spring Boot）
├── frontend/                 ← 所有前端代码（Vue 3 + Vite）
├── openspec/                 ← 规范文档库
├── AGENTS.md                 ← 项目规范（本文件）
├── README.md
└── .gitignore
```

### 后端结构（backend/）

```
backend/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/com/openspec/project/
│   │   │   ├── controller/     # 控制器层
│   │   │   ├── service/        # 业务逻辑层
│   │   │   │   └── impl/       # 服务实现
│   │   │   ├── mapper/         # MyBatis Mapper
│   │   │   ├── entity/         # 实体类
│   │   │   ├── dto/            # 数据传输对象（请求）
│   │   │   ├── vo/             # 视图对象（响应）
│   │   │   ├── config/         # 配置类
│   │   │   ├── common/         # 通用工具/异常/常量
│   │   │   └── Application.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── mapper/         # MyBatis XML 文件
│   │       └── db/migration/   # Flyway 脚本
│   └── test/
│       └── java/
└── target/
```

### 前端结构（frontend/）

```
frontend/
├── index.html
├── vite.config.ts
├── package.json
├── tsconfig.json
├── src/
│   ├── main.ts                 # 入口文件
│   ├── App.vue
│   ├── api/                    # API 请求封装
│   │   ├── index.ts            # axios 配置
│   │   └── modules/            # 按模块拆分
│   ├── assets/                 # 静态资源
│   ├── components/             # 公共组件
│   │   └── common/
│   ├── composables/            # 组合式函数
│   ├── router/                 # 路由配置
│   ├── stores/                 # Pinia 状态管理
│   ├── types/                  # TypeScript 类型定义
│   ├── utils/                  # 工具函数
│   └── views/                  # 页面组件
├── public/
└── .env.*                      # 环境变量配置
```

### 前后端联调约定

| 环境 | 后端 API 地址 | 前端环境变量 |
|------|--------------|-------------|
| 开发环境 | `http://localhost:8080/api` | `VITE_API_BASE_URL=http://localhost:8080/api` |
| 生产环境 | `https://api.example.com/api` | `VITE_API_BASE_URL=https://api.example.com/api` |

前端通过环境变量 `VITE_API_BASE_URL` 引用后端地址，**禁止硬编码 API 地址**。

---

## 三、编码规范

### 3.1 Java 编码规范

| 规范项 | 规则 |
|--------|------|
| **包命名** | 全小写，用点分隔：`com.openspec.project.module` |
| **类命名** | PascalCase（如 `UserService`、`OrderController`） |
| **方法/变量命名** | camelCase（如 `getUserById`、`userName`） |
| **常量命名** | UPPER_SNAKE_CASE（如 `MAX_RETRY_COUNT`） |
| **Controller** | `@RestController` + `@RequestMapping("/api/v1/xxx")` |
| **Service 层** | 接口 + 实现类（`XxxService` + `XxxServiceImpl`） |
| **依赖注入** | 构造器注入（`@RequiredArgsConstructor`） |
| **日志** | Lombok `@Slf4j`，不使用 `System.out.println()` |
| **异常处理** | 全局异常处理器 `@ControllerAdvice` |

**Java 代码示例**：

```java
@Slf4j
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/{id}")
    public Result<UserVO> getById(@PathVariable Long id) {
        log.info("查询用户信息, userId={}", id);
        UserVO user = userService.getUserById(id);
        return Result.success(user);
    }
}
```

### 3.2 Vue 3 + TypeScript 编码规范

| 规范项 | 规则 |
|--------|------|
| **组件命名** | PascalCase（如 `UserList.vue`） |
| **文件命名** | PascalCase（组件）或 kebab-case（工具） |
| **语言** | 必须使用 TypeScript，`<script setup lang="ts">` |
| **组件结构** | `<template>` → `<script setup>` → `<style scoped>` |
| **状态管理** | 跨组件用 Pinia，组件内用 `ref`/`reactive` |
| **Props 定义** | 必须使用 `defineProps<T>()` 或 `withDefaults` |
| **API 请求** | 统一封装 axios，放在 `api/` 目录 |
| **避免 any** | 除非无法确定类型，否则禁止使用 `any` |

**Vue 组件示例**：

```vue
<template>
  <div class="user-list">
    <el-table :data="users" v-loading="loading">
      <el-table-column prop="name" label="姓名" />
      <el-table-column prop="email" label="邮箱" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUserList } from '@/api/modules/user'
import type { UserVO } from '@/types/user'

const users = ref<UserVO[]>([])
const loading = ref(false)

const fetchUsers = async () => {
  loading.value = true
  try {
    const res = await getUserList()
    users.value = res.data
  } finally {
    loading.value = false
  }
}

onMounted(() => fetchUsers())
</script>

<style scoped>
.user-list {
  padding: 20px;
}
</style>
```

### 3.3 TypeScript 类型规范

| 规范项 | 规则 |
|--------|------|
| **类型定义** | `src/types/` 目录存放全局类型 |
| **API 响应类型** | 必须为每个 API 定义响应类型 |
| **组件 Props** | 使用 `defineProps<{ ... }>()` 定义类型 |
| **避免 any** | 使用 `unknown` 或具体类型替代 `any` |

---

## 四、API 接口规范

### 4.1 统一响应格式

```json
{
  "code": 200,
  "message": "操作成功",
  "data": { ... }
}
```

**Java 响应类**：

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Result<T> {
    private Integer code;
    private String message;
    private T data;
    
    public static <T> Result<T> success(T data) {
        return new Result<>(200, "操作成功", data);
    }
    
    public static <T> Result<T> error(String message) {
        return new Result<>(500, message, null);
    }
}
```

### 4.2 RESTful API 设计

| 操作 | HTTP 方法 | URL 示例 |
|------|-----------|----------|
| 查询列表 | GET | `/api/v1/users?pageNum=1&pageSize=10` |
| 查询详情 | GET | `/api/v1/users/{id}` |
| 新增 | POST | `/api/v1/users` |
| 更新 | PUT | `/api/v1/users/{id}` |
| 删除 | DELETE | `/api/v1/users/{id}` |

### 4.3 分页请求规范

| 参数 | 名称 | 说明 |
|------|------|------|
| 页码 | `pageNum` | 从 1 开始 |
| 每页大小 | `pageSize` | 默认 10，最大 100 |

**分页响应**：
```json
{
  "code": 200,
  "data": {
    "list": [...],
    "total": 100,
    "pageNum": 1,
    "pageSize": 10
  }
}
```

### 4.4 HTTP 状态码

| 状态码 | 使用场景 |
|--------|----------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 未登录/Token 失效 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 五、数据库设计规范

### 5.1 命名规范

| 规范项 | 规则 | 示例 |
|--------|------|------|
| **数据库名** | 小写+下划线 | `my_openspec_db` |
| **表名** | 小写+下划线，单数形式 | `user`、`user_profile` |
| **字段名** | 小写+下划线 | `created_time`、`user_name` |
| **主键** | `id`（UUID） | `id VARCHAR(64) PRIMARY KEY` |
| **索引命名** | `idx_表名_字段名` | `idx_user_email` |
| **唯一索引** | `uk_表名_字段名` | `uk_user_phone` |

### 5.2 通用字段

所有表必须包含以下通用字段：

```sql
id            VARCHAR(64) PRIMARY KEY COMMENT '主键ID（UUID）',
created_time  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
updated_time  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
is_deleted    TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除 0-否 1-是',
deleted_time  DATETIME NULL DEFAULT NULL COMMENT '删除时间（软删除）',
created_user  VARCHAR(64) COMMENT '创建人',
updated_user  VARCHAR(64) COMMENT '更新人'
```

### 5.3 建表规范

- 字段必须添加 `COMMENT`
- 主键使用 **UUID**（`VARCHAR(64)`），不使用 `BIGINT` 自增
- 时间字段使用 `DATETIME`，不用 `TIMESTAMP`
- 文本字段根据长度选择 `VARCHAR`、`TEXT`、`LONGTEXT`
- 状态/类型字段使用 `TINYINT`，添加注释说明枚举值

### 5.4 Flyway 数据库版本管理

> 本项目使用 Flyway 管理数据库结构变更。

#### 目录位置

```
backend/src/main/resources/db/migration/
├── V1__init_database.sql
├── V2__add_email_to_user.sql
└── ...
```

#### 命名规则

| 格式 | 说明 | 示例 |
|------|------|------|
| `V{版本号}__{描述}.sql` | 版本号从 1 开始递增，描述用下划线分隔单词 | `V1__create_user_table.sql` |

#### 编写规范

1. **每个 SQL 文件只做一件事**（建一张表 / 加一个字段 / 改一个索引）
2. **必须可重复执行**（幂等）：
   - 建表：`CREATE TABLE IF NOT EXISTS`
   - 加字段：`ALTER TABLE ADD COLUMN IF NOT EXISTS`
3. **禁止修改已执行的迁移文件**（Flyway 会校验 checksum）
4. 回滚通过新增迁移文件实现，**不删除已执行的迁移**

#### Maven 依赖（pom.xml）

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-mysql</artifactId>
</dependency>
```

#### Spring Boot 配置（application.yml）

```yaml
spring:
  flyway:
    enabled: true
    baseline-on-migrate: true
    locations: classpath:db/migration
    encoding: UTF-8
```

#### 常用命令

```bash
mvn flyway:migrate    # 执行所有待执行的迁移
mvn flyway:info       # 查看当前版本状态
mvn flyway:validate   # 校验迁移文件是否被篡改
```

---

## 六、Git 工作流

### 6.1 分支命名规范

| 分支类型 | 命名格式 | 示例 |
|----------|----------|------|
| 主分支 | `main` | 线上稳定代码 |
| 开发分支 | `develop` | 集成分支 |
| 功能分支 | `feature/描述` | `feature/add-pomodoro-timer` |
| 修复分支 | `bugfix/描述` | `bugfix/fix-login-error` |
| 发布分支 | `release/v版本号` | `release/v1.0.0` |

### 6.2 Commit 规范（Conventional Commits）

```
<type>(<scope>): <subject>
```

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 Bug |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构 |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具/依赖更新 |

**示例**：
```
feat(timer): 添加番茄钟计时器核心功能

- 实现 25 分钟倒计时逻辑
- 添加开始/暂停/重置按钮
- 完成时触发提示音

Closes #123
```

---

## 七、AGENTS.md 与 OpenSpec 的关系

### 7.1 两者的定位

| 文件 | 作用 | 范围 |
|------|------|------|
| `AGENTS.md` | **全局规则**：技术栈、编码风格、项目结构约定 | 整个项目的所有开发活动 |
| `openspec/specs/` | **功能规范**：具体功能的验收场景 | 按功能模块独立维护 |

### 7.2 如何协同工作

1. **`AGENTS.md` 是基础约束**：AI 在生成代码和规范时，必须遵循本文档的所有约定
2. **`openspec/specs/` 是功能说明书**：描述"系统应该做什么"，而非"怎么做"
3. **冲突时的优先级**：`openspec/specs/` 中的功能需求优先于 `AGENTS.md` 中的通用约定

### 7.3 AGENTS.md 的加载机制

- OpenCode / Trae / Cursor 会自动从**项目根目录**向上查找并加载 `AGENTS.md`
- VS Code 需要开启 `chat.useAgentsMdFile` 配置
- 每次新会话启动时，AI 重新读取最新版本
- 修改后**不需要重启 IDE**，新会话自动生效

### 7.4 OpenSpec 标准工作流（如使用 OpenCode）

| 命令 | 用途 |
|------|------|
| `/opsx:propose` | 创建变更提案 + 规范文档 |
| `/opsx:apply` | 按 `tasks.md` 实现代码 |
| `/opsx:verify` | 验证实现是否符合规范 |
| `/opsx:archive` | 归档并更新主规范库 |

---

## 八、日志规范

### 8.1 日志级别使用指南

| 级别 | 使用场景 |
|------|----------|
| **ERROR** | 系统错误、异常堆栈，需要人工介入 |
| **WARN** | 非预期但可恢复的情况 |
| **INFO** | 关键业务节点：登录、订单创建、定时任务 |
| **DEBUG** | 开发调试信息，生产环境关闭 |

**示例**：
```java
@Slf4j
@Service
public class UserService {
    public UserVO getUserById(Long id) {
        log.info("查询用户信息, userId={}", id);
        try {
            // 业务逻辑
        } catch (Exception e) {
            log.error("查询用户信息失败, userId={}", id, e);
            throw new BusinessException("用户不存在");
        }
    }
}
```

### 8.2 日志脱敏

敏感信息（手机号、身份证、密码）在日志中必须脱敏：

```java
// 手机号脱敏：138****1234
log.info("用户登录, phone={}", phone.replaceAll("(\\d{3})\\d{4}(\\d{4})", "$1****$2"));
```

---

## 九、安全规范

### 9.1 后端安全

| 规范项 | 要求 |
|--------|------|
| **SQL 注入** | 使用 MyBatis 参数绑定 `#{}`，禁止字符串拼接 |
| **密码存储** | 使用 BCrypt 加密，禁止 MD5 |
| **JWT Token** | 过期时间 2小时，配置刷新机制 |
| **参数校验** | 使用 `@Valid` + 校验注解 |
| **敏感信息** | 日志中脱敏手机号、身份证 |

### 9.2 前端安全

| 规范项 | 要求 |
|--------|------|
| **XSS 防护** | 避免使用 `v-html` 渲染用户输入 |
| **CSRF 防护** | 使用 Token 机制或 SameSite Cookie |
| **敏感存储** | Token 使用 httpOnly Cookie，不使用 localStorage |

---

## 十、测试规范

### 10.1 测试命名

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| Java 单元测试 | `XxxTest` | `UserServiceTest.java` |
| Java 集成测试 | `XxxIT` | `UserControllerIT.java` |
| Vue 组件测试 | `Xxx.spec.ts` | `UserList.spec.ts` |

### 10.2 测试覆盖率要求

- 后端：核心 Service ≥ 80%，Controller ≥ 60%
- 前端：工具函数 100%，组件核心交互 ≥ 70%

---

## 十一、常用开发命令

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

### Docker（可选）

```bash
docker run -d --name mysql-dev -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:8.0
docker-compose up -d
```

---

## 十二、环境配置

### 后端多环境

```yaml
# application.yml
spring:
  profiles:
    active: dev

# application-dev.yml
server:
  port: 8080
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/project_dev
```

### 前端环境变量

```bash
# .env.development
VITE_API_BASE_URL=http://localhost:8080/api

# .env.production
VITE_API_BASE_URL=https://api.example.com
```
