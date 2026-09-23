export interface AssetVO {
  id: string;
  /** 系统编码（人工维护，不可改） */
  code: string;
  /** 系统名称 */
  name: string;
  /** 所属业务域 */
  bizDomain: string;
  /** 负责人 */
  owner: string;
  /** 状态 1-在建 2-已上线 3-已下线 4-维护中 */
  status: number;
  /** 项目名称 */
  projectName: string;
  /** 项目编号 */
  projectNo: string;
  /** 组长 */
  leaderName: string;
  /** 组长手机（SM4加密，读侧解密） */
  leaderMobile: string;
  /** 项目经理 */
  pmName: string;
  /** 项目经理手机（SM4加密，读侧解密） */
  pmMobile: string;
  /** 系统介绍 */
  intro: string;
  /** 系统类别 */
  category: string;
  /** SVN文档地址 */
  svnDocUrl: string;
  /** Git代码地址 */
  gitCodeUrl: string;
  /** 模块名 */
  moduleName: string;
  /** 分支名 */
  branchName: string;
  /** 分支描述 */
  branchDesc: string;
  /** 分支地址 */
  branchUrl: string;
  /** 创建时间 */
  createdTime: string;
  /** 更新时间 */
  updatedTime: string;
}

export interface AssetForm {
  id?: string;
  code: string;
  name: string;
  bizDomain: string;
  owner: string;
  status: number;
  projectName?: string;
  projectNo?: string;
  leaderName?: string;
  leaderMobile?: string;
  pmName?: string;
  pmMobile?: string;
  intro?: string;
  category?: string;
  svnDocUrl?: string;
  gitCodeUrl?: string;
  moduleName?: string;
  branchName?: string;
  branchDesc?: string;
  branchUrl?: string;
}

export interface AssetQuery extends PageQuery {
  /** 关键词（系统编码/系统名称模糊） */
  keyword?: string;
  /** 所属业务域 */
  bizDomain?: string;
  /** 状态 */
  status?: number;
}