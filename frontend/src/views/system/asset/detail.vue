<template>
  <div class="p-2 app-container asset-detail-page">
    <el-card shadow="hover" class="header-panel">
      <div class="detail-header">
        <div>
          <span class="panel-kicker">Asset Detail</span>
          <h3>
            {{ asset ? `${asset.code} · ${asset.name}` : '系统详情' }}
          </h3>
          <!--<p>当前系统：{{ asset?.code || '-' }} / {{ asset?.name || '-' }}</p>-->
        </div>
        <div class="header-actions">
          <el-button icon="Back" @click="handleBack">返回列表</el-button>
        </div>
      </div>
    </el-card>
    <el-card shadow="hover" class="tabs-panel" v-loading="loading">
      <el-tabs v-model="activeTab" type="border-card" class="asset-tabs">
        <el-tab-pane
          v-for="tab in TABS"
          :key="tab.key"
          :label="tab.label"
          :name="tab.key"
        >
          <component
            :is="currentTabComponent(tab)"
            v-if="tab.component && activeTab === tab.key"
            :id="routeId"
            @updated="handleTabUpdated"
          />
          <el-empty
            v-else-if="activeTab === tab.key"
            description="该能力建设中，敬请期待"
            :image-size="88"
          />
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup name="AssetDetail" lang="ts">
import { useRoute, useRouter } from 'vue-router';
import { getAsset } from '@/api/system/asset';
import { AssetVO } from '@/api/system/asset/types';
import { useLoading } from '@/hooks/async/useLoading';
import { TABS } from './tabs/registry';

const route = useRoute();
const router = useRouter();
const routeId = computed(() => String(route.params.id ?? ''));
const asset = ref<AssetVO>();
const { loading, withLoading } = useLoading(true);
const activeTab = ref('basic-info');

const currentTabComponent = (tab: { component?: any }) => tab.component;

/** 返回列表：有应用内历史则后退，硬刷新/直达进入时兜底跳转列表，避免退出系统 */
const handleBack = () => {
  if (window.history.state?.back) {
    router.back();
  } else {
    router.push('/asset/list');
  }
};

/** 加载系统详情（Tab 切换不重新加载，保持宿主上下文） */
const loadAsset = async () => {
  await withLoading(async () => {
    const res = await getAsset(routeId.value);
    asset.value = res.data;
  });
};

/** 子 Tab 保存后回填宿主标题 */
const handleTabUpdated = async () => {
  await loadAsset();
};

watch(routeId, () => {
  loadAsset();
});

onMounted(() => {
  loadAsset();
});
</script>

<style lang="scss" scoped>
@use '@/assets/styles/components/page-shell' as pageShell;

@include pageShell.table-crud-page;
</style>
