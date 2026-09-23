<template>
  <div class="p-2 app-container system-asset-page">
    <div class="search-wrap">
      <el-card shadow="hover" class="search-panel" :class="{ 'is-collapsed': !showSearch }">
        <template #header>
          <div class="panel-heading search-panel-toggle" @click.stop="showSearch = !showSearch">
            <div>
              <span class="panel-kicker">Search Filters</span>
              <h3>筛选条件</h3>
            </div>
          </div>
        </template>
        <el-form ref="queryFormRef" :model="queryParams" :inline="true" class="query-form">
          <el-form-item label="关键词" prop="keyword">
            <el-input
              v-model="queryParams.keyword"
              placeholder="系统编码 / 系统名称"
              clearable
              style="width: 220px"
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item label="业务域" prop="bizDomain">
            <el-input
              v-model="queryParams.bizDomain"
              placeholder="请输入所属业务域"
              clearable
              style="width: 200px"
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-select v-model="queryParams.status" placeholder="资产状态" clearable style="width: 160px">
              <el-option
                v-for="dict in asset_status"
                :key="dict.value"
                :label="dict.label"
                :value="Number(dict.value)"
              />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
    <el-card shadow="hover" class="table-panel">
      <template #header>
        <div class="toolbar-shell">
          <div class="table-heading">
            <span class="panel-kicker">Asset Dataset</span>
            <h3>系统技术资产</h3>
            <p>共 {{ total }} 条记录，支持按业务域/状态筛选、登记、导入导出。</p>
          </div>
          <div class="toolbar-actions">
            <el-button v-hasPermi="['system:asset:add']" type="primary" plain icon="Plus" @click="handleAdd">
              新增
            </el-button>
            <el-button
              v-hasPermi="['system:asset:edit']"
              type="success"
              plain
              icon="Edit"
              :disabled="single"
              @click="handleUpdate()"
            >
              修改
            </el-button>
            <el-button
              v-hasPermi="['system:asset:remove']"
              type="danger"
              plain
              icon="Delete"
              :disabled="multiple"
              @click="handleDelete()"
            >
              删除
            </el-button>
            <el-dropdown v-hasPermi="['system:asset:import']" @command="handleCommand">
              <el-button type="primary" plain icon="Upload">
                导入
                <el-icon class="el-icon--right"><arrow-down /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item icon="Upload" command="handleImport">导入数据</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
            <el-button
              v-hasPermi="['system:asset:export']"
              type="warning"
              plain
              icon="Download"
              @click="handleExport"
            >
              导出
            </el-button>
            <right-toolbar v-model:show-search="showSearch" :search="false" @query-table="getList"></right-toolbar>
          </div>
        </div>
      </template>
      <el-table
        v-loading="loading"
        border
        class="data-table"
        :data="assetList"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="系统编码" align="center" prop="code" width="150" />
        <el-table-column label="系统名称" align="center" prop="name" min-width="160" />
        <el-table-column label="所属业务域" align="center" prop="bizDomain" width="140" />
        <el-table-column label="负责人" align="center" prop="owner" width="110" />
        <el-table-column label="状态" align="center" prop="status" width="100">
          <template #default="scope">
            <dict-tag :options="asset_status" :value="scope.row.status" />
          </template>
        </el-table-column>
        <el-table-column label="创建时间" align="center" prop="createdTime" width="160">
          <template #default="scope">
            <span>{{ parseTime(scope.row.createdTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center" class-name="small-padding fixed-width">
          <template #default="scope">
            <el-tooltip content="详情" placement="top">
              <el-button link type="primary" icon="View" @click="handleDetail(scope.row)"></el-button>
            </el-tooltip>
            <el-tooltip content="编辑" placement="top">
              <el-button
                v-hasPermi="['system:asset:edit']"
                link
                type="primary"
                icon="Edit"
                @click="handleUpdate(scope.row)"
              ></el-button>
            </el-tooltip>
            <el-tooltip content="删除" placement="top">
              <el-button
                v-hasPermi="['system:asset:remove']"
                link
                type="primary"
                icon="Delete"
                @click="handleDelete(scope.row)"
              ></el-button>
            </el-tooltip>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-show="total > 0"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
        :total="total"
        @pagination="getList"
      />
    </el-card>

    <!-- 添加或修改系统技术资产对话框 -->
    <el-dialog v-model="dialog.visible" :title="dialog.title" width="720px" append-to-body>
      <el-form ref="assetFormRef" :model="form" :rules="rules" label-width="110px">
        <AssetFormFields :form="form" :is-edit="isEdit" />
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 导入对话框 -->
    <el-dialog v-model="upload.open" :title="upload.title" width="400px" append-to-body>
      <el-upload
        ref="uploadRef"
        :limit="1"
        accept=".xlsx, .xls"
        :headers="upload.headers"
        :action="upload.url"
        :disabled="upload.isUploading"
        :on-progress="handleFileUploadProgress"
        :on-success="handleFileSuccess"
        :on-error="handleFileError"
        :before-upload="handleBeforeUpload"
        :auto-upload="false"
        drag
      >
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
        <div class="el-upload__text">
          将文件拖到此处，或<em>点击上传</em>
        </div>
        <div class="el-upload__tip">仅支持 .xlsx / .xls 文件，单次上传一个</div>
      </el-upload>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitFileForm">上 传</el-button>
          <el-button @click="upload.open = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Asset" lang="ts">
import { useRouter } from 'vue-router';
import { addAsset, delAsset, exportAsset, getAsset, listAsset, updateAsset } from '@/api/system/asset';
import { AssetForm, AssetQuery, AssetVO } from '@/api/system/asset/types';
import AssetFormFields from './components/AssetFormFields.vue';
import { assetFormRules, createAssetFormData } from './assetForm';
import { useLoading } from '@/hooks/async/useLoading';
import { useFormDialog } from '@/hooks/dialog/useFormDialog';
import { useSearchReset } from '@/hooks/form/useSearchReset';
import { useSearchToggle } from '@/hooks/form/useSearchToggle';
import { useTableSelection } from '@/hooks/table/useTableSelection';
import modal from '@/plugins/modal';
import { useDict } from '@/utils/dict';
import { blobValidate, parseTime } from '@/utils/ruoyi';
import { saveBlob } from '@/utils/save';
import { globalHeaders } from '@/utils/request';

const router = useRouter();
const { asset_status } = toRefs<any>(useDict('asset_status'));

const assetList = ref<AssetVO[]>([]);
const { loading, withLoading } = useLoading(true);
const { showSearch } = useSearchToggle();
const { ids, single, multiple, handleSelectionChange } = useTableSelection<AssetVO>(item => item.id);
const total = ref(0);
const assetFormRef = ref<ElFormInstance>();
const queryFormRef = ref<ElFormInstance>();
const isEdit = ref(false);

const initFormData = createAssetFormData();

const data = reactive<PageData<AssetForm, AssetQuery>>({
  form: createAssetFormData(),
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    keyword: '',
    bizDomain: '',
    status: undefined
  },
  rules: assetFormRules
});

const { queryParams, form, rules } = toRefs<PageData<AssetForm, AssetQuery>>(data);
const { dialog, resetForm, openDialog, showDialog, closeDialog } = useFormDialog({
  form,
  formRef: assetFormRef,
  initialFormData: initFormData
});
const { resetQuery } = useSearchReset({
  queryFormRef,
  queryParams,
  pageNumKey: 'pageNum',
  afterReset: () => {
    handleQuery();
  }
});

const uploadRef = ref();
const upload = reactive({
  open: false,
  title: '',
  isUploading: false,
  headers: globalHeaders(),
  url: import.meta.env.VITE_APP_BASE_API + '/system/asset/import'
});

/** 查询系统技术资产列表 */
const getList = async () => {
  await withLoading(async () => {
    const res = await listAsset(queryParams.value);
    assetList.value = res.data?.rows;
    total.value = res.data?.total;
  });
};

/** 取消按钮 */
const cancel = () => {
  resetForm();
  closeDialog();
};

/** 搜索按钮操作 */
const handleQuery = () => {
  queryParams.value.pageNum = 1;
  getList();
};

/** 详情跳转 */
const handleDetail = (row: AssetVO) => {
  router.push('/system/' + row.id);
};

/** 新增按钮操作 */
const handleAdd = () => {
  isEdit.value = false;
  openDialog('添加系统技术资产');
};

/** 修改按钮操作 */
const handleUpdate = async (row?: Partial<AssetVO>) => {
  isEdit.value = true;
  resetForm();
  const id = row?.id || ids.value[0];
  const res = await getAsset(id);
  Object.assign(form.value, res.data);
  showDialog('修改系统技术资产');
};

/** 提交按钮 */
const submitForm = () => {
  assetFormRef.value?.validate(async (valid: boolean) => {
    if (valid) {
      form.value.id ? await updateAsset(form.value) : await addAsset(form.value);
      modal.msgSuccess('操作成功');
      closeDialog();
      await getList();
    }
  });
};

/** 删除按钮操作 */
const handleDelete = async (row?: Partial<AssetVO>) => {
  const assetIds = row?.id || ids.value;
  await modal.confirm('是否确认删除系统资产"' + (row?.code ?? assetIds) + '"的数据项？删除后将不可恢复。');
  await delAsset(assetIds);
  await getList();
  modal.msgSuccess('删除成功');
};

/** 导入/导出下拉命令 */
const handleCommand = (command: string) => {
  if (command === 'handleImport') {
    handleImport();
  }
};

/** 导入按钮操作 */
const handleImport = () => {
  upload.title = '导入系统技术资产';
  upload.open = true;
};

/** 文件上传中处理 */
const handleFileUploadProgress = () => {
  upload.isUploading = true;
};

/** 文件上传成功处理 */
const handleFileSuccess = (response: any) => {
  upload.isUploading = false;
  upload.open = false;
  if (response.code === 200) {
    modal.msgSuccess(response.msg || '导入成功');
    getList();
  } else {
    modal.msgError(response.msg || '导入失败');
  }
};

/** 文件上传失败处理 */
const handleFileError = () => {
  upload.isUploading = false;
  modal.msgError('导入失败，请检查文件后重试');
};

/** 上传前校验 */
const handleBeforeUpload = (file: File) => {
  const ext = file.name.split('.').pop()?.toLowerCase();
  if (!['xlsx', 'xls'].includes(ext ?? '')) {
    modal.msgError('仅支持 .xlsx / .xls 文件');
    return false;
  }
  if (file.size / 1024 / 1024 > 10) {
    modal.msgError('文件大小不能超过 10MB');
    return false;
  }
  return true;
};

/** 提交上传文件 */
const submitFileForm = () => {
  uploadRef.value?.submit();
};

/** 导出按钮操作 */
const handleExport = async () => {
  const blob = (await exportAsset(queryParams.value)) as unknown as Blob;
  if (blobValidate(blob)) {
    saveBlob(blob, `系统资产_${new Date().getTime()}.csv`);
    modal.msgSuccess('导出成功');
  } else {
    const text = await blob.text();
    const rspObj = JSON.parse(text);
    modal.msgError(rspObj.msg || '导出失败');
  }
};

// 页面被 keep-alive 缓存：首次进入由 onMounted 加载；
// 从详情页（含编辑保存）返回时 onMounted 不再触发，需在 onActivated 重新查询
const mountedOnce = ref(true);
onMounted(() => {
  getList();
});

onActivated(() => {
  if (mountedOnce.value) {
    mountedOnce.value = false;
    return;
  }
  getList();
});
</script>

<style lang="scss" scoped>
@use '@/assets/styles/components/page-shell' as pageShell;

@include pageShell.table-crud-page;
</style>
