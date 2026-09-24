export interface DeployVO {
  id: string;
  /** 所属系统ID */
  assetId: string;
  /** 模块名称 */
  moduleName: string;
  /** 部署应用 */
  deployApp: string;
  /** 主机名 */
  hostName: string;
  /** IP地址 */
  ipAddress: string;
  /** 容器IP */
  containerIp: string;
  /** 链接模版 */
  linkTemplate: string;
  /** 机房 */
  idc: string;
  /** CPU（核） */
  cpuCores: number;
  /** 内存（G） */
  memoryGb: number;
  /** 系统盘（G） */
  sysDiskGb: number;
  /** 数据盘（G） */
  dataDiskGb: number;
  /** 操作系统 */
  osInfo: string;
  /** 快照备份需求 */
  snapshotNeed: string;
  /** 服务器类型 */
  serverType: string;
  /** 节点数量 */
  nodeCount: number;
  /** 租户 */
  tenant: string;
  /** VPC */
  vpc: string;
  /** 安全组 */
  securityGroup: string;
  /** 应用描述 */
  appDesc: string;
  /** 系统环境 1-生产 2-测试 3-开发 */
  sysEnv: number;
  /** 运行环境 */
  runtimeEnv: string;
  /** 部署网段 */
  deploySubnet: string;
  /** 路径信息 */
  pathInfo: string;
  /** 文件挂载 */
  fileMount: string;
  /** 是否涉及批量操作 0-否 1-是 */
  batchOpFlag: number;
  /** 批量调度平台 */
  batchSchedPlatform: string;
  /** 是否纳入应用监控 0-否 1-是 */
  appMonitorFlag: number;
  /** 网络QoS策略 */
  networkQos: string;
  /** 域名 */
  domainName: string;
  /** 国产化 0-否 1-是 */
  domesticFlag: number;
  /** ETL工具 */
  etlTool: string;
  /** 备注 */
  remark: string;
}

export interface DeployForm {
  id?: string;
  assetId: string;
  moduleName: string;
  deployApp: string;
  hostName: string;
  ipAddress: string;
  containerIp?: string;
  linkTemplate?: string;
  idc?: string;
  cpuCores?: number;
  memoryGb?: number;
  sysDiskGb?: number;
  dataDiskGb?: number;
  osInfo?: string;
  snapshotNeed?: string;
  serverType?: string;
  nodeCount?: number;
  tenant?: string;
  vpc?: string;
  securityGroup?: string;
  appDesc?: string;
  sysEnv: number;
  runtimeEnv?: string;
  deploySubnet?: string;
  pathInfo?: string;
  fileMount?: string;
  batchOpFlag?: number;
  batchSchedPlatform?: string;
  appMonitorFlag?: number;
  networkQos?: string;
  domainName?: string;
  domesticFlag?: number;
  etlTool?: string;
  remark?: string;
}

export interface DeployQuery {
  assetId: string;
  sysEnv?: number;
}
