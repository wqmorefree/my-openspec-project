<template>
  <div class="asset-basic-info" v-loading="loading">
    <el-card shadow="hover" class="info-panel">
      <template #header>
        <div class="toolbar-shell">
          <div class="table-heading">
            <span class="panel-kicker">Basic Info</span>
            <h3>基础信息</h3>
            <p>系统编码、名称、归属、状态及项目/负责人等基础字段。</p>
          </div>
          <el-button v-hasPermi="['system:asset:edit']" type="primary" plain icon="Edit" @click="handleEdit">
            编辑
          </el-button>
        </div>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="系统编码">{{ asset?.code }}</el-descriptions-item>
        <el-descriptions-item label="系统名称">{{ asset?.name }}</el-descriptions-item>
        <el-descriptions-item label="所属业务域">{{ asset?.bizDomain }}</el-descriptions-item>
        <el-descriptions-item label="负责人">{{ asset?.owner }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <dict-tag :options="asset_status" :value="asset?.status" />
        </el-descriptions-item>
        <el-descriptions-item label="系统类别">{{ asset?.category || '-' }}</el-descriptions-item>
        <el-descriptions-item label="项目名称">{{ asset?.projectName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="项目编号">{{ asset?.projectNo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="组长">{{ asset?.leaderName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="组长手机">{{ asset?.leaderMobile || '-' }}</el-descriptions-item>
        <el-descriptions-item label="项目经理">{{ asset?.pmName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="项目经理手机">{{ asset?.pmMobile || '-' }}</el-descriptions-item>
        <el-descriptions-item label="SVN文档地址">{{ asset?.svnDocUrl || '-' }}</el-descriptions-item>
        <el-descriptions-item label="Git代码地址">{{ asset?.gitCodeUrl || '-' }}</el-descriptions-item>
        <el-descriptions-item label="模块名">{{ asset?.moduleName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="分支名">{{ asset?.branchName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="分支描述">{{ asset?.branchDesc || '-' }}</el-descriptions-item>
        <el-descriptions-item label="分支地址">{{ asset?.branchUrl || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ parseTime(asset?.createdTime) }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ parseTime(asset?.updatedTime) }}</el-descriptions-item>
        <el-descriptions-item label="系统介绍" :span="2">{{ asset?.intro || '-' }}</el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 编辑基础信息对话框 -->
    <el-dialog v-model="dialog.visible" :title="dialog.title" width="720px" append-to-body>
      <el-form ref="editFormRef" :model="form" :rules="rules" label-width="110px">
        <AssetFormFields :form="form" is-edit />
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="dialog.visible = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { getAsset, updateAsset } from '@/api/system/asset';
import { AssetForm, AssetVO } from '@/api/system/asset/types';
import AssetFormFields from '../components/AssetFormFields.vue';
import { assetFormRules, createAssetFormData } from '../assetForm';
import { useLoading } from '@/hooks/async/useLoading';
import modal from '@/plugins/modal';
import { useDict } from '@/utils/dict';
import { parseTime } from '@/utils/ruoyi';

const props = defineProps<{ id: string }>();
const emit = defineEmits<{ (e: 'updated'): void }>();

const { asset_status } = toRefs<any>(useDict('asset_status'));
const asset = ref<AssetVO>();
const { loading, withLoading } = useLoading(true);
const editFormRef = ref<ElFormInstance>();

const form = reactive<AssetForm>(createAssetFormData());
const rules = assetFormRules;
const dialog = reactive<{ visible: boolean; title: string }>({ visible: false, title: '' });

const loadAsset = async () => {
  await withLoading(async () => {
    const res = await getAsset(props.id);
    asset.value = res.data;
  });
};

/** 编辑按钮操作 */
const handleEdit = () => {
  Object.assign(form, asset.value);
  dialog.title = '编辑基础信息';
  dialog.visible = true;
};

/** 提交按钮 */
const submitForm = () => {
  editFormRef.value?.validate(async (valid: boolean) => {
    if (valid) {
      await updateAsset(form);
      modal.msgSuccess('操作成功');
      dialog.visible = false;
      await loadAsset();
      emit('updated');
    }
  });
};

onMounted(() => {
  loadAsset();
});
</script>

<style lang="scss" scoped>
@use '@/assets/styles/components/page-shell' as pageShell;

@include pageShell.table-crud-page;
</style>
