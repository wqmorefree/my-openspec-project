import type { FormRules } from 'element-plus';
import type { AssetForm } from '@/api/system/asset/types';

/**
 * 资产表单初始数据（工厂函数，避免多处共享同一引用）
 */
export const createAssetFormData = (): AssetForm => ({
  id: undefined,
  code: '',
  name: '',
  bizDomain: '',
  owner: '',
  status: 1,
  projectName: '',
  projectNo: '',
  leaderName: '',
  leaderMobile: '',
  pmName: '',
  pmMobile: '',
  intro: '',
  category: '',
  svnDocUrl: '',
  gitCodeUrl: '',
  moduleName: '',
  branchName: '',
  branchDesc: '',
  branchUrl: ''
});

/**
 * 资产表单统一校验规则（列表新增/编辑弹窗与详情基础信息 Tab 共用，字段演进只改一处）
 */
export const assetFormRules: FormRules = {
  code: [{ required: true, message: '系统编码不能为空', trigger: 'blur' }],
  name: [{ required: true, message: '系统名称不能为空', trigger: 'blur' }],
  bizDomain: [{ required: true, message: '所属业务域不能为空', trigger: 'blur' }],
  owner: [{ required: true, message: '负责人不能为空', trigger: 'blur' }],
  status: [{ required: true, message: '状态不能为空', trigger: 'change' }]
};
