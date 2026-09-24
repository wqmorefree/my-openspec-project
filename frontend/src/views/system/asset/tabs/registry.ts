import { defineAsyncComponent } from 'vue';
import type { Component } from 'vue';

/**
 * 系统详情页 12-Tab 组件注册表（ADR-006 tab-host-registry）。
 *
 * 后续变更的每个 Tab 只需在本表新增 { key, label, component } 一项即可挂载，
 * 宿主框架（detail.vue）零改动；未注册的 Tab 自动展示「建设中」占位。
 */
export interface AssetTabDefinition {
  /** Tab 唯一标识（对应子表领域） */
  key: string;
  /** 展示名称 */
  label: string;
  /** 内容组件；缺省表示未开放（建设中占位） */
  component?: Component;
}

export const TABS: AssetTabDefinition[] = [
  { key: 'basic-info', label: '基础信息', component: defineAsyncComponent(() => import('./basic-info.vue')) },
  { key: 'deploy-info', label: '部署信息', component: defineAsyncComponent(() => import('./deploy-info.vue')) },
  { key: 'interface-dep', label: '接口依赖' },
  { key: 'database', label: '数据库' },
  { key: 'middleware', label: '中间件' },
  { key: 'network-policy', label: '网络策略' },
  { key: 'backup-policy', label: '备份策略' },
  { key: 'config-item', label: '配置项' },
  { key: 'data-distribution', label: '数据分布' },
  { key: 'file-exchange', label: '文件交换' },
  { key: 'tech-stack', label: '技术栈' },
  { key: 'architecture', label: '架构图' }
];
