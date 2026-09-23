# asset-registry-shell Specification

## Purpose

定义系统详情页的容器框架能力：进入单系统后以 Tab 组织「基础信息」及后续资产子表（部署信息、接口依赖、数据库、中间件、网络策略、备份策略、配置项、数据分布、文件交换、技术栈、架构图等），本次仅承载「基础信息」Tab，为后续每个 Tab 的独立 change 提供稳定的宿主与插入点。

## Requirements

### Requirement: 详情页 Tab 导航

系统 SHALL 在详情页顶部提供 Tab 导航，Tab 顺序为：基础信息、部署信息、接口依赖、数据库、中间件、网络策略、备份策略、配置项、数据分布、文件交换、技术栈、架构图。当前变更仅实现「基础信息」Tab 的内容，其余 Tab 在详情页中可见但标注为未开放。

#### Scenario: 打开详情页显示 Tab 导航
- **WHEN** 用户进入某个系统的详情页
- **THEN** 页面顶部展示完整的 Tab 栏，首个「基础信息」Tab 处于激活态并显示其内容

#### Scenario: 点击未开放 Tab
- **WHEN** 用户点击尚未实现的 Tab（如"部署信息"）
- **THEN** 系统提示该能力未开放（如"建设中"），不报错、不跳空页

#### Scenario: Tab 切换保留宿主上下文
- **WHEN** 用户在不同 Tab 间切换
- **THEN** 都不离开当前系统的详情上下文，URL 保持指向该系统

### Requirement: Tab 内容插入点

系统 SHALL 为每个 Tab 提供明确的组件插入点，使后续 change 能以最小改动挂载新的子表组件，而无需改动详情页框架与既有 Tab。

#### Scenario: 新增 Tab 内容组件
- **WHEN** 后续 change 实现了某个 Tab（如"数据库"）的内容组件
- **THEN** 通过框架约定位置注册即可展示，无需重写详情页骨架

#### Scenario: Tab 内容与子表数据隔离
- **WHEN** 用户在已开放 Tab 中操作数据
- **THEN** 数据仅作用于该 Tab 对应的子表，不污染其他 Tab 与系统基础信息

## 说明

- 本能力定义的是宿主容器而非业务内容，业务内容由 `system-registration`（基础信息）及后续各 Tab change 提供。
