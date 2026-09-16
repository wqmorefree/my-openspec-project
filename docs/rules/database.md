# 数据库设计规范（KingbaseES V8R6）

> 适用于所有表设计、Mapper、SQL 和 Flyway 迁移。
>
> **数据库策略**：开发与部署环境统一使用 **KingbaseES V8R6（人大金仓）**，遵循信创合规要求。

---

## 📌 概要总结

**必须遵守的核心规则：**

| 类别 | 核心规则 |
|------|----------|
| **主键** | UUID（`VARCHAR(64)`），不用自增 |
| **通用字段** | 所有表必须含 `id` / `created_time` / `updated_time` / `is_deleted` |
| **命名** | 表名、字段名全小写+下划线，单数形式；**模式名必须小写** |
| **注释** | 所有字段必须加 `COMMENT` |
| **迁移** | Flyway 管理，`V{版本号}__{描述}.sql`，禁止修改已执行的文件 |
| **SQL** | 禁止 `SELECT *`，禁止 WHERE 中对字段做函数运算 |
| **类型转换** | 必须使用显式 `CAST` 或 `::`，禁止隐式转换 |
| **国密加密** | 敏感字段使用 **kbcrypto 插件的 SM4 加密** |
| **驱动区分** | 业务用 `com.kingbase8.Driver`，Flyway 用 `org.postgresql.Driver` |

**禁止事项：**
- ❌ 使用 MySQL 特有语法（如 `AUTO_INCREMENT`、`GROUP_CONCAT`）
- ❌ 使用 `pg_` 前缀访问系统表（Kingbase 使用 `sys_` 前缀）
- ❌ 字段不加 `COMMENT`
- ❌ 使用 `DATETIME`（用 `TIMESTAMP`）
- ❌ 修改已执行的 Flyway 迁移文件
- ❌ 在迁移脚本中使用 Oracle 模式的 PL/SQL 语法

---

## 一、数据库信息

| 项目 | 值 |
|------|-----|
| **数据库** | KingbaseES V8R6（人大金仓） |
| **内核基础** | PostgreSQL 9.6 |
| **JDBC 驱动类（业务连接）** | `com.kingbase8.Driver` |
| **连接串格式（业务连接）** | `jdbc:kingbase8://localhost:54321/database` |
| **JDBC 驱动类（Flyway）** | `org.postgresql.Driver` |
| **连接串格式（Flyway）** | `jdbc:postgresql://localhost:54321/database` |
| **默认端口** | 54321 |
| **字符集** | UTF8 |
| **系统表前缀** | `sys_`（而非 PostgreSQL 的 `pg_`） |
| **国密支持** | kbcrypto 插件（SM3/SM4） |
| **大小写敏感参数** | `enable_ci`（V8R6，替代 V8R3 的 `case_sensitive`） |

> **重要**：业务代码使用 Kingbase 官方驱动连接，**Flyway 必须使用 PostgreSQL 驱动连接**（详见第五章）。

### 为什么用 UUID 而不是自增 ID

| 理由 | 说明 |
|------|------|
| **迁移友好** | 无需调整主键策略 |
| **分布式友好** | 未来多节点不会冲突 |
| **安全** | 不暴露 ID 增长规律 |
| **兼容性** | V8R6 支持 `uuid` 数据类型 |

> **注意**：虽然 V8R6 支持 `uuid` 类型，但 MyBatis-Plus 的 `IdType.ASSIGN_UUID` 生成的是 `String`，为保证映射兼容性，**主键使用 `VARCHAR(64)`**。

---

## 二、命名规范

| 规范项 | 规则 | 示例 |
|--------|------|------|
| **数据库名** | 小写+下划线 | `asset_db` |
| **模式名** | **必须小写**（V8R6 要求） | `public`、`asset` |
| **表名** | 小写+下划线，单数形式 | `user`、`asset` |
| **字段名** | 小写+下划线 | `created_time`、`user_name` |
| **主键** | `id` | `id VARCHAR(64) PRIMARY KEY` |
| **索引命名** | `idx_表名_字段名` | `idx_user_email` |
| **唯一索引** | `uk_表名_字段名` | `uk_user_phone` |
| **外键** | `fk_表名_引用表名` | `fk_asset_user` |

> **V8R6 特别注意**：`search_path` 中的模式名必须写成小写，如 `SET search_path TO "user", public;`。

---

## 三、通用字段

所有表**必须**包含以下通用字段：

