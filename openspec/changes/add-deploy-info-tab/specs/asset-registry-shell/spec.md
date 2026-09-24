# asset-registry-shell Delta

## MODIFIED Requirements

### Requirement: 详情页 Tab 导航

系统 SHALL 在详情页顶部提供 Tab 导航，Tab 顺序为：基础信息、部署信息、接口依赖、数据库、中间件、网络策略、备份策略、配置项、数据分布、文件交换、技术栈、架构图。「基础信息」与「部署信息」Tab 已开放并显示各自业务内容，其余 Tab 在详情页中可见但标注为未开放。

#### Scenario: 打开详情页显示 Tab 导航
- **WHEN** 用户进入某个系统的详情页
- **THEN** 页面顶部展示完整的 Tab 栏，首个「基础信息」Tab 处于激活态并显示其内容

#### Scenario: 点击已开放的部署信息 Tab
- **WHEN** 用户点击「部署信息」Tab
- **THEN** 面板显示该系统的部署节点表格，不显示建设中占位

#### Scenario: 点击未开放 Tab
- **WHEN** 用户点击尚未实现的 Tab（如"接口依赖"）
- **THEN** 系统提示该能力未开放（如"建设中"），不报错、不跳空页

#### Scenario: Tab 切换保留宿主上下文
- **WHEN** 用户在不同 Tab 间切换
- **THEN** 都不离开当前系统的详情上下文，URL 保持指向该系统
