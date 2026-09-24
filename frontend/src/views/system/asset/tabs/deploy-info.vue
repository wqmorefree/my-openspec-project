<template>
  <div class="deploy-info-tab" v-loading="loading">
    <el-card shadow="never">
      <template #header>
        <div class="toolbar-shell">
          <div class="table-heading">
            <span class="panel-kicker">Deployment</span>
            <h3>部署信息</h3>
            <p>登记当前系统在各环境下的部署节点、资源规格与网络配置。</p>
          </div>
          <div class="toolbar-actions">
            <el-select
              v-model="envFilter"
              placeholder="系统环境"
              clearable
              class="env-filter"
              @change="getList"
            >
              <el-option
                v-for="dict in deploy_sys_env"
                :key="dict.value"
                :label="dict.label"
                :value="Number(dict.value)"
              />
            </el-select>
            <el-button
              v-hasPermi="['system:asset:add']"
              type="primary"
              icon="Plus"
              @click="handleAdd"
            >
              新增
            </el-button>
            <el-button
              v-hasPermi="['system:asset:import']"
              type="info"
              plain
              icon="Upload"
              @click="upload.open = true"
            >
              导入
            </el-button>
            <el-button
              v-hasPermi="['system:asset:export']"
              type="warning"
              plain
              icon="Download"
              @click="handleExport"
            >
              导出
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="dataList" border>
        <el-table-column label="序号" type="index" width="55" align="center" />
        <el-table-column label="模块名称" prop="moduleName" min-width="120" show-overflow-tooltip />
        <el-table-column label="部署应用" prop="deployApp" min-width="120" show-overflow-tooltip />
        <el-table-column label="主机名" prop="hostName" min-width="120" show-overflow-tooltip />
        <el-table-column label="IP地址" prop="ipAddress" width="140" show-overflow-tooltip />
        <el-table-column label="机房" prop="idc" min-width="100" show-overflow-tooltip />
        <el-table-column label="CPU（核）" prop="cpuCores" width="90" align="center" />
        <el-table-column label="内存（G）" prop="memoryGb" width="90" align="center" />
        <el-table-column label="系统环境" width="100" align="center">
          <template #default="scope">
            <dict-tag :options="deploy_sys_env" :value="scope.row.sysEnv" />
          </template>
        </el-table-column>
        <el-table-column label="运行环境" prop="runtimeEnv" min-width="110" show-overflow-tooltip />
        <el-table-column label="操作" width="170" align="center" fixed="right">
          <template #default="scope">
            <el-button link type="primary" icon="View" @click="handleView(scope.row)">详情</el-button>
            <el-button
              v-hasPermi="['system:asset:edit']"
              link
              type="primary"
              icon="Edit"
              @click="handleEdit(scope.row)"
            >
              修改
            </el-button>
            <el-button
              v-hasPermi="['system:asset:remove']"
              link
              type="danger"
              icon="Delete"
              @click="handleDelete(scope.row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑部署节点对话框 -->
    <el-dialog
      v-model="dialog.visible"
      :title="dialog.title"
      width="1080px"
      append-to-body
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <DeployFormFields :form="form" />
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="dialog.visible = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 部署节点详情抽屉 -->
    <el-drawer v-model="drawer.visible" title="部署节点详情" size="640px" append-to-body>
      <div v-if="current" class="deploy-detail">
        <el-descriptions title="基础信息" :column="2" border>
          <el-descriptions-item label="模块名称">{{ fmt(current.moduleName) }}</el-descriptions-item>
          <el-descriptions-item label="部署应用">{{ fmt(current.deployApp) }}</el-descriptions-item>
          <el-descriptions-item label="主机名">{{ fmt(current.hostName) }}</el-descriptions-item>
          <el-descriptions-item label="IP地址">{{ fmt(current.ipAddress) }}</el-descriptions-item>
          <el-descriptions-item label="系统环境">
            <dict-tag :options="deploy_sys_env" :value="current.sysEnv" />
          </el-descriptions-item>
          <el-descriptions-item label="运行环境">{{ fmt(current.runtimeEnv) }}</el-descriptions-item>
          <el-descriptions-item label="应用描述" :span="2">{{ fmt(current.appDesc) }}</el-descriptions-item>
        </el-descriptions>

        <el-descriptions title="资源配置" :column="2" border class="mt-16">
          <el-descriptions-item label="容器IP">{{ fmt(current.containerIp) }}</el-descriptions-item>
          <el-descriptions-item label="机房">{{ fmt(current.idc) }}</el-descriptions-item>
          <el-descriptions-item label="服务器类型">{{ fmt(current.serverType) }}</el-descriptions-item>
          <el-descriptions-item label="CPU（核）">{{ fmt(current.cpuCores) }}</el-descriptions-item>
          <el-descriptions-item label="内存（G）">{{ fmt(current.memoryGb) }}</el-descriptions-item>
          <el-descriptions-item label="节点数量">{{ fmt(current.nodeCount) }}</el-descriptions-item>
          <el-descriptions-item label="系统盘（G）">{{ fmt(current.sysDiskGb) }}</el-descriptions-item>
          <el-descriptions-item label="数据盘（G）">{{ fmt(current.dataDiskGb) }}</el-descriptions-item>
          <el-descriptions-item label="操作系统" :span="2">{{ fmt(current.osInfo) }}</el-descriptions-item>
        </el-descriptions>

        <el-descriptions title="网络配置" :column="2" border class="mt-16">
          <el-descriptions-item label="链接模版">{{ fmt(current.linkTemplate) }}</el-descriptions-item>
          <el-descriptions-item label="租户">{{ fmt(current.tenant) }}</el-descriptions-item>
          <el-descriptions-item label="VPC">{{ fmt(current.vpc) }}</el-descriptions-item>
          <el-descriptions-item label="安全组">{{ fmt(current.securityGroup) }}</el-descriptions-item>
          <el-descriptions-item label="部署网段">{{ fmt(current.deploySubnet) }}</el-descriptions-item>
          <el-descriptions-item label="域名">{{ fmt(current.domainName) }}</el-descriptions-item>
          <el-descriptions-item label="网络QoS策略" :span="2">{{ fmt(current.networkQos) }}</el-descriptions-item>
        </el-descriptions>

        <el-descriptions title="运维配置" :column="2" border class="mt-16">
          <el-descriptions-item label="快照备份需求">{{ fmt(current.snapshotNeed) }}</el-descriptions-item>
          <el-descriptions-item label="路径信息">{{ fmt(current.pathInfo) }}</el-descriptions-item>
          <el-descriptions-item label="文件挂载">{{ fmt(current.fileMount) }}</el-descriptions-item>
          <el-descriptions-item label="是否涉及批量操作">{{ yesNo(current.batchOpFlag) }}</el-descriptions-item>
          <el-descriptions-item label="批量调度平台">{{ fmt(current.batchSchedPlatform) }}</el-descriptions-item>
          <el-descriptions-item label="是否纳入应用监控">{{ yesNo(current.appMonitorFlag) }}</el-descriptions-item>
          <el-descriptions-item label="国产化">{{ yesNo(current.domesticFlag) }}</el-descriptions-item>
          <el-descriptions-item label="ETL工具">{{ fmt(current.etlTool) }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ fmt(current.remark) }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-drawer>

    <!-- 部署节点导入对话框 -->
    <el-dialog v-model="upload.open" title="部署节点导入" width="400px" append-to-body>
      <el-upload
        ref="uploadRef"
        accept=".xlsx, .xls"
        :show-file-list="false"
        :auto-upload="false"
        :on-change="handleFileChange"
        drag
      >
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
        <div class="el-upload__text">
          将文件拖到此处，或<em>点击上传</em>
        </div>
        <div class="el-upload__tip">仅支持 .xlsx / .xls 文件，单次上传一个</div>
      </el-upload>
      <div v-if="upload.file" class="selected-file">
        <el-icon><Document /></el-icon>
        <span class="file-name">{{ upload.file.name }}</span>
        <el-button link type="danger" icon="Close" @click="clearSelectedFile" />
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="upload.importing" @click="handleImport">上 传</el-button>
          <el-button @click="upload.open = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import {
  addDeploy,
  delDeploy,
  exportDeploy,
  importDeploy,
  listDeploy,
  updateDeploy
} from '@/api/system/asset/deploy';
import type { DeployForm, DeployVO } from '@/api/system/asset/deploy/types';
import DeployFormFields from '../components/DeployFormFields.vue';
import { useLoading } from '@/hooks/async/useLoading';
import modal from '@/plugins/modal';
import { useDict } from '@/utils/dict';
import { blobValidate } from '@/utils/ruoyi';
import { saveBlob } from '@/utils/save';