```sql
id            VARCHAR(64) PRIMARY KEY COMMENT '主键ID（UUID）',
created_time  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
updated_time  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
is_deleted    SMALLINT NOT NULL DEFAULT 0 COMMENT '是否删除 0-否 1-是',
deleted_time  TIMESTAMP NULL DEFAULT NULL COMMENT '删除时间（软删除）',
created_user  VARCHAR(64) COMMENT '创建人',
updated_user  VARCHAR(64) COMMENT '更新人'
```

**注意**：
- 时间类型使用 `TIMESTAMP`（KingbaseES 不支持 MySQL 的 `DATETIME`）
- 状态字段使用 `SMALLINT`（KingbaseES 支持 `BOOLEAN`，但为兼容性考虑用 `SMALLINT`）

---

## 四、建表规范

### 4.1 基本要求

- 字段必须添加 `COMMENT`
- 主键使用 **UUID**（`VARCHAR(64)`），不使用自增
- 时间字段使用 `TIMESTAMP`
- 文本字段根据长度选择 `VARCHAR`、`TEXT`
- 状态/类型字段使用 `SMALLINT`，添加注释说明枚举值
- 表必须添加 `COMMENT`

### 4.2 字段类型选择

| 场景 | 类型 | 说明 |
|------|------|------|
| 主键 | `VARCHAR(64)` | UUID |
| 短字符串 | `VARCHAR(64)` / `VARCHAR(128)` | 用户名、邮箱 |
| 长文本 | `TEXT` | 描述、内容 |
| 整数 | `INTEGER` / `BIGINT` | 数量、ID 引用 |
| 小数 | `NUMERIC(m,n)` | 金额 |
| 布尔 | `BOOLEAN` 或 `SMALLINT` | 推荐 `SMALLINT` 兼容性更好 |
| 时间 | `TIMESTAMP` | 创建/更新时间 |
| 日期 | `DATE` | 仅日期 |
| JSON | `jsonb` | 推荐 `jsonb`（性能更好） |
| UUID | `uuid` | V8R6 原生支持 |

### 4.3 建表示例

```sql
CREATE TABLE IF NOT EXISTS asset (
    id            VARCHAR(64) PRIMARY KEY,
    asset_name    VARCHAR(128) NOT NULL,
    asset_type    VARCHAR(64) NOT NULL,
    ip_address    VARCHAR(64),
    secret_key    VARCHAR(256),
    status        SMALLINT NOT NULL DEFAULT 1,
    created_time  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted    SMALLINT NOT NULL DEFAULT 0,
    deleted_time  TIMESTAMP NULL DEFAULT NULL,
    created_user  VARCHAR(64),
    updated_user  VARCHAR(64)
);

COMMENT ON TABLE asset IS '技术资产表';
COMMENT ON COLUMN asset.asset_name IS '资产名称';
COMMENT ON COLUMN asset.asset_type IS '资产类型';
COMMENT ON COLUMN asset.ip_address IS 'IP地址（不加密）';
COMMENT ON COLUMN asset.secret_key IS '资产密钥（SM4加密存储）';
COMMENT ON COLUMN asset.status IS '状态 1-正常 0-禁用';

CREATE UNIQUE INDEX uk_asset_ip ON asset (ip_address) WHERE is_deleted = 0;
CREATE INDEX idx_asset_status ON asset (status);
```

---

## 五、Flyway 数据库版本管理

### 5.1 适配说明

> **关键点**：KingbaseES 适配 Flyway 需要**使用 PostgreSQL 形态的驱动和连接串**。
>
> - **业务代码**：`com.kingbase8.Driver` + `jdbc:kingbase8://`
> - **Flyway**：`org.postgresql.Driver` + `jdbc:postgresql://`

### 5.2 目录位置

```
backend/src/main/resources/db/migration/
├── V1__init_database.sql
├── V2__add_asset_table.sql
└── ...
```

### 5.3 命名规则

| 格式 | 说明 | 示例 |
|------|------|------|
| `V{版本号}__{描述}.sql` | 版本号从 1 递增，描述用下划线分隔 | `V1__create_user_table.sql` |

**注意**：`V` 后是**两个下划线** `__`。

### 5.4 编写规范

1. **每个 SQL 文件只做一件事**（建一张表 / 加一个字段 / 改一个索引）
2. **必须可重复执行**（幂等）：
   - 建表：`CREATE TABLE IF NOT EXISTS`
   - 加字段：`ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
3. **禁止修改已执行的迁移文件**（Flyway 会校验 checksum）
4. 回滚通过新增迁移文件实现，**不删除已执行的迁移**
5. **禁止使用 Oracle 模式的 PL/SQL 语法**（KingbaseES 使用 Flyway 时暂不支持）

### 5.5 Maven 依赖

```xml
<!-- Flyway 核心 -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
    <version>6.4.1</version>
