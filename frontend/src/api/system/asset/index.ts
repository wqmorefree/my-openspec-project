import type { PageResult } from '@/api/types';
import type { AxiosPromise } from '@/utils/api-types';
import request from '@/utils/request';
import type { AssetForm, AssetQuery, AssetVO } from './types';

// 查询系统技术资产列表
export function listAsset(query: AssetQuery): AxiosPromise<PageResult<AssetVO>> {
  return request({
    url: '/system/asset/list',
    method: 'get',
    params: query
  });
}

// 查询系统技术资产详细
export function getAsset(id: string | number): AxiosPromise<AssetVO> {
  return request({
    url: '/system/asset/' + id,
    method: 'get'
  });
}

// 新增系统技术资产
export function addAsset(data: AssetForm) {
  return request({
    url: '/system/asset',
    method: 'post',
    data: data
  });
}

// 修改系统技术资产
export function updateAsset(data: AssetForm) {
  return request({
    url: '/system/asset',
    method: 'put',
    data: data
  });
}

// 删除系统技术资产（逻辑删除，仅管理员）
export function delAsset(ids: string | number | (string | number)[]) {
  return request({
    url: '/system/asset/' + ids,
    method: 'delete'
  });
}

// 按当前筛选条件导出 CSV（GET 流式下载）
export function exportAsset(query: AssetQuery) {
  return request({
    url: '/system/asset/export',
    method: 'get',
    params: query,
    responseType: 'blob',
    timeout: 60000
  });
}