const props = defineProps<{ id: string }>();
const emit = defineEmits<{ (e: 'updated'): void }>();

const { deploy_sys_env } = toRefs<any>(useDict('deploy_sys_env'));

const { loading, withLoading } = useLoading(false);
const dataList = ref<DeployVO[]>([]);
const envFilter = ref<number>();
const formRef = ref<ElFormInstance>();
const uploadRef = ref();

/** 导入对话框状态 */
const upload = reactive<{ open: boolean; importing: boolean; file?: File }>({
  open: false,
  importing: false,
  file: undefined
});

/** 部署表单初始数据（标记字段默认 0-否） */
const createForm = (): DeployForm => ({
  id: undefined,
  assetId: props.id,
  moduleName: '',
  deployApp: '',
  hostName: '',
  ipAddress: '',
  containerIp: '',
  linkTemplate: '',
  idc: '',
  cpuCores: undefined,
  memoryGb: undefined,
  sysDiskGb: undefined,
  dataDiskGb: undefined,
  osInfo: '',
  snapshotNeed: '',
  serverType: '',
  nodeCount: undefined,
  tenant: '',
  vpc: '',
  securityGroup: '',
  appDesc: '',
  sysEnv: undefined as unknown as number,
  runtimeEnv: '',
  deploySubnet: '',
  pathInfo: '',
  fileMount: '',
  batchOpFlag: 0,
  batchSchedPlatform: '',
  appMonitorFlag: 0,
  networkQos: '',
  domainName: '',
  domesticFlag: 0,
  etlTool: '',
  remark: ''
});