</dependency>

<!-- PostgreSQL 驱动（给 Flyway 用） -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.6.0</version>
</dependency>

<!-- Kingbase 官方驱动（给业务代码用） -->
<dependency>
    <groupId>com.kingbase8</groupId>
    <artifactId>kingbase8</artifactId>
    <version>8.6.0</version>
</dependency>
```

**安装 Kingbase JDBC 驱动到本地仓库**：

```bash
mvn install:install-file \
  -Dfile=libs/kingbase8-8.6.0.jar \
  -DgroupId=com.kingbase8 \
  -DartifactId=kingbase8 \
  -Dversion=8.6.0 \
  -Dpackaging=jar
```

### 5.6 Spring Boot 配置

```yaml
spring:
  # 业务数据源：使用 Kingbase 官方驱动
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
    encoding: UTF-8
    clean-disabled: true  # 禁止 clean 操作（生产环境重要）
```

> **注意**：必须为 Flyway 单独配置 `url` / `user` / `password`，否则 Flyway 会尝试用 Kingbase 驱动连接，导致迁移失败。

### 5.7 常用命令

```bash
mvn flyway:migrate    # 执行所有待执行的迁移
mvn flyway:info       # 查看当前版本状态
mvn flyway:validate   # 校验迁移文件是否被篡改
mvn flyway:clean      # 清空数据库（⚠️ 仅开发环境）
```

### 5.8 注意事项

| 事项 | 说明 |
|------|------|
| **驱动区分** | 业务用 `com.kingbase8.Driver`，Flyway 用 `org.postgresql.Driver` |
| **连接串区分** | 业务用 `jdbc:kingbase8://`，Flyway 用 `jdbc:postgresql://` |
| **PL/SQL 语法** | 迁移脚本禁止使用 Oracle 模式的 PL/SQL 语法 |
| **系统表差异** | V8R6 版本保留了 `pg_` 开头的内置表，创建 `flyway_schema_history` 表时不会报错 |
| **clean 禁用** | 生产环境必须设置 `clean-disabled: true` |

---

## 六、KingbaseES V8R6 SQL 编写规范

### 6.1 系统表前缀

KingbaseES V8R6 使用 `sys_` 前缀，而不是 PostgreSQL 的 `pg_` 前缀：

```sql
-- ✅ 正确
SELECT * FROM sys_tables WHERE schemaname = 'public';

-- ❌ 错误（PostgreSQL 语法）
SELECT * FROM pg_tables WHERE schemaname = 'public';
```

### 6.2 显式类型转换

KingbaseES V8R6 对隐式类型转换更严格，必须显式转换：

```sql
-- ✅ 正确：JSONB 取值是 text，显式转数值再比较
SELECT * FROM asset WHERE (asset_info ->> 'level')::INTEGER >= 3;
SELECT * FROM asset WHERE CAST(asset_info ->> 'level' AS INTEGER) >= 3;

-- ❌ 错误（text 与数值直接比较，V8R6 隐式转换可能报错）
SELECT * FROM asset WHERE asset_info ->> 'level' >= 3;
```

> 说明：`->>` 从 `jsonb` 取出的值是 `text` 类型，与数值比较时必须显式 `::INTEGER`（或 `CAST`）。其它需要显式转换的常见场景：`VARCHAR` ↔ `NUMERIC`、字符串 → `TIMESTAMP`。

### 6.3 字符串拼接

使用 `||` 而非 MySQL 的 `CONCAT`：

```sql
-- ✅ 正确
SELECT first_name || ' ' || last_name AS full_name FROM user;

-- ✅ 也可用（KingbaseES 支持 CONCAT 函数）
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM user;
```

### 6.4 空值处理

使用 `COALESCE` 而非 MySQL 的 `IFNULL`：

```sql
-- ✅ 正确
SELECT COALESCE(phone, '未填写') FROM user;

-- ❌ 错误（MySQL 语法）
SELECT IFNULL(phone, '未填写') FROM user;
```

### 6.5 分组拼接

使用 `STRING_AGG` 而非 MySQL 的 `GROUP_CONCAT`：

```sql
-- ✅ 正确
SELECT dept_id, STRING_AGG(user_name, ',') 
FROM user 
GROUP BY dept_id;
```

### 6.6 国密加密函数

V8R6 通过 **kbcrypto 插件**支持国密算法。使用前需先加载扩展：

```sql
-- 加载 kbcrypto 扩展
CREATE EXTENSION kbcrypto;
```

