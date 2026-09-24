import type { AxiosPromise } from '@/utils/api-types';
import request from '@/utils/request';
import type { DeployForm, DeployQuery, DeployVO } from './types';

// 查询系统部署节点列表（不分页）
export function listDeploy(query: DeployQuery): AxiosPromise<DeployVO[]> {
  return request({
    url: '/system/asset/deploy/list',
    method: 'get',
    params: query
  });
}

// 新增系统部署节点
export function addDeploy(data: DeployForm) {
  return request({
    url: '/system/asset/deploy',
    method: 'post',
    data: data
  });
}

// 修改系统部署节点
export function updateDeploy(data: DeployForm) {
  return request({
    url: '/system/asset/deploy',
    method: 'put',
    data: data
  });
}

// 删除系统部署节点（逻辑删除，仅管理员）
export function delDeploy(ids: string | number | (string | number)[]) {
  return request({
    url: '/system/asset/deploy/' + ids,
    method: 'delete'
  });
}

// 按当前系统导出部署节点 CSV（GET 流式下载）
export function exportDeploy(query: DeployQuery) {
  return request({
    url: '/system/asset/deploy/export',
    method: 'get',
    params: query,
    responseType: 'blob',
    timeout: 60000
  });
}

// Excel 批量导入部署节点
export function importDeploy(file: File, assetId: string) {
  const formData = new FormData();
  formData.append('file', file);
  return request({
    url: '/system/asset/deploy/import',
    method: 'post',
    params: { assetId },
    data: formData
  });
}