const form = reactive<DeployForm>(createForm());

const rules: FormRules = {
  moduleName: [{ required: true, message: '模块名称不能为空', trigger: 'blur' }],
  deployApp: [{ required: true, message: '部署应用不能为空', trigger: 'blur' }],
  hostName: [{ required: true, message: '主机名不能为空', trigger: 'blur' }],
  ipAddress: [{ required: true, message: 'IP地址不能为空', trigger: 'blur' }],
  sysEnv: [{ required: true, message: '系统环境不能为空', trigger: 'change' }]
};

const dialog = reactive<{ visible: boolean; title: string }>({ visible: false, title: '' });
const drawer = reactive<{ visible: boolean }>({ visible: false });
const current = ref<DeployVO>();

/** 查询部署节点列表 */
const getList = async () => {
  await withLoading(async () => {
    const res = await listDeploy({ assetId: props.id, sysEnv: envFilter.value });
    dataList.value = res.data;
  });
};

/** 新增按钮 */
const handleAdd = () => {
  Object.assign(form, createForm());
  dialog.title = '新增部署节点';
  dialog.visible = true;
};

/** 修改按钮（BigDecimal 后端序列化为字符串，el-input-number 需 Number，这里统一转换） */
const handleEdit = (row: DeployVO) => {
  const toNum = (v: string | number | undefined) =>
    v === undefined || v === null || v === '' ? undefined : Number(v);
  Object.assign(form, createForm(), row, {
    cpuCores: toNum(row.cpuCores),
    memoryGb: toNum(row.memoryGb),
    sysDiskGb: toNum(row.sysDiskGb),
    dataDiskGb: toNum(row.dataDiskGb),
    nodeCount: toNum(row.nodeCount)
  });
  dialog.title = '编辑部署节点';
  dialog.visible = true;
};