#### SM3 哈希

```sql
SELECT sm3('password');
```

#### SM4 加解密

`sm4(data, key, flag)` 函数用于 SM4 加解密：

| 参数 | 说明 |
|------|------|
| `data` | 待加解密的数据 |
| `key` | 密钥（16 字节） |
| `flag` | 加解密标识：**0-加密，1-解密**（官方标准） |

```sql
-- 加密（flag = 0）
SELECT sm4('secret_data', '0123456789ABCDEF', 0);

-- 解密（flag = 1）
SELECT sm4(encrypted_data, '0123456789ABCDEF', 1);

-- 验证：加密后再解密应还原
SELECT sm4(sm4('secret_data', '0123456789ABCDEF', 0), '0123456789ABCDEF', 1);
```

> **说明**：`flag` 参数是 KingbaseES kbcrypto 插件的官方标准定义，0 表示加密，1 表示解密。

> **注意**：kbcrypto 默认已添加到 `shared_preload_libraries` 中，重启数据库时自动加载，但仍需手动执行 `CREATE EXTENSION kbcrypto;`。

### 6.7 大小写敏感

| 版本 | 参数 | 说明 |
|------|------|------|
| V8R3 | `case_sensitive` | — |
| V8R6 | `enable_ci` | 控制大小写敏感 |

**模式名必须小写**：

```sql
-- ✅ 正确
SET search_path TO "user", public;

-- ❌ 错误（V8R6 中模式名必须小写）
SET search_path TO "USER", PUBLIC;
```

### 6.8 SQL 编写规范

| 规范项 | 规则 |
|--------|------|
| **禁止** | `SELECT *`，必须列出字段 |
| **分页** | 使用 MyBatis-Plus `Page` 对象 |
| **批量** | 使用 `saveBatch` / `updateBatchById` |
| **索引** | WHERE / ORDER BY 字段必须有索引 |
| **禁止** | 在 WHERE 中对字段做函数运算 |
| **参数绑定** | 使用 `#{}`，禁止 `${}` 拼接 |
| **类型转换** | 必须显式 `CAST` 或 `::` |
| **字符串拼接** | 使用 `\|\|` 或 `CONCAT` |
| **空值处理** | 使用 `COALESCE` |
| **分组拼接** | 使用 `STRING_AGG` |

---

## 七、ORM 规范（MyBatis-Plus）

### 7.1 实体类规范

```java
@Data
@TableName("asset")
public class AssetEntity {
    
    @TableId(type = IdType.ASSIGN_UUID)
    private String id;
    
    private String assetName;
    
    private String assetType;
    
    private String ipAddress;
    
    @TableField(typeHandler = Sm4TypeHandler.class)
    private String secretKey;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdTime;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedTime;
    
    @TableLogic
    private Integer isDeleted;
}
```

### 7.2 规范要求

| 规范项 | 规则 |
|--------|------|
| **主键** | `@TableId(type = IdType.ASSIGN_UUID)` |
| **逻辑删除** | `@TableLogic` 注解，字段 `is_deleted` |
| **自动填充** | `created_time` / `updated_time` 用 `@TableField(fill = ...)` |
| **敏感字段** | 使用 `@TableField(typeHandler = Sm4TypeHandler.class)` |
| **表名映射** | 用 `@TableName` 显式指定 |
| **Mapper** | 接口继承 `BaseMapper<T>` |

### 7.3 分页配置（Kingbase）

```java
@Configuration
public class MybatisPlusConfig {
    
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        // Kingbase 分页插件（金仓兼容 PostgreSQL 方言）
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.POSTGRE_SQL));
        return interceptor;
    }
}
```

### 7.4 Sm4TypeHandler（数据库层 kbcrypto 自动加解密）

> 敏感字段（手机号、身份证、资产密钥）通过 `Sm4TypeHandler` 调用**数据库层 kbcrypto 的 `sm4()` 函数**完成加解密：
> - **写入**：先执行 `SELECT sm4(?, ?, 0)` 得到密文，再写入参数（flag=0 加密）
> - **读取**：实体字段取到的是密文，再执行 `SELECT sm4(?, ?, 1)` 还原明文（flag=1 解密）
>
> 加解密都在数据库内计算，应用层只有 TypeHandler 编排，密钥通过环境变量注入。

