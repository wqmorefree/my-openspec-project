# ADR-002：数据库接入 KingbaseES + Flyway(pg) + POSTGRE_SQL 方言

## 状态
已采纳

## 背景
数据库用金仓 V8R6（内核基于 PostgreSQL 9.6）。需要确定三层兼容方案：业务连接驱动、数据库迁移工具、MyBatis-Plus 分页方言。其中分页方言金仓官方文档同时认可 `kingbasees` 与 `postgresql` 两种写法。

## 选项

| 选型 | 优点 | 缺点 |
|------|------|------|
| 业务/迁移分开驱动（业务 kingbase8 + Flyway pg） | 各用最合适的驱动，业务走厂商驱动保证兼容；Flyway 走 pg 驱动才能被识别 | 两套连接串，配置稍多 |
| 统一用 kingbase8 驱动跑 Flyway | 一套驱动 | Flyway 无法识别金仓，迁移无法执行（官方已证实） |
| 分页方言 `DbType.KINGBASE_ES` | MyBatis-Plus 3.4+ 内置；语义上直指金仓 | 依赖 MyBatis-Plus 版本对金仓枚举的支持，低版本会报 `not found` |
| 分页方言 `DbType.POSTGRE_SQL` | 金仓官网明确"无法识别金仓故配置成 postgresql"；分页 LIMIT/OFFSET 与 PG 完全一致 | 枚举名不出现"金仓"，需要文档说明 |

## 决策
业务数据源用 `com.kingbase8.Driver`、Flyway 独立用 `org.postgresql.Driver`；分页方言固定 `DbType.POSTGRE_SQL`。

## 理由
- 金仓官方文档明确要求分页插件"配置成 postgresql"（V8R6 手册原文），这是最权威的依据。
- V8R6 内核即 PostgreSQL 9.6，`LIMIT x OFFSET y` 语法与 PG 完全一致，`POSTGRE_SQL` 方言生成的 SQL 金仓 100% 兼容，无语法损失。
- 与 AGENTS.md、config.yaml 既有约定一致，避免多文档冲突。
- 不依赖 MyBatis-Plus 对 `KINGBASE_ES` 枚举的版本支持，排除低版本兼容风险。
- 迁移脚本须补齐设施：`find_in_set` 兼容函数、全小写下划线命名、`DATETIME`→`TIMESTAMP`、规避 string/bigint 隐式比较。