/** 查看详情 */
const handleView = (row: DeployVO) => {
  current.value = row;
  drawer.visible = true;
};

/** 提交表单 */
const submitForm = async () => {
  if (!formRef.value) return;
  const valid = await formRef.value.validate().catch(() => false);
  if (!valid) return;
  form.assetId = props.id;
  try {
    if (form.id) {
      await updateDeploy(form);
    } else {
      await addDeploy(form);
    }
    modal.msgSuccess('操作成功');
    dialog.visible = false;
    await getList();
    emit('updated');
  } catch {
    modal.msgError('操作失败，请重试');
  }
};

/** 删除按钮（二次确认） */
const handleDelete = (row: DeployVO) => {
  modal
    .confirm(`是否确认删除部署节点“${row.moduleName}”？`)
    .then(async () => {
      await delDeploy(row.id);
      modal.msgSuccess('删除成功');
      await getList();
    })
    .catch(() => {});
};

/** 选择导入文件（覆盖式，仅保留最近一次） */
const handleFileChange = (uploadFile: { raw: File }) => {
  upload.file = uploadFile.raw;
};

/** 清除已选文件 */
const clearSelectedFile = () => {
  upload.file = undefined;
  uploadRef.value?.clearFiles();
};

/** 对话框提交导入 */
const handleImport = async () => {
  if (!upload.file) {
    modal.msgWarning('请先选择要导入的文件');
    return;
  }
  try {
    upload.importing = true;
    const res = await importDeploy(upload.file, props.id);
    modal.alertSuccess(res.data || res.msg || '导入成功');
    upload.open = false;
    upload.file = undefined;
    uploadRef.value?.clearFiles();
    await getList();
  } catch {
    modal.msgError('导入失败，请检查文件格式或网络后重试');
  } finally {
    upload.importing = false;
  }
};

/** CSV 导出 */
const handleExport = async () => {
  const blob = (await exportDeploy({ assetId: props.id, sysEnv: envFilter.value })) as unknown as Blob;
  if (blobValidate(blob)) {
    saveBlob(blob, `部署节点_${new Date().getTime()}.csv`);
    modal.msgSuccess('导出成功');
  } else {
    const text = await blob.text();
    try {
      const rspObj = JSON.parse(text);
      modal.msgError(rspObj.msg || '导出失败');
    } catch {
      modal.msgError('导出失败');
    }
  }
};

/** 空值占位（0 为合法值，不兜底）；统一返回字符串，避免 descriptions value 类型告警 */
const fmt = (value: string | number | undefined | null) => {
  if (value === undefined || value === null || value === '') {
    return '-';
  }
  return String(value);
};

/** 0/1 标记转 否/是 */
const yesNo = (flag: number) => (flag === 1 ? '是' : '否');

onMounted(() => {
  getList();
});
</script>

<style lang="scss" scoped>
.deploy-info-tab {
  .toolbar-shell {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
  }

  .toolbar-actions {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .env-filter {
    width: 140px;
  }

  .inline-upload {
    display: inline-block;
  }

  .selected-file {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 12px;
    padding: 8px 12px;
    background: var(--el-fill-color-light);
    border-radius: 4px;

    .file-name {
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      font-size: 13px;
    }
  }
}

.deploy-detail {
  .mt-16 {
    margin-top: 16px;
  }
}
</style>
