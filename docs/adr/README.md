# Architecture Decision Records（ADR）索引

> 本目录集中记录本项目的**关键技术决策**。Change 的 `design.md`「技术选型」章节通过 `ADR-NNN` 编号引用本目录，决策理由集中沉淀，长期可追溯。
> **模板与编写规则见 `docs/rules/adr.md`。**

## 目录

| 编号 | 决策标题 | 状态 | 关联 Change |
|---|---|---|---|
| ADR-001 | 采用 RuoYi-Vue-Plus 6.X 单体分支作为基座 | Accepted | add-asset-registration-core |
| ADR-002 | 数据库接入 KingbaseES + Flyway(pg) + POSTGRE_SQL 方言 | Accepted | add-asset-registration-core |
| ADR-003 | 认证与权限采用 Sa-Token + JWT，权限点控删除 | Accepted | add-asset-registration-core |
| ADR-004 | 国密分层：SM2 传输 / SM3 哈希 / SM4 敏感字段(kbcrypto) | Accepted | add-asset-registration-core |
| ADR-005 | 数据模型：sys_asset 主表 + 子表独立 change | Accepted | add-asset-registration-core |
| ADR-006 | 详情页采用 Tab 宿主 + 子表组件注册表 | Accepted | add-asset-registration-core |
| ADR-007 | 导入导出：EasyExcel 导入 + CSV 流式导出 | Accepted | add-asset-registration-core |
| ADR-008 | 部署信息采用单表平铺节点模型 | Accepted | add-deploy-info-tab |