```java
package com.openspec.project.common.typehandler;

import cn.hutool.core.util.StrUtil;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;

import java.sql.*;

/**
 * 敏感字段 SM4 加解密 TypeHandler
 *
 * 加密/解密均在数据库层（kbcrypto 插件）完成：
 * INSERT: SELECT sm4(?, ?, 0) 生成密文后落库
 * SELECT: SELECT sm4(?, ?, 1) 解密还原明文
 */
@MappedJdbcTypes(JdbcType.VARCHAR)
public class Sm4TypeHandler extends BaseTypeHandler<String> {

    /** 密钥从环境变量注入，禁止硬编码（见 security.md 第十章） */
    private static final String SM4_KEY = System.getenv("SM4_KEY");

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i,
                                    String parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, encrypt(parameter, ps.getConnection()));
    }

    @Override
    public String getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return decrypt(rs.getString(columnName), rs.getStatement().getConnection());
    }

    @Override
    public String getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return decrypt(rs.getString(columnIndex), rs.getStatement().getConnection());
    }

    @Override
    public String getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return decrypt(cs.getString(columnIndex), cs.getConnection());
    }

    /** 调用数据库 sm4() 函数加密（flag=0） */
    private String encrypt(String plain, Connection conn) throws SQLException {
        if (StrUtil.isBlank(plain)) {
            return plain;
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT sm4(?, ?, 0)")) {
            ps.setString(1, plain);
            ps.setString(2, SM4_KEY);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : plain;
            }
        }
    }

    /** 调用数据库 sm4() 函数解密（flag=1） */
    private String decrypt(String cipher, Connection conn) throws SQLException {
        if (StrUtil.isBlank(cipher)) {
            return cipher;
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT sm4(?, ?, 1)")) {
            ps.setString(1, cipher);
            ps.setString(2, SM4_KEY);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : cipher;
            }
        }
    }
}
```

> **注意**：
> - **实体类注册**：在实体字段上加 `@TableField(typeHandler = Sm4TypeHandler.class)`（见 7.1 示例）。
> - **密钥一致性**：TypeHandler 拿到的 `SM4_KEY` 必须与 kbcrypto 插件使用的密钥一致（均为 `application.yml` 中 `${SM4_KEY}` 环境变量）。
> - **查询条件**：用加密字段作为 WHERE 条件时，需对入参做同样加密，如 `WHERE secret_key = sm4(#{value}, #{sm4Key}, 0)`，且应加 `@Param` 绑定，禁止字符串拼接。
> - **排序/去重**：加密字段无法直接 `ORDER BY` / `GROUP BY` / 唯一索引（密文不稳定），需要此类能力时提前告知 DBA 另建摘要列。

---

## 八、数据类型映射

| Java 类型 | KingbaseES V8R6 类型 | 说明 |
|-----------|----------------------|------|
| `String` | `VARCHAR(n)` | 短字符串 |
| `String` | `TEXT` | 长文本 |
| `Integer` | `INTEGER` / `SMALLINT` | 整数 |
| `Long` | `BIGINT` | 长整数 |
| `BigDecimal` | `NUMERIC(m,n)` | 金额 |
| `Boolean` | `BOOLEAN` / `SMALLINT` | 布尔 |
| `LocalDateTime` | `TIMESTAMP` | 时间 |
| `LocalDate` | `DATE` | 日期 |
| `UUID` | `uuid` | UUID 类型 |
| `String` (JSON) | `jsonb` | JSON 类型 |

---

## 九、数据库连接池

| 配置项 | 推荐值 | 说明 |
|--------|--------|------|
| **连接池** | HikariCP | Spring Boot 默认 |
| **最大连接数** | 10-20 | 根据并发量调整 |
| **最小空闲连接** | 5 | — |
| **连接超时** | 30s | — |
| **空闲超时** | 10min | — |

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
```

---

## 十、备份与恢复

KingbaseES V8R6 提供以下备份工具：

| 工具 | 用途 |
|------|------|
| **sys_dump** | 逻辑备份（导出 SQL 脚本或归档文件） |
| **sys_restore** | 恢复 sys_dump 生成的归档文件 |
| **sys_dumpall** | 备份集群全局对象（角色、表空间等） |
| **sys_rman** | 物理备份（支持全量/增量） |

```bash
# 逻辑备份
sys_dump -U username -d database -f backup.sql

# 恢复
sys_restore -U username -d database backup.sql

# 备份集群全局对象
sys_dumpall -U username -f all_backup.sql
```

---

## 十一、代码格式

| 规范项 | 规则 |
|--------|------|
| SQL 关键字 | 大写（`SELECT`、`FROM`、`WHERE`） |
| 表名/字段名 | 小写+下划线 |
| 缩进 | 4 空格 |
| 分号 | 每条语句结尾加 `;` |
